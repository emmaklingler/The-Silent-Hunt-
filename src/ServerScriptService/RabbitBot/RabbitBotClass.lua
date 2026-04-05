local RabbitBot = {}
RabbitBot.__index = RabbitBot

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Status = require(game.ServerScriptService.BehaviourTree.Node.Utiles.Status)
local SoundManager = require(game.ServerScriptService.Sound.SoundManager)

-- Event pour les animations
local ChangeStateRabbitEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateRabbitEvent")

function RabbitBot.new(model)
    local self = setmetatable({}, RabbitBot)

    self.Model = model
    self.Humanoid = model:WaitForChild("Humanoid")
    self.Root = model:WaitForChild("HumanoidRootPart")

    -- FIX PHYSIQUE : On s'assure que le serveur gère le bot
    local success, err = pcall(function()
        self.Root:SetNetworkOwner(nil)
    end)
    
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
    self.wanderTarget = nil 
    self.jumpCooldown = 0
    self.jumpForce = 60 
    self.upForce = 35

    return self
end

-- =====================================================
-- COMPORTEMENT DE SURVIE (FUITE)
-- =====================================================
function RabbitBot:TryFlee(hunterPosition)
    if not self.Root or not hunterPosition then return Status.FAILURE end
    
    -- Si on doit fuir, on oublie la balade en cours
    self.wanderTarget = nil

    if self.fleeState then
        if os.clock() >= self.fleeState.endTime then
            warn("🏃‍♂️ [FUITE] Terminée.")
            self.fleeState = nil
            self.Humanoid.WalkSpeed = self.normalSpeed
            self:ChangeState("Idle")
            return Status.SUCCESS
        end
        return Status.RUNNING
    end

    print("😱 [FUITE] Chasseur trop proche ! Fuite lancée.")
    local direction = (self.Root.Position - hunterPosition).Unit
    local fleeTarget = self.Root.Position + direction * self.fleeDistance

    self.fleeState = { endTime = os.clock() + self.fleeDuration }
    self.Humanoid.WalkSpeed = self.fleeSpeed
    self.Humanoid:MoveTo(fleeTarget)
    self:ChangeState("Running")
    self:Jump()

    return Status.RUNNING
end

-- =====================================================
-- GESTION DES BESOINS (MANGER)
-- =====================================================
function RabbitBot:ActionEat(carrotPart)
    if not carrotPart or not carrotPart.Parent then return false end
    
    self.wanderTarget = nil -- Stop tout mouvement
    warn("😋 [ACTION] Le lapin mange : " .. carrotPart.Name)
    
    self:ChangeState("Idle")
    self.Humanoid:MoveTo(self.Root.Position) 

    SoundManager.playSound(nil, carrotPart.Position, SoundManager.SoundId.EatCarrot, 1)
    carrotPart:Destroy()
    self.Satiety = 100
    return true
end

-- =====================================================
-- NAVIGATION ET MOUVEMENT ALEATOIRE (WANDER)
-- =====================================================
function RabbitBot:Wander()
    -- 1. Si on a déjà une cible, on gère le déplacement vers elle
    if self.wanderTarget then
        local currentPos = self.Root.Position
        local targetPos = self.wanderTarget
        
        -- Calcul de distance à plat (XZ) pour éviter les bugs de saut/hauteur
        local distance = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude

        if distance > 4 then
            -- On ne relance MoveTo QUE si le bot s'est arrêté de marcher physiquement
            if self.Humanoid.MoveDirection.Magnitude < 0.1 then
                self.Humanoid:MoveTo(self.wanderTarget)
            end
            self:ChangeState("Running")
            return Status.RUNNING
        else
            -- On est arrivé à la destination Wander
            print("📍 [WANDER] Destination atteinte.")
            self.wanderTarget = nil
            self:ChangeState("Idle")
            return Status.SUCCESS
        end
    end

    -- 2. Création d'une nouvelle cible si on n'en a pas
    local randomOffset = Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
    local newDest = self.Root.Position + randomOffset
    
    -- Sécurité : On vérifie que la cible n'est pas sur nous-même
    if (newDest - self.Root.Position).Magnitude < 10 then
        return Status.FAILURE
    end

    self.wanderTarget = newDest
    print("🎲 [WANDER] Nouvelle cible choisie.")
    
    self.Humanoid:MoveTo(self.wanderTarget)
    self:ChangeState("Running")
    return Status.RUNNING
end

-- =====================================================
-- PERCEPTION (REMISE EN PLACE POUR BLACKBOARD)
-- =====================================================
function RabbitBot:CanSeeHunter(hunterRoot)
    if not hunterRoot or not self.Root then return false end
    
    local direction = (hunterRoot.Position - self.Root.Position)
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
-- ETATS ET UTILITAIRES
-- =====================================================
function RabbitBot:ChangeState(state)
    -- VERROU CRITIQUE : Empêche le bégaiement de l'animation
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

    hrp:ApplyImpulse(Vector3.new(dir.X * self.jumpForce * mass, self.upForce * mass, dir.Z * self.jumpForce * mass))
    self.jumpCooldown = os.clock() + 1.5
end

function RabbitBot:IsGrounded()
    return self.Humanoid.FloorMaterial ~= Enum.Material.Air
end

return RabbitBot