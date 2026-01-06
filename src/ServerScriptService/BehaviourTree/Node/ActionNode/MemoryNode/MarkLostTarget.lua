local MakeTrap = {}
MakeTrap.__index = MakeTrap

local Status = require(script.Parent.Parent.Utiles.Status)

local DEFAULT_COOLDOWN = 6.0    -- secondes entre 2 poses
local DEFAULT_PLACE_TIME = 1.2  -- secondes pour poser le piège
local MIN_TRAP_SPACING = 12     -- studs (évite 15 pièges au même endroit)
--[[
    Noeud MarkLostTarget: enregistre la perte de la cible actuelle
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS après l'enregistrement de la perte de cible
]]

function MakeTrap.new(opts)
	local self = setmetatable({}, MakeTrap)
	self.cooldown = (opts and opts.cooldown) or DEFAULT_COOLDOWN
	self.placeTime = (opts and opts.placeTime) or DEFAULT_PLACE_TIME
	self.minTrapSpacing = (opts and opts.minTrapSpacing) or MIN_TRAP_SPACING
	return self
end

local function isTooClose(blackboard, pos, minSpacing)
	if not blackboard.traps then return false end
	for _, t in ipairs(blackboard.traps) do
		if t.position and (t.position - pos).Magnitude < minSpacing then
			return true
		end
	end
	return false
end

function MakeTrap:Run(chasseur, blackboard)
	blackboard.makeTrap = blackboard.makeTrap or {
		placing = false,
		startTime = 0,
		lastPlaced = -math.huge,
	}

	local state = blackboard.makeTrap
	local now = os.clock()

	-- Cooldown anti-spam
	if not state.placing and (now - state.lastPlaced) < self.cooldown then
		return Status.FAILURE
	end

	local hunterPos = chasseur.Root and chasseur.Root.Position
	if not hunterPos then
		return Status.FAILURE
	end

	-- Anti-spam local (pas deux pièges collés)
	if not state.placing and isTooClose(blackboard, hunterPos, self.minTrapSpacing) then
		return Status.FAILURE
	end

	-- Démarrage (une seule fois)
	if not state.placing then
		-- Optionnel : check ressource si tu as
		if chasseur.CanMakeTrap and not chasseur:CanMakeTrap() then
			return Status.FAILURE
		end

		-- Optionnel : démarre anim/sound, reserve ressource
		if chasseur.StartMakeTrap then
			local ok = chasseur:StartMakeTrap()
			if not ok then return Status.FAILURE end
		end

		state.placing = true
		state.startTime = now
		blackboard.isBusy = true -- si tu veux, mais ne bloque pas MakeTrap avec
		return Status.RUNNING
	end

	-- En cours : on attend la fin
	if (now - state.startTime) < self.placeTime then
		return Status.RUNNING
	end

	-- Finalisation : spawn + consommation réelle
	local success
	if chasseur.FinishMakeTrap then
		success = chasseur:FinishMakeTrap()
	else
		-- fallback si tu as juste MakeTrap()
		success = chasseur:MakeTrap()
	end

	-- Log dans le blackboard (utile pour ShouldPlaceTrap)
	blackboard.traps = blackboard.traps or {}
	table.insert(blackboard.traps, { position = hunterPos, time = now })

	-- Cleanup
	state.placing = false
	state.lastPlaced = now
	blackboard.isBusy = false

	return success and Status.SUCCESS or Status.FAILURE
end

return MakeTrap
