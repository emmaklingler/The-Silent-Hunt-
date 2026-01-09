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
	local target, type =  blackboard:GetBestTargetOrPosition()
    if not target then return Status.FAILURE end
	local pos = nil
	if type == "Position" then
		pos = target
	elseif type == "Target" then
		pos = target.Root.Position
	end
	if not pos then return Status.FAILURE end
	
	local result = chasseur:Follow(pos, 5)

	return result
end

return FollowTarget 