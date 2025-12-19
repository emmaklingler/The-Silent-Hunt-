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
    -- Si le chasseur est occupé, il ne peut pas attaquer
    if blackboard.isBusy then return Status.FAILURE end
    local target = blackboard.target
    -- Vérification de la validité de la cible
    if not target or not target.Root then return Status.FAILURE end
    print("AttackTarget")


	blackboard.isBusy = true
	chasseur:Attack(target)
    blackboard.isBusy = false

    return Status.SUCCESS
end

return AttackTarget 
