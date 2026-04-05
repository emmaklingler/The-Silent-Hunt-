local HunterClose = {}
HunterClose.__index = HunterClose

local Status = require(script.Parent.Parent.Utiles.Status)

--[[
    Noeud HunterClose : vérifie si le chasseur est à portée ET visible (Raycast).
    Met à jour blackboard.hunterRoot si le chasseur est détecté.

    @param radius: number - rayon de détection (défaut: 60, doit correspondre à rabbit.panicRadius)
]]
function HunterClose.new(radius)
    local self = setmetatable({}, HunterClose)
    self.radius = radius or 60
    return self
end

function HunterClose:Run(rabbit, blackboard)
    local hunter = workspace:FindFirstChild("Chasseur_Test")
    if not hunter or not hunter:FindFirstChild("HumanoidRootPart") then
        blackboard.hunterRoot = nil
        return Status.FAILURE
    end

    local hunterRoot = hunter.HumanoidRootPart

    if rabbit:CanSeeHunter(hunterRoot) then
        blackboard.hunterRoot = hunterRoot
        return Status.SUCCESS
    end

    blackboard.hunterRoot = nil
    return Status.FAILURE
end

return HunterClose