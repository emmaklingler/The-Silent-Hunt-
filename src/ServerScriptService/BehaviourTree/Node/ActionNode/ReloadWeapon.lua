local ReloadWeapon = {}
ReloadWeapon.__index = ReloadWeapon
local Status = require(script.Parent.Parent.Utiles.Status)

local DEFAULT_RELOAD_TIME = 1.6
local DEFAULT_COOLDOWN = 0.2

function ReloadWeapon.new(opts)
	local self = setmetatable({}, ReloadWeapon)
	self.reloadTime = (opts and opts.reloadTime) or DEFAULT_RELOAD_TIME
	self.cooldown = (opts and opts.cooldown) or DEFAULT_COOLDOWN
	return self
end

--[[
    Noeud ReloadWeapon: recharge l'arme du chasseur
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si l'arme est rechargée,
            Status.RUNNING si le rechargement est en cours,
            Status.FAILURE si le rechargement ne peut pas être effectué
]]
function ReloadWeapon:Run(chasseur, blackboard)
	blackboard.reload = blackboard.reload or {
		active = false,
		startTime = 0,
		lastTry = 0,
	}

	local state = blackboard.reload
	local now = os.clock()

	-- évite de relancer 60x/s si impossible
	if not state.active and (now - state.lastTry) < self.cooldown then
		return Status.FAILURE
	end

	-- Démarrage du reload (une seule fois)
	if not state.active then
		state.lastTry = now

		-- Optionnel : si tu as une méthode "CanReload"
		if chasseur.CanReload and not chasseur:CanReload() then
			return Status.FAILURE
		end

		-- StartReload si tu l’as (animation / son / verrou)
		if chasseur.StartReload then
			local ok = chasseur:StartReload()
			if not ok then return Status.FAILURE end
		end

		state.active = true
		state.startTime = now
		blackboard.isBusy = true -- info (évite d'autres actions si tu veux)
		return Status.RUNNING
	end

	-- En cours : on attend la fin
	if (now - state.startTime) < self.reloadTime then
		return Status.RUNNING
	end

	-- Fin : applique réellement le reload
	local success
	if chasseur.FinishReload then
		success = chasseur:FinishReload()
	else
		-- fallback : si tu n’as qu’une seule fonction, elle doit vraiment recharger ici
		success = chasseur:ReloadWeapon()
	end

	-- Cleanup
	state.active = false
	blackboard.isBusy = false

	return success and Status.SUCCESS or Status.FAILURE
end

return ReloadWeapon
