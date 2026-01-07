local Patrol = {}
Patrol.__index = Patrol
local Status = require(script.Parent.Parent.Utiles.Status)

function Patrol.new()
    local self = setmetatable({}, Patrol)
    return self
end

--[[
    Noeud Patrol: effectue une patrouille aléatoire autour du chasseur.
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si la patrouille est effectuée, sinon Status.FAILURE
]]
function Patrol:Run(chasseur)
	local result = chasseur:Patrol(50)
    print("Patrol result:", result)
	
    return result
end

return Patrol