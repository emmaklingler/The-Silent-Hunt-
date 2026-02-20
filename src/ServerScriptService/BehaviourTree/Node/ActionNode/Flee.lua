local Flee = {}
Flee.__index = Flee

local Status = require(script.Parent.Parent.Utiles.Status)

function Flee.new()
    return setmetatable({}, Flee)
end
--[[
    Noeud Flee: fait fuir le lapin du chasseur
    @param rabbit: classe du lapin
    @param blackboard: table de données partagées
    @return Status.SUCCESS si le lapin est en train de fuir, Status.FAILURE sinon
]]

function Flee:Run(rabbit, blackboard)

    if not blackboard.hunterPosition then
        return Status.FAILURE
    end

    return rabbit:TryFlee(blackboard.hunterPosition)
end

return Flee
