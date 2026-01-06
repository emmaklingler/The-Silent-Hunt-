local AttackTarget = {}
AttackTarget.__index = AttackTarget
local Status = require(script.Parent.Parent.Utiles.Status)

function AttackTarget.new()
	local self = setmetatable({}, AttackTarget)
	return self
end

--[[
    Noeud AttackTarget: attaque la cible actuelle
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si l'attaque est effectuée, sinon Status.FAILURE
]]
function AttackTarget:Run(chasseur, blackboard)
	local target = blackboard.target
	if not target then
		return Status.FAILURE
	end

	local result = chasseur:TryAttack(target)

	if result == "running" then
		return Status.RUNNING
	elseif result == "finished" then
		return Status.SUCCESS
	end

	return Status.FAILURE
end

return AttackTarget 
