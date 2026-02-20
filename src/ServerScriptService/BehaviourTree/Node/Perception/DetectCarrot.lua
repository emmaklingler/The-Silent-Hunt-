local DetectCarrot = {}
DetectCarrot.__index = DetectCarrot

function DetectCarrot.new(radius)
    local self = setmetatable({}, DetectCarrot)
    self.radius = radius or 50
    return self
end

function DetectCarrot:Run(rabbit, blackboard)

    for _, carrot in pairs(workspace:GetChildren()) do
        if carrot.Name == "Carrot" then
            local dist = (rabbit.Root.Position - carrot.Position).Magnitude

            if dist < self.radius then
                blackboard:SetCarrotPosition(carrot.Position)
            end
        end
    end
end

return DetectCarrot
