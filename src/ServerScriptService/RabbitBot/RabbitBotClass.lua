local RabbitBot = {}
RabbitBot.__index = RabbitBot

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Status = require(game.ServerScriptService.BehaviourTree.Node.Utiles.Status)
local SoundManager = require(game.ServerScriptService.Sound.SoundManager)

local ChangeStateRabbitEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateRabbitEvent")

function RabbitBot.new(model)
    local self = setmetatable({}, RabbitBot)

    self.Model = model
    self.Humanoid = model:WaitForChild("Humanoid")
    self.Root = model:WaitForChild("HumanoidRootPart")

    pcall(function() self.Root:SetNetworkOwner(nil) end)
    self.Humanoid.AutoRotate = true

    -- Stats vitales
    self.MaxHealth = 100
    self.Health = self.MaxHealth
    self.Satiety = 100
    self.Stress = 0

    -- Paramètres IA
    self.panicRadius = 60
    self.fleeDistance = 80
    self.fleeSpeed = 28
    self.normalSpeed = 16
    self.fleeDuration = 3

    -- États internes
    self.state = "Idle"
    self.fleeState = nil
    self.jumpCooldown = 0
    self.jumpForce = 60
    self.upForce = 35

    -- Pathfinding
    self.pathState = nil
    self.lastPathCompute = 0

    -- Cache des spawn points de carottes
    self._carrotSpawnPoints = {}
    self:_LoadCarrotSpawnPoints()

    return self
end

-- =====================================================
-- SPAWN POINTS
-- =====================================================

function RabbitBot:_LoadCarrotSpawnPoints()
    local spawnFolder = workspace:FindFirstChild("CarrotSpawn")
    if not spawnFolder then
        warn("[RabbitBot] Folder 'CarrotSpawn' introuvable dans le Workspace.")
        return
    end

    for _, part in ipairs(spawnFolder:GetChildren()) do
        if part:IsA("BasePart") or part:IsA("Model") then
            local pos = part:IsA("Model") and part:GetPivot().Position or part.Position
            table.insert(self._carrotSpawnPoints, pos)
        end
    end

    print(string.format("[RabbitBot] %d spawn points de carottes mémorisés.", #self._carrotSpawnPoints))
end

-- =====================================================
-- PATHFINDING
-- =====================================================

--[[
    Calcule un chemin vers une position cible.
    @param targetPosition: Vector3
    @return table|nil - waypoints ou nil si échec
]]
function RabbitBot:ComputePath(targetPosition)
    self.lastPathCompute = os.clock()

    local path = PathfindingService:CreatePath({
        AgentRadius = 4,
        AgentHeight = 6,
        AgentCanJump = true,
        WaypointSpacing = 6,
    })

    path:ComputeAsync(self.Root.Position, targetPosition)

    if path.Status ~= Enum.PathStatus.Success then
        return nil
    end

    return path:GetWaypoints()
end

--[[
    Déplace le lapin vers une position en suivant un chemin calculé.
    @param position: Vector3 - destination
    @param timeout: number - durée max avant FAILURE (défaut: 8)
    @return Status
]]
function RabbitBot:Follow(position, timeout)
    timeout = timeout or 8

    if not position then
        self:StopMove()
        return Status.FAILURE
    end

    -- Démarrage du pathfinding
    if not self.pathState then

        if os.clock() - self.lastPathCompute < 0.1 then
            return Status.RUNNING
        end

        local waypoints = self:ComputePath(position)
        if not waypoints or #waypoints == 0 then
            return Status.FAILURE
        end

        self.pathState = {
            waypoints = waypoints,
            index = 1,
            target = position,
            startTime = os.clock(),
            timeout = timeout,
        }

        self:ChangeState("Running")
        self.Humanoid:MoveTo(waypoints[1].Position)
        return Status.RUNNING
    end

    -- La cible a bougé → recalcul
    if (self.pathState.target - position).Magnitude > 8 then
        self:StopMove(false)
        return Status.RUNNING
    end

    -- Timeout
    if os.clock() - self.pathState.startTime > self.pathState.timeout then
        self:StopMove()
        return Status.FAILURE
    end

    local waypoint = self.pathState.waypoints[self.pathState.index]

    -- Waypoint atteint
    local dist = (
        Vector3.new(self.Root.Position.X, 0, self.Root.Position.Z) -
        Vector3.new(waypoint.Position.X, 0, waypoint.Position.Z)
    ).Magnitude

    if dist < 3 then
        self.pathState.index += 1

        -- Fin du chemin
        if self.pathState.index > #self.pathState.waypoints then
            self:StopMove()
            return Status.SUCCESS
        end

        -- Gestion saut si nécessaire
        local next = self.pathState.waypoints[self.pathState.index]
        if next.Action == Enum.PathWaypointAction.Jump then
            self.Humanoid.Jump = true
        end

        self.Humanoid:MoveTo(next.Position)
    end

    return Status.RUNNING
end

--[[
    Arrête le mouvement du lapin.
    @param anim: boolean - si true, repasse en Idle (défaut: true)
]]
function RabbitBot:StopMove(anim)
    if anim == nil then anim = true end
    self.pathState = nil
    self.Humanoid:Move(Vector3.zero)
    if anim then
        self:ChangeState("Idle")
    end
end

-- =====================================================
-- DÉTECTION DES CAROTTES
-- =====================================================

function RabbitBot:GetClosestCarrot(maxDistance)
    maxDistance = maxDistance or 200

    local carrotFolder = workspace:FindFirstChild("Carrot")
    if not carrotFolder then return nil end

    local closest = nil
    local closestDist = maxDistance

    for _, carrot in ipairs(carrotFolder:GetChildren()) do
        local part = nil
        if carrot:IsA("BasePart") then
            part = carrot
        elseif carrot:IsA("Model") and carrot.PrimaryPart then
            part = carrot.PrimaryPart
        end

        if part then
            local dist = (self.Root.Position - part.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = part
            end
        end
    end

    return closest
end

-- =====================================================
-- COMPORTEMENT DE SURVIE (FUITE)
-- =====================================================

function RabbitBot:TryFlee(hunterPosition)
    if not self.Root or not hunterPosition then return Status.FAILURE end

    -- Annule tout pathfinding en cours
    self:StopMove(false)

    if self.fleeState then
        if os.clock() >= self.fleeState.endTime then
            self.fleeState = nil
            self.Humanoid.WalkSpeed = self.normalSpeed
            self:ChangeState("Idle")
            return Status.SUCCESS
        end
        return Status.RUNNING
    end

    local direction = (self.Root.Position - hunterPosition).Unit
    local fleeTarget = self.Root.Position + direction * self.fleeDistance

    self.fleeState = { endTime = os.clock() + self.fleeDuration }
    self.Humanoid.WalkSpeed = self.fleeSpeed
    self.Humanoid:MoveTo(fleeTarget)
    self:ChangeState("Running")
   

    return Status.RUNNING
end

-- =====================================================
-- GESTION DES BESOINS (MANGER)
-- =====================================================

--[[
    Se déplace vers la carotte via pathfinding et la mange en arrivant.
    @param carrot: BasePart
    @return Status
]]
function RabbitBot:GoToAndEat(carrot)
    if not carrot or not carrot.Parent then
        self:StopMove()
        return Status.FAILURE
    end

    local dist = (self.Root.Position - carrot.Position).Magnitude
    if dist <= 4 then
        self:ActionEat(carrot)
        return Status.SUCCESS
    end

    return self:Follow(carrot.Position, 10)
end

function RabbitBot:ActionEat(carrotPart)
    if not carrotPart or not carrotPart.Parent then return false end

    self:StopMove()
    self:ChangeState("Idle")

    SoundManager.playSound(nil, carrotPart.Position, SoundManager.SoundId.EatCarrot, 1)
    carrotPart:Destroy()
    self.Satiety = 100

    return true
end

-- =====================================================
-- EXPLORATION (WANDER)
-- =====================================================

--[[
    Choisit un point aléatoire et s'y déplace via pathfinding.
    @return Status
]]
function RabbitBot:Wander()
    -- Pathfinding déjà en cours → continuer
    if self.pathState then
        return self:Follow(self.pathState.target)
    end

    -- Nouvelle destination aléatoire
    local offset = Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
    local dest = self.Root.Position + offset

    return self:Follow(dest, 8)
end

-- =====================================================
-- PERCEPTION
-- =====================================================

function RabbitBot:CanSeeHunter(hunterRoot)
    if not hunterRoot or not self.Root then return false end

    local direction = hunterRoot.Position - self.Root.Position
    local distance = direction.Magnitude

    if distance > self.panicRadius then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { self.Model }

    local result = workspace:Raycast(self.Root.Position, direction.Unit * distance, params)

    if result then
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        return hitModel == hunterRoot.Parent
    end

    return true
end

-- =====================================================
-- ÉTATS ET UTILITAIRES
-- =====================================================

function RabbitBot:ChangeState(state)
    if self.state == state then return end
    self.state = state
    ChangeStateRabbitEvent:FireAllClients(self.Model, state)
end

function RabbitBot:Jump()
    if not self:IsGrounded() or os.clock() < self.jumpCooldown then return end
    self:ChangeState("Jumping")

    local hrp = self.Root
    local dir = hrp.CFrame.LookVector
    local mass = hrp.AssemblyMass

    hrp:ApplyImpulse(Vector3.new(
        dir.X * self.jumpForce * mass,
        self.upForce * mass,
        dir.Z * self.jumpForce * mass
    ))
    self.jumpCooldown = os.clock() + 1.5
end

function RabbitBot:IsGrounded()
    return self.Humanoid.FloorMaterial ~= Enum.Material.Air
end

return RabbitBot