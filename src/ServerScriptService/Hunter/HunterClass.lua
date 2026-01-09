local Hunter = {}
Hunter.__index = Hunter

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local ChangeStateHunterEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateHunterEvent")
local ServerStorage = game:GetService("ServerStorage")

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

	-- =============================
	-- Paramètres d'attaque close
	-- =============================
	self.closeAttackDamage = 20
	self.attackCooldown = 3
	self.attackDuration = 1.5

	-- =============================
	-- Paramètres d'attaque à distance
	-- =============================
	self.rangedAttackDamage = 15

	-- Timing tir
	self.rangedCooldown = 2
	self.rangedAttackDuration = 0.5

	self.isAiming = false
	self.aimEndTime = 0
	self.aimDuration = 1

	-- =============================
	-- Munitions
	-- =============================
	self.magSize = 2
	self.ammoInMag = self.magSize

	self.maxAmmoReserve = 2
	self.ammoReserve = self.maxAmmoReserve

	-- =============================
	-- Reload
	-- =============================
	self.reloadDuration = 3
	self.isReloading = false
	self.reloadEndTime = 0

	-- =============================
	-- Pathfinding state
	-- =============================
	self.lastPathCompute = 0
	self.pathState = nil
	self.patrolState = nil
	self.moveState = nil

	-- =============================
	-- Animation / state
	-- =============================
	self.state = ""
	self:ChangeState("Idle")

	-- =============================
	-- États d'attaque / timers
	-- =============================
	self.isAttacking = false
	self.isRangedAttacking = false
	self.attackEndTime = 0

	self.nextAttackTime = 0      -- close
	self.nextRangedTime = 0      -- ranged

	-- =============================
	-- Pèges
	-- =============================
	-- self.ActiveTraps = {}
	-- self.maxActiveTraps = 4
	self.trapsStockMax = 5
	self.trapsStock = self.trapsStockMax



	return self
end

--[[
	Arrête le mouvement du chasseur
]]
function Hunter:StopMove()
	self.moveState = nil
	self.patrolState = nil
	self.pathState = nil
	self.Humanoid:Move(Vector3.zero)
	self:ChangeState("Idle")
end

--[[
	Calcule un chemin vers une position cible
	@param targetPosition: Vector3 - la position cible
	@return table - liste de waypoints du chemin, ou nil si le chemin ne peut pas être calculé
]]
function Hunter:ComputePath(targetPosition)
	self.lastPathCompute = os.clock()

    local path = PathfindingService:CreatePath({
        AgentRadius = 8,
        AgentHeight = 25,
        AgentCanJump = false,
		WaypointSpacing = 6, 
		Costs = {
			Danger = math.huge,
		}
    })

    path:ComputeAsync(self.Root.Position, targetPosition)

    if path.Status ~= Enum.PathStatus.Success then
        return nil
    end

    return path:GetWaypoints()
end

local function IsWaypointValid(root, waypoint)
	local dirToWaypoint = (waypoint.Position - root.Position)
	if dirToWaypoint.Magnitude < 4 then
		return false
	end

	local forward = root.CFrame.LookVector
	local dot = forward:Dot(dirToWaypoint.Unit)

	-- dot < 0 => derrière le perso
	return dot > 0
end

local function GetFirstValidWaypoint(root, waypoints)
	for i, wp in ipairs(waypoints) do
		if IsWaypointValid(root, wp) then
			return i
		end
	end
	return 1
end

--Pour DEBUG
local folder = Instance.new("Folder")
folder.Name = "DebugPath"
folder.Parent = workspace
--[[
    Déplace le chasseur vers une position cible
    @param targetPosition: Vector3 - la position vers laquelle se déplacer en pathfinding
]]
function Hunter:Follow(position, timeout)
	timeout = timeout or 5

	-- target invalide -> stop
	if not position then
		self:StopMove()
		return Status.FAILURE
	end

	-- start move si nécessaire
	if not self.pathState then

		if os.clock() - self.lastPathCompute < 0.5 then
			return Status.RUNNING
		end

        local waypoints = self:ComputePath(position)
        if not waypoints or #waypoints == 0 then
            return Status.FAILURE
        end
		--Pour DEBUG
		folder:ClearAllChildren()
		for _, waypoint in pairs(waypoints) do
			local part = Instance.new("Part")
			part.Size = Vector3.new(1,1,1)
			part.Parent = folder
			part.Position = waypoint.Position + Vector3.new(0,2,0)
			part.Anchored = true	
			part.CanCollide = false
			part.BrickColor = BrickColor.new("Bright yellow")
		end

        self.pathState = {
            waypoints = waypoints,
            index = 1,
            target = position,
            startTime = os.clock(),
            timeout = timeout
        }

        self:ChangeState("Walk")
        self.Humanoid:MoveTo(waypoints[GetFirstValidWaypoint(self.Root, waypoints)].Position)
        return Status.RUNNING
    end


	-- TARGET A BOUGÉ -> RECALCUL
    if (self.pathState.target - position).Magnitude > 12 then
        self:StopMove()
        return Status.RUNNING
    end

	-- TIMEOUT
    if os.clock() - self.pathState.startTime > self.pathState.timeout then
        self:StopMove()
        return Status.FAILURE
    end

	local waypoint = self.pathState.waypoints[self.pathState.index]

    -- ATTEINT LE WAYPOINT
    if (self.Root.Position - waypoint.Position).Magnitude < 3 then
        self.pathState.index += 1

        -- FIN DU CHEMIN
        if self.pathState.index > #self.pathState.waypoints then
            self:StopMove()
            return Status.SUCCESS
        end

        local nextWaypoint = self.pathState.waypoints[self.pathState.index]
        self.Humanoid:MoveTo(nextWaypoint.Position)
    end

	return Status.RUNNING
end



--[[
    Déplace le chasseur vers une position cible
    @param targetPosition: Vector3 - la position vers laquelle se déplacer
]]
function Hunter:Patrol(radius)
	radius = radius or 40

	-- init patrol
	if not self.patrolState then
		self.patrolState = {
			mode = "Waiting",
			radius = radius,
			waitEndTime = os.clock() + math.random(0, 1)
		}
		self:ChangeState("Idle")
		return Status.RUNNING
	end

	---------------------------------------------------
	-- MODE : WAITING (regarde autour de lui)
	---------------------------------------------------
	if self.patrolState.mode == "Waiting" then
		-- temps d'attente terminé → nouvelle destination
		if os.clock() >= self.patrolState.waitEndTime then
			local offset = Vector3.new(
				math.random(-radius, radius),
				0,
				math.random(-radius, radius)
			)

			self.patrolState.target = self.Root.Position + offset
			self.patrolState.mode = "Moving"

			self:ChangeState("Walk")
		else
			-- rester idle
			self:ChangeState("Idle")
		end

		return Status.RUNNING
	end

	---------------------------------------------------
	-- MODE : MOVING (pathfinding)
	---------------------------------------------------
	if self.patrolState.mode == "Moving" then
		local status = self:Follow(self.patrolState.target, 10)

		-- arrivé ou échec → pause
		if status == Status.SUCCESS or status == Status.FAILURE then
			self.patrolState = {
				mode = "Waiting",
				radius = radius,
				waitEndTime = os.clock() + math.random(2, 5)
			}
			self:ChangeState("Idle")
		end

		return Status.RUNNING
	end

	return Status.RUNNING
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

	-- pas de tir pendant reload
	if self.isReloading then
		return Status.FAILURE
	end

	-- =========================
	-- PHASE 1 : TIR EN COURS
	-- =========================
	if self.isRangedAttacking then
		if os.clock() >= self.attackEndTime then
			self.isRangedAttacking = false
			self.rangedDidShoot = false
			self:ChangeState("Idle")
			return Status.SUCCESS
		end
		return Status.RUNNING
	end

	-- =========================
	-- PHASE 2 : VISÉE (WIND-UP)
	-- =========================
	if self.isAiming then
		-- rotation continue vers la cible
		local lookPos = Vector3.new(
			target.Root.Position.X,
			self.Root.Position.Y,
			target.Root.Position.Z
		)
		self.Root.CFrame = CFrame.lookAt(self.Root.Position, lookPos)

		if os.clock() >= self.aimEndTime then
			-- fin de visée → on tire
			self.isAiming = false
			self.isRangedAttacking = true

			self.attackEndTime = os.clock() + self.rangedAttackDuration
			self.nextRangedTime = os.clock() + self.rangedCooldown
			self.ammoInMag -= 1

			--Amélioration, refait un raycast avant de tirer
			--TEMP POUR TEST
			local att1 = Instance.new("Attachment")
			att1.Parent = self.Model:WaitForChild("Backpack")
			local att2 = Instance.new("Attachment")
			att2.Parent = target.Root
			local beam = Instance.new("Beam")
			beam.Attachment0 = att1
			beam.Attachment1 = att2
			beam.Parent = self.Root
			Debris:AddItem(att1, 0.2)
			Debris:AddItem(att2, 0.2)
			Debris:AddItem(beam, 0.2)

			--TEMP POUR TEST
			self:ChangeState("AttackArme")
			target:RemoveHealth(self.rangedAttackDamage)

			print("[SHOT] Tir après visée")
		end

		return Status.RUNNING
	end

	-- =========================
	-- PHASE 0 : CONDITIONS
	-- =========================
	local origin = self.Root.Position
	local targetPos = target.Root.Position
	local toTarget = targetPos - origin
	

	if os.clock() < (self.nextRangedTime or 0) then
		return Status.FAILURE
	end

	if (self.ammoInMag or 0) <= 0 then
		return Status.FAILURE
	end

	-- Raycast ligne de vue
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { self.Model }

	local result = workspace:Raycast(origin, toTarget, params)
	if not result or not result.Instance:IsDescendantOf(target.Model) then
		return Status.FAILURE
	end

	-- =========================
	-- DÉBUT VISÉE
	-- =========================
	self:StopMove()

	self.isAiming = true
	self.aimEndTime = os.clock() + self.aimDuration
	self:ChangeState("Aim")

	print("[AIM] Début de la visée")

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

--===========================================================
-- Méthodes spécifiques à la creation de piège 
--===========================================================
local Trap = require(script.Parent.Objets.Trap)

function Hunter:TryPlaceTrap()
	if not self.Root then
		return false
	end

	self._nextTrapTime = self._nextTrapTime or 0
	if os.clock() < self._nextTrapTime then
		return false
	end
	self._nextTrapTime = os.clock() + 2 -- cooldown entre chaque piège

	-- Position: aux pieds du chasseur (simple)
	local position = self.Root.Position - Vector3.new(0, self.Root.Size.Y * 0.5, 0)
	
	if (self.trapsStock or 0) <= 0 then
		return false
	end

	local trap = Trap.new(self, position)

	self.trapsStock -= 1
	print(string.format("[TRAP] posé | stock=%d/%d", self.trapsStock, self.trapsStockMax))


	self.ActiveTraps = self.ActiveTraps or {}
	table.insert(self.ActiveTraps, trap)
	print("[TRAP] Piège posé à", position)
	return true
end






return Hunter