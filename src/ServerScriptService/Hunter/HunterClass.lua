local Hunter = {}
Hunter.__index = Hunter
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeStateHunterEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateHunterEvent")
-- local PathfindingService = game:GetService("PathfindingService")
local Status = require(game.ServerScriptService.BehaviourTree.Node.Utiles.Status)

--[[
    Classe Hunter: gère le comportement et les actions d'un chasseur dans le jeu.
    @param model: Model - le modèle du chasseur dans le jeu
]]
function Hunter.new(model: Model)
    local self = setmetatable({}, Hunter)
    self.Model = model
    self.Humanoid = model:WaitForChild("Humanoid")
	self.Root = model:WaitForChild("HumanoidRootPart")

    -- Paramètres d'attaque
    self.closeAttackRange = 10
    self.closeAttackDamage = 20
    self.attackCooldown = 3
    self.attackDuration = 1.5
	
	
    self.isAttacking = false

	--Paramètres d'attaque à distance 
	self.rangedMinRange = 12
	self.rangedMaxRange = 50
	self.rangedAttackDamage = 15

	-- Timing tir
	self.rangedCooldown = 1.2
	self.rangedAttackDuration = 0.25 -- temps "tir" (animation/lock) simulé

	-- Munitions 
	self.magSize = 2
	self.ammoInMag = self.magSize
	self.maxAmmoReserve = 0
	self.ammoReserve = self.maxAmmoReserve 

	-- Reload 
	self.reloadDuration = 1.4
	self.isReloading = false
	self.reloadEndTime = 0

    -- Animation
    self.state = ""
    self:ChangeState("Idle")  -- État initial du chasseur

		
	-- État attaque (tu peux garder un seul flag pour l’instant)
	self.isAttacking = false
	self.attackEndTime = 0
	self.nextRangedTime = 0

    return self
end

--[[
	Arrête le mouvement du chasseur
]]
function Hunter:StopMove()
	self.moveState = nil
	self.patrolState = nil
	self.Humanoid:Move(Vector3.zero)
	self:ChangeState("Idle")
end


--[[
    Déplace le chasseur vers une position cible
    @param targetPosition: Vector3 - la position vers laquelle se déplacer en pathfinding
]]
function Hunter:Follow(position, timeout)
	timeout = timeout or 5

	-- target invalide → stop
	if not position then
		self:StopMove()
		return Status.FAILURE
	end

	-- start move si nécessaire
	if not self.moveState then
		self.moveState = {
			target = position,
			startTime = os.clock(),
			timeout = timeout
		}

		self:ChangeState("Walk")
		self.Humanoid:MoveTo(position)
		return Status.RUNNING
	end

	-- réajuster si la cible a bougé
	if (self.moveState.target - position).Magnitude > 2 then
		self.moveState.target = position
		self.Humanoid:MoveTo(position)
	end

	-- timeout
	if os.clock() - self.moveState.startTime > self.moveState.timeout then
		self:StopMove()
		return Status.FAILURE
	end

	-- arrivé
	if (self.Root.Position - self.moveState.target).Magnitude < 4 then
		self:StopMove()
		return Status.SUCCESS
	end

	return Status.RUNNING
end


--[[
    Déplace le chasseur vers une position cible
    @param targetPosition: Vector3 - la position vers laquelle se déplacer
]]
function Hunter:Patrol(radius)
	-- Si pas de state ou on est arrivé, générer nouvelle destination
	if not self.patrolState or (self.Root.Position - self.patrolState.target).Magnitude < 4 then
		self:StopMove()

		local offset = Vector3.new(
			math.random(-radius, radius),
			0,
			math.random(-radius, radius)
		)

		self.patrolState = {
			target = self.Root.Position + offset
		}

		self:ChangeState("Walk")
		self.Humanoid:MoveTo(self.patrolState.target)
		return Status.RUNNING
	end

	-- Si on est encore en route
	if self.patrolState then
		self.Humanoid:MoveTo(self.patrolState.target)
		return Status.RUNNING
	end

	return Status.SUCCESS
end

--[[
    Attaque d'une cible
    @param target: RabbitClass - la cible à attaquer
]]
function Hunter:TryAttackClose(target)
	if self.isAttacking then
		if os.clock() >= self.attackEndTime then
			self.isAttacking = false
			self:ChangeState("Idle")
			return Status.SUCCESS
		end
		return Status.RUNNING
	end
	
	-- conditions
	local dist = (self.Root.Position - target.Root.Position).Magnitude
	if dist > self.closeAttackRange then
		return Status.FAILURE
	end

	-- cooldown
	if os.clock() < (self.nextAttackTime or 0) then
		return Status.FAILURE
	end

	-- start attack
	self.isAttacking = true
	self.attackEndTime = os.clock() + self.attackDuration
	self.nextAttackTime = os.clock() + self.attackCooldown

	self:ChangeState("AttackPied")
	target:RemoveHealth(self.closeAttackDamage)

	return Status.RUNNING
end



--[[
    Change l'état du chasseur et envoie au Client pour faire l'animation
    @param state: string - le nouvel état du chasseur
]]
function Hunter:ChangeState(state)
    self.state = state
    --envoie au client
    ChangeStateHunterEvent:FireAllClients(self.Model, state)
end





--[[
    Recharge l'arme
    @return Status.SUCCESS si reload terminé,
            Status.RUNNING si reload en cours,
            Status.FAILURE si impossible de recharger
]]
function Hunter:TryReloadWeapon()
	-- Reload déjà en cours
	if self.isReloading then
		if os.clock() >= self.reloadEndTime then
			self.isReloading = false

			local missing = self.magSize - self.ammoInMag
			local take = math.min(missing, self.ammoReserve)

			self.ammoInMag += take
			self.ammoReserve -= take

			self:ChangeState("Idle")
			print(string.format("[RELOAD] Terminé -> chargeur=%d/%d | réserve=%d",
				self.ammoInMag, self.magSize, self.ammoReserve
			))

			return Status.SUCCESS
		end

		return Status.RUNNING
	end

	-- Conditions pour démarrer
	if not self:CanReload() then
		print(string.format("[RELOAD] Impossible -> chargeur=%d/%d | réserve=%d",
			self.ammoInMag, self.magSize, self.ammoReserve
		))
		return Status.FAILURE
	end

	-- Start reload
	self.isReloading = true
	self.reloadEndTime = os.clock() + self.reloadDuration

	self:ChangeState("Reload")
	print(string.format("[RELOAD] Début -> chargeur=%d/%d | réserve=%d (%.1fs)",
		self.ammoInMag, self.magSize, self.ammoReserve, self.reloadDuration
	))

	return Status.RUNNING
end

--[[
    Attaque d'une cible à distance (simulation munitions + reload)
    @param target: RabbitClass - la cible à attaquer
]]
function Hunter:TryRangedAttack(target)
	if not target or not target.Root then
		return Status.FAILURE
	end

	-- Si reload en cours, on laisse finir (priorité)
	if self.isReloading then
		return self:TryReloadWeapon()
	end

	-- Si tir en cours
	if self.isAttacking then
		if os.clock() >= self.attackEndTime then
			self.isAttacking = false
			self:ChangeState("Idle")
			print("[RANGED] Fin tir")
			return Status.SUCCESS
		end
		return Status.RUNNING
	end

	-- Distance valide
	local dist = (self.Root.Position - target.Root.Position).Magnitude
	if dist < self.rangedMinRange or dist > self.rangedMaxRange then
		return Status.FAILURE
	end

	-- Cooldown
	if os.clock() < (self.nextRangedTime or 0) then
		return Status.FAILURE
	end

	-- Chargeur vide -> reload
	if self:NeedsReload() then
		print("[RANGED] Chargeur vide -> reload")
		return self:TryReloadWeapon()
	end

	-- 🔴 STOP AVANT TIR
	self:StopMove()

	-- Start tir
	self.isAttacking = true
	self.attackEndTime = os.clock() + self.rangedAttackDuration
	self.nextRangedTime = os.clock() + self.rangedCooldown

	-- Consomme 1 munition
	self.ammoInMag -= 1

	self:ChangeState("AttackArme")
	print(string.format(
		"[RANGED] Tir simulé | dist=%.1f | chargeur=%d/%d | réserve=%d",
		dist,
		self.ammoInMag, self.magSize, self.ammoReserve
	))

	target:RemoveHealth(self.rangedAttackDamage)

	return Status.RUNNING
end

--===========================================================
-- Méthodes spécifiques au ravitaillement en munitions
--===========================================================

 --[[
	Obtient la position de la cabane de ravitaillement
	@return Vector3 - la position de la cabane]]

function Hunter:GetHutPart()
	return workspace:FindFirstChild("RefillPoint")
end

--[[
	Vérifie si le chasseur a besoin de munitions
	@return boolean - true si le chasseur doit récupérer des munitions, false sinon
]]
function Hunter:NeedsMunitions()
	return (self.ammoReserve or 0) <= 0 and (self.ammoInMag or 0) <= 0
end

--[[
	Déplace le chasseur vers une partie cible
]]
function Hunter:MoveToPoint(part, timeout, arriveRadius)
	if not part then return Status.FAILURE end
	arriveRadius = arriveRadius or ((part.Size.Magnitude * 0.5) + 4) -- auto
	return self:Follow(part.Position, timeout, arriveRadius)
end

--[[
	Vérifie si le chasseur a besoin de recharger
	@return boolean - true si le chasseur doit recharger, false sinon
]]
function Hunter:NeedsReload()
	return (self.ammoInMag or 0) <= 0
end
--[[
	Vérifie si le chasseur peut recharger
	@return boolean - true si le chasseur peut recharger, false sinon
]]
function Hunter:CanReload()
	return (self.ammoReserve or 0) > 0 and (self.ammoInMag or 0) < (self.magSize or 0)
end


--[[
	Va récupérer des munitions à un point dédié
	@return boolean - true si les munitions sont récupérées, false sinon
]]

function Hunter:RefillMunitions()
	self:StopMove()

	-- Remplit la réserve
	self.ammoReserve = self.maxAmmoReserve

	-- recharge direct le chargeur
	local missing = self.magSize - self.ammoInMag
	local take = math.min(missing, self.ammoReserve)
	self.ammoInMag += take
	self.ammoReserve -= take

	self:ChangeState("Idle")
	print(string.format("[REFILL] réserve=%d | chargeur=%d/%d",
		self.ammoReserve, self.ammoInMag, self.magSize
	))

	return true
end




return Hunter