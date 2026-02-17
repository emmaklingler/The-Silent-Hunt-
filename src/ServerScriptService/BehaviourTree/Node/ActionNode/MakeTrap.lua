local MakeTrap = {}
MakeTrap.__index = MakeTrap

local Status = require(script.Parent.Parent.Utiles.Status)

function MakeTrap.new(arriveRadius)
	local self = setmetatable({}, MakeTrap)
	self.arriveRadius = arriveRadius or 6
	return self
end
--[[
	Noeud MakeTrap: fait poser un piège au chasseur à la dernière position vue de la cible
	@param chasseur: classe du chasseur
	@param blackboard: table de données partagées
	@return Status.SUCCESS si le piège a été posé,
			Status.FAILURE sinon
]]
function MakeTrap:Run(chasseur, blackboard)
	return chasseur:TryPlaceTrapAt()
end

return MakeTrap
