local RabbitBT = {}
RabbitBT.__index = RabbitBT

local RunService = game:GetService("RunService")
print("=== RABBIT BT SIMPLE LOADED ===")

function RabbitBT.new(rabbit)
    local self = setmetatable({}, RabbitBT)

    self.rabbit = rabbit
    self.connection = nil
    self.nextMoveTime = 0

    return self
end

function RabbitBT:Start()

    self.connection = RunService.Heartbeat:Connect(function()

        if not self.rabbit or not self.rabbit.Root then
            return
        end

        local hunterModel = workspace:FindFirstChild("Hunter")

        -- =========================
        -- DETECTION HUNTER
        -- =========================
        if hunterModel then
            local hunterRoot = hunterModel:FindFirstChild("HumanoidRootPart")

            if hunterRoot then
                local canSee = self.rabbit:CanSeeHunter(hunterRoot)

                if canSee then
                    print("👁️ [Rabbit] Hunter DETECTED")

                    self.rabbit.Stress = math.clamp(self.rabbit.Stress + 10, 0, 100)

                    local result = self.rabbit:TryFlee(hunterRoot.Position)

                    print("🏃 [Rabbit] Fleeing... state:", result)

                    if math.random() < 0.2 then
                        print("🐰 [Rabbit] PANIC JUMP")
                        self.rabbit:Jump()
                    end

                    return -- PRIORITÉ fuite
                else
                    -- debug vision
                    --print("👁️ [Rabbit] Hunter NOT in vision")
                end
            end
        else
            print("⚠️ [Rabbit] Hunter NOT FOUND")
        end

        -- =========================
        -- COMPORTEMENT NORMAL
        -- =========================
        if os.clock() >= self.nextMoveTime then
            self.nextMoveTime = os.clock() + 3

            local randomOffset = Vector3.new(
                math.random(-50,50),
                0,
                math.random(-50,50)
            )

            local target = self.rabbit.Root.Position + randomOffset

            print("🐰 [Rabbit] Wandering to:", target)

            -- rotation vers la cible (IMPORTANT pour FOV)
            self.rabbit.Root.CFrame = CFrame.lookAt(
                self.rabbit.Root.Position,
                target
            )

            self.rabbit.Humanoid.WalkSpeed = self.rabbit.normalSpeed
            self.rabbit.Humanoid:MoveTo(target)
        end

    end)
end