local EatCarrot = {}
EatCarrot.__index = EatCarrot

local Status = require(script.Parent.Parent.Utiles.Status)

function EatCarrot.new()
    return setmetatable({}, EatCarrot)
end
--[[
    Noeud EatCarrot: fait manger une carotte au lapin
    @param rabbit: classe du lapin
    @param blackboard: table de données partagées
    @return Status.SUCCESS si le lapin a mangé une carotte, Status.FAILURE sinon
]]
function EatCarrot:Run(rabbit, blackboard)

    if not blackboard.closestCarrot then
        return Status.FAILURE
    end

    return rabbit:TryEatCarrot(blackboard.closestCarrot)
end

return EatCarrot
