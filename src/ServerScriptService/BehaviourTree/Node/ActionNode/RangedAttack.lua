local RangedAttack = {}
RangedAttack.__index = RangedAttack

local Status = require(script.Parent.Parent.Utiles.Status)

-- Réglages
local DEFAULT_MIN_RANGE = 10    -- studs (évite de tirer à bout portant)
local DEFAULT_MAX_RANGE = 35    -- studs
local DEFAULT_COOLDOWN  = 1.2   -- secondes
--[[
    Noeud RangedAttack: attaque la cible à distance
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si l'attaque à distance est terminée avec succès,
            Status.RUNNING si l'attaque est en cours,
            Status.FAILURE si l'attaque ne peut pas être effectuée
]]

function RangedAttack.new(opts)
	local self = setmetatable({}, RangedAttack)
	self.minRange = (opts and opts.minRange) or DEFAULT_MIN_RANGE
	self.maxRange = (opts and opts.maxRange) or DEFAULT_MAX_RANGE
	self.cooldown = (opts and opts.cooldown) or DEFAULT_COOLDOWN
	return self
end

local function isValidTarget(target)
	return target and target.Root and target.Root.Parent ~= nil
end

function RangedAttack:Run(chasseur, blackboard)
	local target = blackboard.target
	if not isValidTarget(target) then
		blackboard.rangedAttack = nil
		return Status.FAILURE
	end

	local hunterPos = chasseur.Root and chasseur.Root.Position
	if not hunterPos then
		return Status.FAILURE
	end

	local targetPos = target.Root.Position
	local dist = (targetPos - hunterPos).Magnitude

	-- Trop près / trop loin => on échoue pour laisser FollowTarget / CloseAttack gérer
	if dist < self.minRange or dist > self.maxRange then
		return Status.FAILURE
	end

	-- Si tu gères les munitions : ne tire pas si vide
	if chasseur.HasMunitions and not chasseur:HasMunitions() then
		return Status.FAILURE
	end

	-- Etat interne (cooldown + tir en cours)
	blackboard.rangedAttack = blackboard.rangedAttack or {
		started = false,
		lastShot = -math.huge,
	}
	local state = blackboard.rangedAttack

	local now = os.clock()

	-- Cooldown : empêche de tirer 60 fois/sec
	if not state.started and (now - state.lastShot) < self.cooldown then
		return Status.FAILURE
	end

	-- Optionnel : line of sight (si dispo)
	-- if chasseur.HasLineOfSight and not chasseur:HasLineOfSight(target) then
	--     return Status.FAILURE
	-- end

	-- Démarrage du tir (une seule fois)
	if not state.started then
		state.started = true
		state.lastShot = now
		blackboard.isBusy = true -- optionnel
	end

	-- Exécution / continuation
	-- Idéalement Shoot() gère animation + projectile + délai
	local result
	if chasseur.Shoot then
		result = chasseur:Shoot(target)
	else
		-- fallback si tu n'as que Attack()
		result = chasseur:Attack(target)
	end

	if result == "running" then
		return Status.RUNNING
	end

	-- Fin du tir : cleanup
	state.started = false
	blackboard.isBusy = false

	if result == "finished" then
		return Status.SUCCESS
	end

	return Status.FAILURE
end

return RangedAttack
