local NeedsReload = {}
NeedsReload.__index = NeedsReload

local Status = require(script.Parent.Parent.Utiles.Status)

function NeedsReload.new()
	local self = setmetatable({}, NeedsReload)
	return self
end

--[[
    Noeud NeedsReload: vérifie si l'arme du chasseur doit être rechargée
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si l'arme doit être rechargée,
            Status.FAILURE sinon
]]
function NeedsReload:Run(chasseur, blackboard)
	-- Cas propre : méthode dédiée
	if chasseur.NeedsReload then
		return chasseur:NeedsReload() and Status.SUCCESS or Status.FAILURE
	end

	-- Fallback simple (si tu as des variables)
	if chasseur.currentAmmo ~= nil and chasseur.maxAmmo ~= nil then
		if chasseur.currentAmmo <= 0 then
			return Status.SUCCESS
		end
	end

	return Status.FAILURE
end

return NeedsReload
