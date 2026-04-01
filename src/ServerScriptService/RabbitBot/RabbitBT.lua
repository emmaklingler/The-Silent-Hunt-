local RabbitBT = {}
RabbitBT.__index = RabbitBT

local RunService = game:GetService("RunService")

function RabbitBT.new(rabbit)
    local self = setmetatable({}, RabbitBT)
    self.rabbit = rabbit
    self.connection = nil
    self.nextMoveTime = 0
    self.isMoving = false
    self.isEating = false -- Verrou pour éviter l'hésitation (surplace)
    self.blackboard = {} 
    return self
end

function RabbitBT:Start()
    -- Écouteur de fin de trajet pour les animations
    self.rabbit.Humanoid.MoveToFinished:Connect(function(reached)
        self.isMoving = false
        -- Si on s'arrête de bouger, on repasse en Idle sauf si on saute
        if self.rabbit.state ~= "Jumping" then
            self.rabbit:ChangeState("Idle")
        end
    end)

    self.connection = RunService.Heartbeat:Connect(function()
        -- Sécurité : Vérifie si le lapin existe toujours
        if not self.rabbit or not self.rabbit.Root or not self.rabbit.Model.Parent then 
            if self.connection then self.connection:Disconnect() end
            return 
        end

        -- --- LOGIQUE DE BESOINS ---
        -- Diminue la faim doucement
        self.rabbit.Satiety = math.max(0, self.rabbit.Satiety - 0.05)

        local hunterModel = workspace:FindFirstChild("Chasseur_Test")

        -- 1. PRIORITÉ ABSOLUE : FUITE (Survie)
        -- La peur casse même l'envie de manger
        if hunterModel then
            local hunterRoot = hunterModel:FindFirstChild("HumanoidRootPart")
            if hunterRoot and self.rabbit:CanSeeHunter(hunterRoot) then
                self.isMoving = true
                self.isEating = false -- On oublie la carotte, on fuit !
                self.blackboard.closestCarrot = nil 
                
                self.rabbit:TryFlee(hunterRoot.Position)
                self.nextMoveTime = os.clock() + 2 
                return 
            end
        end

        -- 2. PRIORITÉ : CHERCHER À MANGER (Si Satiety < 50 ou déjà en train d'y aller)
        if self.rabbit.Satiety < 50 or self.isEating then
            
            -- Recherche de cible si on n'en a pas
            if not self.blackboard.closestCarrot or not self.blackboard.closestCarrot.Parent then
                self.blackboard.closestCarrot = self.rabbit:GetNearestCarrot()
            end

            local targetCarrot = self.blackboard.closestCarrot
            if targetCarrot then
                self.isEating = true -- On verrouille la priorité "Faim"
                local dist = (self.rabbit.Root.Position - targetCarrot.Position).Magnitude
                
                if dist > 5 then -- Marge de 5 pour être sûr de l'atteindre
                    if not self.isMoving then
                        self.isMoving = true
                        self.rabbit.Humanoid.WalkSpeed = self.rabbit.normalSpeed
                        self.rabbit.Humanoid:MoveTo(targetCarrot.Position)
                        self.rabbit:ChangeState("Running")
                    end
                else
                    -- ON EST ARRIVÉ : ACTION DE MANGER
                    self.isMoving = false
                    self.isEating = false -- On déverrouille
                    self.rabbit:ActionEat(targetCarrot) -- Gère le Destroy et le Son
                    self.blackboard.closestCarrot = nil 
                    self.nextMoveTime = os.clock() + 4 -- Pause digestive
                end
                return -- Bloque le Wander
            else
                self.isEating = false -- Pas de carotte trouvée, on annule le verrou
            end
        end

        -- 3. COMPORTEMENT NORMAL (WANDER)
        if os.clock() >= self.nextMoveTime then
            if not self.isMoving and not self.isEating then
                self.nextMoveTime = os.clock() + math.random(5, 10)
                
                local randomOffset = Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
                local target = self.rabbit.Root.Position + randomOffset
                
                self.isMoving = true
                self.rabbit.Humanoid.WalkSpeed = self.rabbit.normalSpeed
                self.rabbit.Humanoid:MoveTo(target)
                self.rabbit:ChangeState("Running")
            end
        end
        
        -- Sécurité animation : force le Running si le bot glisse
        if self.rabbit.Humanoid.MoveDirection.Magnitude > 0.1 and self.rabbit.state == "Idle" then
            self.rabbit:ChangeState("Running")
        end
    end)
end

function RabbitBT:Stop()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

return RabbitBT