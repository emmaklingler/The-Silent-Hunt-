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
	local target = blackboard.target
	if not target or not target.Root then
		return Status.FAILURE
	end
	
	local result = chasseur:Follow(target.Root.Position, 5)

	return result
end

return FollowTarget 