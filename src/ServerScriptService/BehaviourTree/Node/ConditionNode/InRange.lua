local InRange = {}
InRange.__index = InRange
local Status = require(script.Parent.Parent.Utiles.Status)

function InRange.new(distanceMin, distanceMax)
    local self = setmetatable({}, InRange)
    self.distanceMin = distanceMin -- distance minimale de détection
    self.distanceMax = distanceMax -- distance maximale de détection
    return self
end

--[[
    Noeud InRange: vérifie si le chasseur peut voir une cible proche
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si une cible est trouvée, sinon Status.FAILURE
]]

function InRange:Run(chasseur, blackboard)
    -- Si le chasseur est occupé, il ne peut pas voir de nouvelle cible
	local target, type = blackboard:GetBestTargetOrPosition()
    if type ~= "Target" then return Status.FAILURE end
	if not target then return Status.FAILURE end

	local distance = (chasseur.Root.Position - target.Root.Position).Magnitude
	return (distance >= self.distanceMin and distance <= self.distanceMax)
		and Status.SUCCESS or Status.FAILURE
end

return InRange