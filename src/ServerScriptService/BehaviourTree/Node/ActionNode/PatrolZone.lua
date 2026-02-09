local PatrolZone = {}
PatrolZone.__index = PatrolZone
local Status = require(script.Parent.Parent.Utiles.Status)

function PatrolZone.new()
    local self = setmetatable({}, PatrolZone)
    return self
end

--[[
    Noeud PatrolZone: effectue une patrouille aléatoire autour du chasseur.
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si la patrouille est effectuée, sinon Status.FAILURE
]]
function PatrolZone:Run(chasseur)
	local result = chasseur:PatrolZone(chasseur.Root.Position, 50)
	
    return result
end

return PatrolZone