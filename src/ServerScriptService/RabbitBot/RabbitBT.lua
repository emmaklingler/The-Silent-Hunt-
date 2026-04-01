local RabbitBT = {}
RabbitBT.__index = RabbitBT

local RunService = game:GetService("RunService")

function RabbitBT.new(rabbit)
    local self = setmetatable({}, RabbitBT)
    self.rabbit = rabbit
    self.connection = nil
    self.nextMoveTime = 0
    self.isMoving = false -- Nouvelle variable pour suivre le trajet
    return self
end

function RabbitBT:Start()
    -- On écoute quand l'Humanoid finit SON trajet (atteint la destination)
    self.rabbit.Humanoid.MoveToFinished:Connect(function(reached)
        self.isMoving = false
        if self.rabbit.state ~= "Jumping" then
            self.rabbit:ChangeState("Idle")
        end
    end)

    self.connection = RunService.Heartbeat:Connect(function()
        if not self.rabbit or not self.rabbit.Root or not self.rabbit.Model.Parent then 
            if self.connection then self.connection:Disconnect() end
            return 
        end

        local hunterModel = workspace:FindFirstChild("Chasseur_Test")

        -- 1. DETECTION HUNTER (PRIORITÉ)
        if hunterModel then
            local hunterRoot = hunterModel:FindFirstChild("HumanoidRootPart")
            if hunterRoot and self.rabbit:CanSeeHunter(hunterRoot) then
                self.isMoving = true -- On est en mouvement (fuite)
                self.rabbit:TryFlee(hunterRoot.Position)
                self.nextMoveTime = os.clock() + 2 
                return 
            end
        end

        -- 2. COMPORTEMENT NORMAL (WANDER)
        if os.clock() >= self.nextMoveTime then
            -- On ne relance un Wander que si on n'est pas déjà en train de bouger
            if not self.isMoving then
                self.nextMoveTime = os.clock() + math.random(4, 8)
                
                local randomOffset = Vector3.new(
                    math.random(-40, 40),
                    0,
                    math.random(-40, 40)
                )

                local target = self.rabbit.Root.Position + randomOffset
                
                self.isMoving = true -- On marque le début du trajet
                self.rabbit.Humanoid.WalkSpeed = self.rabbit.normalSpeed
                self.rabbit.Humanoid:MoveTo(target)
                self.rabbit:ChangeState("Running")
            end
        end
        
        -- Sécurité : si on est en "Idle" mais qu'on bouge encore physiquement (ex: poussé par un choc)
        if self.rabbit.Humanoid.MoveDirection.Magnitude > 0.1 and self.rabbit.state == "Idle" then
            self.rabbit:ChangeState("Running")
        end
    end)
end

return RabbitBT