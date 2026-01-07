local ReloadWeapon = {}
ReloadWeapon.__index = ReloadWeapon
local Status = require(script.Parent.Parent.Utiles.Status)

function ReloadWeapon.new()
	return setmetatable({}, ReloadWeapon)
end

--[[
    Noeud ReloadWeapon: recharge l'arme du chasseur
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si le rechargement est terminé,
            Status.RUNNING si le rechargement est en cours,
            Status.FAILURE si le rechargement est impossible
]]
function ReloadWeapon:Run(chasseur)
	return chasseur:TryReloadWeapon()
end

return ReloadWeapon
