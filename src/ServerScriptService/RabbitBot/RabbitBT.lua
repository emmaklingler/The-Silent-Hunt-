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

        -- Toutes les 3 secondes on change de destination
        if os.clock() >= self.nextMoveTime then
            self.nextMoveTime = os.clock() + 3

            local randomOffset = Vector3.new(
                math.random(-50,50),
                0,
                math.random(-50,50)
            )

            local target = self.rabbit.Root.Position + randomOffset

            print("🐰 Rabbit moving to:", target)
            
            self.rabbit.Humanoid:MoveTo(target)
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
