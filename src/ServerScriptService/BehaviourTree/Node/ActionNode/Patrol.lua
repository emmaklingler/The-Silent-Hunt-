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
function Patrol:Run(chasseur, blackboard)
    -- Si le chasseur est occupé, il ne peut pas patrouiller
	if blackboard.isBusy then return Status.FAILURE end
	print("Patrol")
    -- Mise à jour de l'état du chasseur dans le blackboard
	blackboard.isBusy = true
	blackboard.state = "Patrol"

    -- Génération d'une position aléatoire autour du chasseur
	local randomOffset = Vector3.new(
		math.random(-20, 20),
		0,
		math.random(-20, 20)
	)

    -- Déplacement du chasseur vers la nouvelle position
	local destination = chasseur.Root.Position + randomOffset
	chasseur:MoveTo(destination)

    -- Fin de la patrouille, mise à jour du blackboard
	blackboard.isBusy = false
    return Status.SUCCESS
end

return Patrol