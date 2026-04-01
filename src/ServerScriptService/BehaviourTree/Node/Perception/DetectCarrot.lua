local DetectCarrot = {}
DetectCarrot.__index = DetectCarrot

local folder = game.Workspace:WaitForChild("Carrot")

function DetectCarrot.new(radius)
    local self = setmetatable({}, DetectCarrot)
    self.radius = radius or 50
    return self
end

function DetectCarrot:Run(rabbit, blackboard)   

    for _, carrot in folder:GetChildren() do
        local dist = (rabbit.Root.Position - carrot.Position).Magnitude

        if dist < self.radius then
            blackboard:SetCarrotPosition(carrot.Position)
        end
    end
end

return DetectCarrot
