local HasLastSeenPosition = {}
HasLastSeenPosition.__index = HasLastSeenPosition
local Status = require(script.Parent.Parent.Utiles.Status)

function HasLastSeenPosition.new(distanceMin, distanceMax)
    local self = setmetatable({}, HasLastSeenPosition)
    return self
end

--[[
    Noeud HasLastSeenPosition: vérifie si le chasseur à une position mémorisée
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si une position mémorisée est présente, sinon Status.FAILURE
]]

function HasLastSeenPosition:Run(hunter, blackboard)
	if blackboard:HasMemory() and not blackboard:HasValidTarget() then
		return Status.SUCCESS
	end
	return Status.FAILURE
end

return HasLastSeenPosition