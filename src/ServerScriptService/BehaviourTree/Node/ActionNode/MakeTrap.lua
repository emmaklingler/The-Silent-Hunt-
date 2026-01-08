local MakeTrap = {}
MakeTrap.__index = MakeTrap

local Status = require(script.Parent.Parent.Utiles.Status) -- adapte si ton Status est ailleurs

--[[
	Noeud MakeTrap: tente de poser un piège à l'emplacement actuel du chasseur
	@param chasseur: classe du chasseur
	@return Status.SUCCESS si le piège est posé avec succès,
			Status.FAILURE sinon
]]
function MakeTrap.new()
	local self = setmetatable({}, MakeTrap)
	return self
end

function MakeTrap:Run(chasseur, blackboard)
	local ok = chasseur:TryPlaceTrap()
	return ok and Status.SUCCESS or Status.FAILURE
end

return MakeTrap
