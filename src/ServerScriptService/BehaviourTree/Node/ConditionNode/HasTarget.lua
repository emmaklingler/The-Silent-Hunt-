local HasTarget = {}
HasTarget.__index = HasTarget
local Status = require(script.Parent.Parent.Utiles.Status)

function HasTarget.new(distanceMin, distanceMax)
    local self = setmetatable({}, HasTarget)
    return self
end

--[[
    Noeud HasTarget: vérifie si le chasseur à une cible
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si une cible est présente, sinon Status.FAILURE
]]

function HasTarget:Run(chasseur, blackboard)
	local target, type =  blackboard:GetBestTargetOrPosition()
    if type ~= "Target" then return Status.FAILURE end

    return Status.SUCCESS
end

return HasTarget