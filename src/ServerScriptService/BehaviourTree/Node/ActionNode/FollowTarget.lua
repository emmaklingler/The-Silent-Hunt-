local FollowTarget = {}
FollowTarget.__index = FollowTarget
local Status = require(script.Parent.Parent.Utiles.Status)

function FollowTarget.new()
	local self = setmetatable({}, FollowTarget)
	return self
end

--[[
    Noeud FollowTarget: suit une cible target
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si le suivi est effectué, sinon Status.FAILURE
]]
function FollowTarget:Run(chasseur, blackboard)
    -- Si le chasseur est occupé, il ne peut pas voir de nouvelle cible
	if blackboard.isBusy then return Status.FAILURE end
    local target = blackboard.target
    -- Vérification de la validité de la cible
    if not target or not target.Root then return Status.FAILURE end
    print("FollowTarget")

    blackboard.isBusy = true
    chasseur:MoveTo(target.Root.Position)
    blackboard.isBusy = false
    
	return Status.SUCCESS
end

return FollowTarget 