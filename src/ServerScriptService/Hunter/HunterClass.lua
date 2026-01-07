local Hunter = {}
Hunter.__index = Hunter
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeStateHunterEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateHunterEvent")
local PathfindingService = game:GetService("PathfindingService")
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
    self.attackRange = 10
    self.attackDamage = 20
    self.attackCooldown = 3
    self.attackDuration = 1.5
    self.isAttacking = false

	-- Pathfinding 
	self.pathState = nil

    -- Animation, ...
    self.state = ""
    self:ChangeState("Idle")  -- État initial du chasseur
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
    local path = PathfindingService:CreatePath({
        AgentRadius = 6,
        AgentHeight = 20,
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
        self.Humanoid:MoveTo(waypoints[1].Position)
        return Status.RUNNING
    end


	-- TARGET A BOUGÉ -> RECALCUL
    if (self.pathState.target - position).Magnitude > 5 then
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
	
	-- conditions
	local dist = (self.Root.Position - target.Root.Position).Magnitude
	if dist > self.attackRange then
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
	target:RemoveHealth(self.attackDamage)

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

return Hunter