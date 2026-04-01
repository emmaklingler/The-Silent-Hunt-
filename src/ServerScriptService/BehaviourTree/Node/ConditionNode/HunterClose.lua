local HunterClose = {}
HunterClose.__index = HunterClose
local Status = require(script.Parent.Parent.Utiles.Status)

function HunterClose.new(radius)
    local self = setmetatable({}, HunterClose)
    self.radius = radius or 50
    return self
end

function HunterClose:Run(rabbit, blackboard)
    -- On cherche le Chasseur_Test dans le workspace
    local hunter = workspace:FindFirstChild("Chasseur_Test")
    if not hunter or not hunter:FindFirstChild("HumanoidRootPart") then return Status.FAILURE end
    
    local dist = (rabbit.Root.Position - hunter.HumanoidRootPart.Position).Magnitude
    return (dist <= self.radius) and Status.SUCCESS or Status.FAILURE
end

return HunterClose