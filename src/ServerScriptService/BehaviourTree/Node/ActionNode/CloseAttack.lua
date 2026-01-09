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
	local target, type =  blackboard:GetBestTargetOrPosition()
    if type ~= "Target" then return Status.FAILURE end
    if not target then return Status.FAILURE end
	
	return chasseur:TryAttackClose(target)
end

return AttackTarget 
