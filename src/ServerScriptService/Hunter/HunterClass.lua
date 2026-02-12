local Hunter = {}
Hunter.__index = Hunter

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local ServerStorage = game:GetService("ServerStorage")
local Trap = require(script.Parent:WaitForChild("Objets"):WaitForChild("Trap"))

local ChangeStateHunterEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateHunterEvent")

local Status = require(game.ServerScriptService.BehaviourTree.Node.Utiles.Status)
local Debug = require(game.ServerScriptService.Game.Debug)
local SoundManager = require(game.ServerScriptService.Sound.SoundManager)

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
	self.attackDuration = 0.5

	-- =============================
	-- Paramètres d'attaque à distance
	-- =============================
	self.rangedAttackDamage = 25

	self.rangedRange = 100
	self.rangedContext = nil
	-- Timing tir
	self.rangedCooldown = 2
	self.rangedAttackDuration = 0.5

	self.isAiming = false
	self.aimEndTime = 0
	self.aimDuration = 1

	-- =============================
	-- Munitions
	-- =============================
	self.magSize = 5 -- pour test
	self.ammoInMag = self.magSize

	self.maxAmmoReserve = 3
	self.ammoReserve = self.maxAmmoReserve

	-- =============================
	-- Reload
	-- =============================
	self.reloadDuration = 2
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
	@param anim: boolean - si true, change l'état en "Idle"
]]
function Hunter:StopMove(anim:true)
	self.moveState = nil
	self.patrolState = nil
	self.pathState = nil
	self.Humanoid:Move(Vector3.zero)
	if not anim then return end
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
		WaypointSpacing = 8, 
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

		if os.clock() - self.lastPathCompute < 0.1 then
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
        self:StopMove(false)
        return Status.RUNNING
    end

	-- TIMEOUT
    if os.clock() - self.pathState.startTime > self.pathState.timeout then
        self:StopMove()
        return Status.FAILURE
    end

	local waypoint = self.pathState.waypoints[self.pathState.index]

    -- ATTEINT LE WAYPOINT
	local distanceToWaypoint =(Vector3.new(self.Root.Position.X, 0, self.Root.Position.Z) - 
                      Vector3.new(waypoint.Position.X, 0, waypoint.Position.Z)).Magnitude
    if distanceToWaypoint < 4 then	
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
	Patrouille dans une zone définie
	@param center: Vector3 - centre de la zone
	@param radius: number - rayon de patrouille
]]
function Hunter:PatrolZone(center, radius)
	radius = radius or 40

	-- init
	if not self.patrolState then
		self.patrolState = {
			mode = "Waiting",
			center = center,
			radius = radius,
			waitEndTime = os.clock() + math.random(0, 1)
		}

		self:ChangeState("Idle")
		return Status.RUNNING
	end

	---------------------------------------------------
	-- MODE : WAITING
	---------------------------------------------------
	if self.patrolState.mode == "Waiting" then
		if os.clock() >= self.patrolState.waitEndTime then
			local offset = Vector3.new(
				math.random(-radius, radius),
				0,
				math.random(-radius, radius)
			)
			
			self.patrolState.target = center + offset -- center
			self.patrolState.mode = "Moving"

			self:ChangeState("Walk")
		else
			self:ChangeState("LookAround")
		end

		return Status.RUNNING
	end

	---------------------------------------------------
	-- MODE : MOVING
	---------------------------------------------------
	if self.patrolState.mode == "Moving" then
		local status = self:Follow(self.patrolState.target, 10)

		-- arrivé ou échec → pause
		if status == Status.SUCCESS or status == Status.FAILURE then
			self.patrolState = {
				mode = "Waiting",
				center = center,
				radius = radius,
				waitEndTime = os.clock() + math.random(2, 5)
			}
			self:ChangeState("LookAround")
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
	if self.state == state then return end
	Debug.Print("[State] "..self.state .. " -> " .. state)
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
			Debug.Print(string.format("[RELOAD] Terminé -> chargeur=%d/%d | réserve=%d",
				self.ammoInMag, self.magSize, self.ammoReserve
			))

			return Status.SUCCESS
		end

		return Status.RUNNING
	end

	-- Conditions pour démarrer
	if not self:CanReload() then
		Debug.Print(string.format("[RELOAD] Impossible -> chargeur=%d/%d | réserve=%d",
			self.ammoInMag, self.magSize, self.ammoReserve
		))
		return Status.FAILURE
	end

	-- Start reload
	
	self.isReloading = true
	self.reloadEndTime = os.clock() + self.reloadDuration

	self:ChangeState("Reload")
	SoundManager.playSound(nil, self.Root.Position, SoundManager.SoundId.Reload, 1)
	Debug.Print(string.format("[RELOAD] Début -> chargeur=%d/%d | réserve=%d (%.1fs)",
		self.ammoInMag, self.magSize, self.ammoReserve, self.reloadDuration
	))

	return Status.RUNNING
end

--[[
    Attaque d'une cible à distance (simulation munitions + reload)
    @param target: RabbitClass - la cible à attaquer
]]
function Hunter:TryRangedAttack(target)
	
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
		local ctx = self.rangedContext

		-- Mise à jour dynamique de la visée
		if target and typeof(target) ~= "Vector3" and target.Root then
			ctx.lastKnownPosition = target.Root.Position
		end

		local aimDir = (ctx.lastKnownPosition - self.Root.Position)
		if aimDir.Magnitude > 0 then
			ctx.aimDirection = aimDir.Unit
		end

		-- rotation visuelle
		local lookPos = self.Root.Position + Vector3.new(
			ctx.aimDirection.X,
			0,
			ctx.aimDirection.Z
		)
		self.Root.CFrame = CFrame.lookAt(self.Root.Position, lookPos)

		if os.clock() >= self.aimEndTime then
			-- passage au tir
			self.isAiming = false
			self.isRangedAttacking = true

			self.attackEndTime = os.clock() + self.rangedAttackDuration
			self.nextRangedTime = os.clock() + self.rangedCooldown
			self.ammoInMag -= 1

			-- Raycast FINAL
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { self.Model }

			local result = workspace:Raycast(
				self.Root.Position,
				ctx.aimDirection * self.rangedRange,
				params
			)

			if result then
				local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
				if hitModel == ctx.targetModel and target and typeof(target) ~= "Vector3" then
					target:RemoveHealth(self.rangedAttackDamage)
					Debug.Print("[SHOT] Touché")
				else
					Debug.Print("[SHOT] Obstacle")
				end
			end

			self:ChangeState("Shoot")
			SoundManager.playSound(nil, self.Root.Position, SoundManager.SoundId.Shoot, 3)

			-- effet visuel tir (particule, son, etc.) à ajouter ici
			ReplicatedStorage.Remote.VFXEvent:FireAllClients({
				type = "Shoot",
				origin = self.Model.FusilUp.Attachment,
				hitPosition = result and result.Position or (self.Root.Position + ctx.aimDirection * self.rangedRange)
			})

		end

		return Status.RUNNING
	end

	-- =========================
	-- PHASE 0 : CONDITIONS
	-- =========================
	if not target or not target.Root then
		return Status.FAILURE
	end

	if os.clock() < (self.nextRangedTime or 0) then
		return Status.FAILURE
	end

	if (self.ammoInMag or 0) <= 0 then
		return Status.FAILURE
	end

	-- =========================
	-- DÉBUT VISÉE
	-- =========================
	self:StopMove()

	self.isAiming = true
	self.aimEndTime = os.clock() + self.aimDuration

	self.rangedContext = {
		aimDirection = Vector3.zero,
		targetModel = target.Model,
		lastKnownPosition = target.Root.Position,
	}

	self:ChangeState("Aim")
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
	Debug.Print(string.format("[REFILL] réserve=%d | chargeur=%d/%d",
		self.ammoReserve, self.ammoInMag, self.magSize
	))

	return true
end
function Hunter:TryPlaceTrapAt(position)
	if not self.Root or not position then return false end

	-- cooldown
	self._nextTrapTime = self._nextTrapTime or 0
	if os.clock() < self._nextTrapTime then return false end
	self._nextTrapTime = os.clock() + 2

	-- stock
	if (self.trapsStock or 0) <= 0 then return false end

	self.ActiveTraps = self.ActiveTraps or {}

	--------------------------------------------------------
	-- Projection au sol
	--------------------------------------------------------
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {
		self.Model,
		workspace:FindFirstChild("Traps")
	}

	local origin = position + Vector3.new(0, 50, 0)
	local result = workspace:Raycast(origin, Vector3.new(0, -200, 0), rayParams)

	if not result then return false end
	if result.Normal.Y < 0.85 then return false end

	local drop = origin.Y - result.Position.Y
	if drop > 140 then return false end

	position = result.Position

	--------------------------------------------------------
	-- Pas deux pièges trop proches (XZ)
	--------------------------------------------------------
	local MIN_DIST = 14
	local pos2D = Vector3.new(position.X, 0, position.Z)

	for i = #self.ActiveTraps, 1, -1 do
		local trap = self.ActiveTraps[i]
		if not trap or not trap.Model or not trap.Model.Parent then
			table.remove(self.ActiveTraps, i)
		else
			local tpos = trap.Model:GetPivot().Position
			local tpos2D = Vector3.new(tpos.X, 0, tpos.Z)
			if (tpos2D - pos2D).Magnitude < MIN_DIST then
				return false
			end
		end
	end

	--------------------------------------------------------
	-- Création
	--------------------------------------------------------
	local trap = Trap.new(self, position)

	self.trapsStock -= 1
	table.insert(self.ActiveTraps, trap)

	return true
end


return Hunter

--[[
animation bug, son bug
Attaque pied bug

Amélioration timout follow, en fonction du temps entre deux points a la place du temps total donc plus petit

- ajout fatigue / stress et autre pour le chasseur
- erreur de tire en fonction 
- erreur de vision pareille / Si il hesite affiche ?, si il trouve affiche !

- Arrete de bouger si lapin proche
- Si lapin proche soit le tue soit l'attaque simplement 

Certaines fois bug reste bloqué sur le dernier waypoint je pense et ensuite change d'état plein de fois d'affiler
  15:03:48.013  [DEBUG]: [State] Shoot -> Idle SRC : ServerScriptService.Hunter.HunterClass  -  Server - Debug:9
  15:03:48.177  [DEBUG]: [State] Idle -> Walk SRC : ServerScriptService.Hunter.HunterClass  -  Server - Debug:9

  15:04:08.960  [DEBUG]: [State] Walk -> Idle SRC : ServerScriptService.Hunter.HunterClass  -  Server - Debug:9
  15:04:08.977  [DEBUG]: [State] Idle -> Walk SRC : ServerScriptService.Hunter.HunterClass  -  Server - Debug:9
  15:04:09.011  [DEBUG]: [State] Walk -> Idle SRC : ServerScriptService.Hunter.HunterClass  -  Server - Debug:9
  15:04:09.028  [DEBUG]: [State] Idle -> Walk SRC : ServerScriptService.Hunter.HunterClass  -  Server - Debug:9
  
  15:04:11.661  [DEBUG]: [State] Walk -> Idle SRC : ServerScriptService.Hunter.HunterClass  -  Server - Debug:9
  15:04:14.678  [DEBUG]: [State] Idle -> Walk SRC : ServerScriptService.Hunter.HunterClass  -  Server - Debug:9
  15:04:16.278  [DEBUG]: [State] Walk -> Aim SRC : ServerScriptService.Hunter.HunterClass  -  Server - Debug:9
]]