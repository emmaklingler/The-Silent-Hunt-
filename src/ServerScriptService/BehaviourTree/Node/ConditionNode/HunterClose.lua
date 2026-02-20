local HunterClose = {}
HunterClose.__index = HunterClose

local Status = require(script.Parent.Parent.Utiles.Status)

function HunterClose.new(radius)
    local self = setmetatable({}, HunterClose)
    self.radius = radius
    return self
end
--[[
    Noeud HunterClose: vérifie si le chasseur est proche du lapin
    @param rabbit: classe du lapin
    @param blackboard: table de données partagées
    @return Status.SUCCESS si le chasseur est proche, sinon Status.FAILURE
]]
function HunterClose:Run(rabbit, blackboard)

    if not blackboard.hunterPosition then
        return Status.FAILURE
    end

    local distance = (rabbit.Root.Position - blackboard.hunterPosition).Magnitude

    if distance <= self.radius then
        return Status.SUCCESS
    end

    return Status.FAILURE
end

return HunterClose
