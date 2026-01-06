local ShouldPlaceTrap = {}
ShouldPlaceTrap.__index = ShouldPlaceTrap

local Status = require(script.Parent.Parent.Utiles.Status)

-- Réglages
local DEFAULT_LOST_WINDOW = 5.0      -- secondes : "perdu récemment"
local DEFAULT_MAX_DISTANCE = 10      -- studs : distance max de lastKnownPosition
local DEFAULT_MIN_TRAP_SPACING = 12  -- studs : pas 2 pièges collés

function ShouldPlaceTrap.new(opts)
	local self = setmetatable({}, ShouldPlaceTrap)
	self.lostWindow = (opts and opts.lostWindow) or DEFAULT_LOST_WINDOW
	self.maxDistance = (opts and opts.maxDistance) or DEFAULT_MAX_DISTANCE
	self.minTrapSpacing = (opts and opts.minTrapSpacing) or DEFAULT_MIN_TRAP_SPACING
	return self
end

local function dist(a, b)
	return (a - b).Magnitude
end

-- Vérifie qu'on peut poser un piège ICI (sol correct, pas eau, etc.)
-- Tu peux le mettre côté chasseur si tu préfères centraliser la logique.
local function isGroundOk(chasseur)
	if chasseur.CanPlaceTrapHere then
		return chasseur:CanPlaceTrapHere()
	end
	return true -- fallback : si pas implémenté, on ne bloque pas
end

-- Empêche de poser un piège trop proche d’un autre (simple anti-spam)
local function isTooCloseToExistingTrap(blackboard, position, minSpacing)
	if not blackboard.traps then return false end
	for _, t in ipairs(blackboard.traps) do
		if t.position and dist(t.position, position) < minSpacing then
			return true
		end
	end
	return false
end
--[[
    Noeud ShouldPlaceTrap: détermine si le chasseur doit poser un piège
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si les conditions de pose de piège sont réunies,
            Status.FAILURE sinon
]]

--[[ 
    Condition : ShouldPlaceTrap
    SUCCESS si :
    - hors combat
    - a des pièges / peut en fabriquer
    - cible perdue récemment
    - lastKnownPosition proche
    - terrain OK
    - pas déjà un piège tout près
]]
function ShouldPlaceTrap:Run(chasseur, blackboard)
	-- 1) Hors combat (à adapter selon ton système)
	if blackboard.combat and blackboard.combat.inProgress then
		return Status.FAILURE
	end

	-- 2) Ressources : stock / capacité
	if chasseur.HasTraps and not chasseur:HasTraps() then
		return Status.FAILURE
	end
	-- Si tu n'as pas HasTraps(), tu peux remplacer par un champ chasseur.traps

	-- 3) Perdu récemment ?
	local lostTime = blackboard.lostTargetTime
	if not lostTime then
		return Status.FAILURE
	end
	local now = os.clock()
	if (now - lostTime) > self.lostWindow then
		return Status.FAILURE
	end

	-- 4) lastKnownPosition obligatoire
	local lastPos = blackboard.lastKnownPosition
	local hunterPos = chasseur.Root and chasseur.Root.Position
	if not lastPos or not hunterPos then
		return Status.FAILURE
	end

	-- 5) Pas trop loin du dernier point connu
	if dist(hunterPos, lastPos) > self.maxDistance then
		return Status.FAILURE
	end

	-- 6) Terrain OK
	if not isGroundOk(chasseur) then
		return Status.FAILURE
	end

	-- 7) Pas déjà un piège collé
	if isTooCloseToExistingTrap(blackboard, hunterPos, self.minTrapSpacing) then
		return Status.FAILURE
	end

	return Status.SUCCESS
end

return ShouldPlaceTrap
