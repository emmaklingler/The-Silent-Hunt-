local RabbitBot = {}
RabbitBot.__index = RabbitBot

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Status = require(game.ServerScriptService.BehaviourTree.Node.Utiles.Status)
local SoundManager = require(game.ServerScriptService.Sound.SoundManager)
local RabbitBT = require(game.ServerScriptService.RabbitBot.RabbitBT)
local NoiseServerEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("NoiseServerEvent")
local ChangeStateRabbitEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateRabbitEvent")

function RabbitBot.spawn()
    local botNames = {"Floppy", "Caramel", "Noisette", "Pepper", "Mochi", "Biscuit", "Cannelle", "Peanut", "Coco", "Hazel"}

    -- =========================
    -- RÉCUP TEMPLATE
    -- =========================
    local template = game.ServerStorage:WaitForChild("Asset"):WaitForChild("rabbitbot")

    -- =========================
    -- CLONE
    -- =========================
    local model = template:Clone()
    model.Name = botNames[math.random(1, #botNames)]
    model.Parent = workspace

    -- =========================
    -- POSITION SPAWN
    -- =========================
    local spawnFolder = workspace:FindFirstChild("PlayerSpawn")
    if spawnFolder then
        local spawnPoints = spawnFolder:GetChildren()
        if #spawnPoints > 0 then
            local spawnPoint = spawnPoints[math.random(1, #spawnPoints)]
            model:PivotTo(spawnPoint.CFrame + Vector3.new(0,5,0))
        end
    end

    -- =========================
    -- CRÉATION OBJET
    -- =========================
    local self = setmetatable({}, RabbitBot)

    self.Model = model
    self.Humanoid = model:WaitForChild("Humanoid")
    self.Root = model:WaitForChild("HumanoidRootPart")

    pcall(function() self.Root:SetNetworkOwner(nil) end)
    self.Humanoid.AutoRotate = true

    -- =========================
    -- STATS
    -- =========================
    self.MaxHealth = 100
    self.Health = self.MaxHealth
    self.Satiety = math.random(30, 90)
    self.Stress = 0

    -- =========================
    -- PARAMÈTRES IA
    -- =========================
    self.panicRadius = 150
    self.fleeDistance = 80
    self.fleeSpeed = 18
    self.normalSpeed = 16
    self.fleeDuration = 3

    -- =========================
    -- ÉTATS
    -- =========================
    self.state = "Idle"
    self.fleeState = nil
    self.jumpCooldown = 0
    self.jumpForce = 60
    self.upForce = 35

    -- =========================
    -- PATHFINDING
    -- =========================
    self.pathState = nil
    self.lastPathCompute = 0

    -- =========================
    -- START IA
    -- =========================
    RabbitBT.Start(self)

    return self
end

local function GetFirstValidWaypoint(root, waypoints)
    for i, wp in ipairs(waypoints) do
        local dir = (wp.Position - root.Position)
        if dir.Magnitude >= 4 then
            local dot = root.CFrame.LookVector:Dot(dir.Unit)
            if dot > 0 then
                return i
            end
        end
    end
    return 1
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

    local groundedTarget = Vector3.new(
        targetPosition.X,
        self.Root.Position.Y,
        targetPosition.Z
    )

    local path = PathfindingService:CreatePath({
        AgentRadius = 4,
        AgentHeight = 10,   -- ← augmenter (était 6)
        AgentCanJump = false,
        WaypointSpacing = 8, -- ← même que le chasseur (était 6)
    })

    path:ComputeAsync(self.Root.Position, groundedTarget)

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
        if os.clock() - self.lastPathCompute < 0.7 then
            return Status.RUNNING
        end

        local waypoints = self:ComputePath(position)
        if not waypoints or #waypoints == 0 then
            return Status.FAILURE
        end

        local firstIndex = GetFirstValidWaypoint(self.Root, waypoints)

        self.pathState = {
            waypoints = waypoints,
            index = firstIndex,
            target = position,
            startTime = os.clock(),
            timeout = timeout,
        }

        self:ChangeState("Running")
        self.Humanoid:MoveTo(waypoints[firstIndex].Position)
     

        return Status.RUNNING
        
    end

    -- BRUIT émis pendant le déplacement (toutes les 2s)
    if not self._nextNoiseTime or os.clock() > self._nextNoiseTime then
        NoiseServerEvent:Fire({
            position = self.Root.Position,
            intensity = 1,
            time = os.clock(),
            source = nil
        })
        self._nextNoiseTime = os.clock() + 2
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

        local next = self.pathState.waypoints[self.pathState.index]
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

    for _, carrot in carrotFolder:GetChildren() do
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

    -- Si fuite déjà en cours → on continue SANS toucher au pathfinding
    if self.fleeState then
        if os.clock() >= self.fleeState.endTime then
            self.fleeState = nil
            self.Humanoid.WalkSpeed = self.normalSpeed
            self:ChangeState("Idle")
            return Status.SUCCESS
        end
        return Status.RUNNING
    end

    -- StopMove seulement au DÉBUT de la fuite
    self:StopMove(false)

    local awayDir = (self.Root.Position - hunterPosition).Unit
    local fleeTarget = (self.Root.Position + awayDir * self.fleeDistance)

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

    local flatDist = (
        Vector3.new(self.Root.Position.X, 0, self.Root.Position.Z) -
        Vector3.new(carrot.Position.X, 0, carrot.Position.Z)
    ).Magnitude

    if flatDist <= 4 then
        self:ActionEat(carrot)
        return Status.SUCCESS
    end

    return self:Follow(carrot.Position, 10)
end

function RabbitBot:IsAlive()
    return self.Health > 0
end


function RabbitBot:DansCachette()
    return false  
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
    if self.pathState then
        return self:Follow(self.pathState.target)
    end

    -- Plusieurs tentatives pour trouver une destination valide
    for _ = 1, 5 do
        local offset = Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
        local dest = Vector3.new(
            self.Root.Position.X + offset.X,
            self.Root.Position.Y,  -- ← même hauteur que le lapin
            self.Root.Position.Z + offset.Z
        )

        local result = self:Follow(dest, 8)
        if result ~= Status.FAILURE then
            return result
        end
        -- Si FAILURE → on reset et on réessaie avec une autre destination
        self.pathState = nil
        self.lastPathCompute = 0
    end

    -- Toutes les tentatives ont échoué → on attend
    return Status.RUNNING
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
        if hitModel ~= hunterRoot.Parent then
            return false
        end
    end

    -- Fuite immédiate sans attendre le BT
    if not self.fleeState then
        self:TryFlee(hunterRoot.Position)
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
function RabbitBot:RemoveHealth(amount)
    self.Health = math.max(0, self.Health - amount)
    
    -- Force la fuite si pas déjà en train de fuir
    if self.Health > 0 and not self.fleeState then
        local hunter = workspace:FindFirstChild("Chasseur_Test")
        if hunter and hunter:FindFirstChild("HumanoidRootPart") then
            self:TryFlee(hunter.HumanoidRootPart.Position)
        end
    end

    if self.Health <= 0 then
        self.Health = 0
        self.Model:Destroy()
    end
end

function RabbitBot:IsGrounded()
    return self.Humanoid.FloorMaterial ~= Enum.Material.Air
end

return RabbitBot