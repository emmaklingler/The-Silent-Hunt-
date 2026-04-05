local Flee = {}
Flee.__index = Flee

local Status = require(script.Parent.Parent.Utiles.Status)

--[[
    Noeud Flee : déclenche la fuite du lapin loin du chasseur.
    Utilise blackboard.hunterRoot mis à jour par UpdatePerceptionRabbit.
]]
function Flee.new()
    return setmetatable({}, Flee)
end

function Flee:Run(rabbit, blackboard)
    if not blackboard.hunterRoot then
        return Status.FAILURE
    end

    return rabbit:TryFlee(blackboard.hunterRoot.Position)
end

return Flee