local RangedAttack = {}
RangedAttack.__index = RangedAttack
local Status = require(script.Parent.Parent.Utiles.Status)

function RangedAttack.new()
	return setmetatable({}, RangedAttack)
end

--[[
    Noeud RangedAttack: effectue une attaque à distance sur la cible actuelle
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si le tir est terminé,
            Status.RUNNING si tir ou rechargement en cours,
            Status.FAILURE si l'attaque ne peut pas être effectuée
]]
function RangedAttack:Run(chasseur, blackboard)
	local target = blackboard.target
	if not target then
		return Status.FAILURE
	end

	return chasseur:TryRangedAttack(target)
end

return RangedAttack
