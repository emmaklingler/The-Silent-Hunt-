local NeedsMunitions = {}
NeedsMunitions.__index = NeedsMunitions

local Status = require(script.Parent.Parent.Utiles.Status)
--[[
    Noeud NeedsMunitions: vérifie si le chasseur a besoin de munitions
    @param hunter: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si le chasseur a besoin de munitions,
            Status.FAILURE sinon
]]
function NeedsMunitions.new()
	return setmetatable({}, NeedsMunitions)
end

function NeedsMunitions:Run(hunter, blackboard)
	if not hunter.NeedsMunitions then return Status.FAILURE end
	return hunter:NeedsMunitions() and Status.SUCCESS or Status.FAILURE
end

return NeedsMunitions
