local RabbitBot = {}
RabbitBot.__index = RabbitBot

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Status = require(game.ServerScriptService.BehaviourTree.Node.Utiles.Status)
local SoundManager = require(game.ServerScriptService.Sound.SoundManager)
-- On récupère l'event pour les animations
local ChangeStateRabbitEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateRabbitEvent")

function RabbitBot.new(model)
    local self = setmetatable({}, RabbitBot)

    self.Model = model
    self.Humanoid = model:WaitForChild("Humanoid")
    self.Root = model:WaitForChild("HumanoidRootPart")

    -- =============================
    -- FIX PHYSIQUE ET RESEAU
    -- =============================
    -- On s'assure que le serveur gère la physique pour éviter les saccades
    local success, err = pcall(function()
        self.Root:SetNetworkOwner(nil)
    end)
    
    -- Empêche le bot de "coller" au sol (ajuste la valeur selon la taille du modèle)
    self.Humanoid.HipHeight = 1.2 
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
    self.jumpForce = 60 -- Un peu réduit pour plus de réalisme
    self.upForce = 35

    return self
end

function RabbitBot:TryFlee(hunterPosition)
    if not self.Root or not hunterPosition then
        return Status.FAILURE
    end

    if self.fleeState then
        if math.random() < 0.08 then
            self:Jump()
        end

        if os.clock() >= self.fleeState.endTime then
            self.fleeState = nil
            self.Humanoid.WalkSpeed = self.normalSpeed
            self:ChangeState("Idle")
            return Status.SUCCESS
        end
        return Status.RUNNING
    end

    local direction = (self.Root.Position - hunterPosition)
    if direction.Magnitude == 0 then return Status.FAILURE end

    direction = direction.Unit
    local fleeTarget = self.Root.Position + direction * self.fleeDistance

    self.fleeState = {
        endTime = os.clock() + self.fleeDuration
    }

    self.Humanoid.WalkSpeed = self.fleeSpeed
    self.Humanoid:MoveTo(fleeTarget)
    self:ChangeState("Running") -- "Running" au lieu de "Flee" pour correspondre aux anims

    self:Jump()
    return Status.RUNNING
end

function RabbitBot:ChangeState(state)
    if self.state == state then return end
    self.state = state
    
    -- On prévient tous les clients que CE bot change d'état
    ChangeStateRabbitEvent:FireAllClients(self.Model, state)
end

function RabbitBot:IsGrounded()
    return self.Humanoid.FloorMaterial ~= Enum.Material.Air
end

-- À ajouter dans ton fichier RabbitBot.lua actuel

-- Scanne le dossier CarrotSpawn et trouve la carotte la plus proche
function RabbitBot:GetNearestCarrot()
    local spawnsFolder = workspace:FindFirstChild("CarrotSpawn")
    if not spawnsFolder then return nil end

    local closestCarrot = nil
    local shortestDistance = math.huge

    -- On boucle sur les enfants du dossier uniquement
    for _, child in ipairs(spawnsFolder:GetChildren()) do
        -- On vérifie que c'est bien une Part et pas le dossier lui-même
        if child:IsA("BasePart") then
            local distance = (self.Root.Position - child.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestCarrot = child -- C'est bien la carotte individuelle ici
            end
        end
    end

    return closestCarrot
end
function RabbitBot:Follow(targetPosition)
    if not targetPosition then return Status.FAILURE end

    -- 1. ORDRE PHYSIQUE
    self.Humanoid:MoveTo(targetPosition)
    
    -- 2. ORDRE D'ANIMATION (Le remède à la glissade)
    -- On vérifie si le lapin est censé bouger
    if (targetPosition - self.Root.Position).Magnitude > 2 then
        self:ChangeState("Running")
    end

    -- 3. VÉRIFICATION D'ARRIVÉE
    -- Si le lapin s'arrête de lui-même (cible atteinte)
    if self.Humanoid.MoveDirection.Magnitude == 0 then
        self:ChangeState("Idle")
        return Status.SUCCESS
    end

    return Status.RUNNING
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
    
    -- Retour à l'état précédent après le saut
    task.delay(0.8, function()
        if self.Humanoid.MoveDirection.Magnitude > 0 then
            self:ChangeState("Running")
        else
            self:ChangeState("Idle")
        end
    end)
end


function RabbitBot:ActionEat(carrotPart)
    if not carrotPart or not carrotPart.Parent then return false end

    -- On force l'arrêt des pattes
    self:ChangeState("Idle")

    -- On appelle la logique de destruction définie dans le gestionnaire
    if _G.BotEatCarrot then
        _G.BotEatCarrot(self, carrotPart)
    else
        -- Backup si _G n'est pas encore chargé
        carrotPart:Destroy()
        self.Satiety = 100
    end

    print("🐰 [MIAM] Le lapin a fini de manger.")
    return true
end



function RabbitBot:CanSeeHunter(hunterRoot)
    if not hunterRoot or not self.Root then return false end

    local direction = (hunterRoot.Position - self.Root.Position)
    local distance = direction.Magnitude

    if distance > self.panicRadius then return false end

    -- Raycast pour vérifier les murs
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

return RabbitBot