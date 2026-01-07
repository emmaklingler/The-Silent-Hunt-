local GetMunitions = {}
GetMunitions.__index = GetMunitions

local Status = require(script.Parent.Parent.Utiles.Status)

function GetMunitions.new()
	return setmetatable({}, GetMunitions)
end

--[[
	Noeud GetMunitions: fait aller le chasseur chercher des munitions à sa hutte
	@param hunter: classe du chasseur
	@param blackboard: table de données partagées
	@return Status.SUCCESS si le chasseur a récupéré des munitions,
			Status.RUNNING s'il est en chemin,
			Status.FAILURE si le chasseur n'a pas besoin de munitions ou ne peut pas y aller
]]
			
function GetMunitions:Run(hunter, blackboard)
	if not hunter.NeedsMunitions or not hunter:NeedsMunitions() then
		blackboard.getMunitions = nil
		return Status.FAILURE
	end

	local pos = hunter.GetHutPosition and hunter:GetHutPosition()
	if not pos then return Status.FAILURE end

	-- On avance vers le point
	local move = hunter.Follow and hunter:Follow(pos, 12) or Status.FAILURE
	if move == Status.SUCCESS then
		if hunter.RefillMunitions then
			return hunter:RefillMunitions() and Status.SUCCESS or Status.FAILURE
		end
		return Status.SUCCESS
	end

	return move -- RUNNING ou FAILURE
end

return GetMunitions
