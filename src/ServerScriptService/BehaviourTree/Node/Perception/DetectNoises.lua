local DetectNoises = {}
DetectNoises.__index = DetectNoises

-- Enum des statuts du Behaviour Tree
local Status = require(script.Parent.Parent.Utiles.Status)

-- Temps minimal entre deux détections de bruit
-- Évite de recalculer 60 fois par seconde
local DETECTION_COOLDOWN = 0.2 -- secondes
--[[
    Noeud DetectNoises: détecte les bruits dans l'environnement
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si un bruit est détecté,
            Status.FAILURE si aucun bruit pertinent n'est détecté
]]

function DetectNoises.new()
	local self = setmetatable({}, DetectNoises)
	return self
end

--[[ 
    Noeud DetectNoises
    Rôle :
    - Écoute l’environnement pour détecter un bruit
    - Met à jour le blackboard avec une "cible sonore"
    - Ne déclenche PAS directement une attaque
]]
function DetectNoises:Run(chasseur, blackboard)

	-- Initialisation de l’état interne du noeud
	blackboard.detectNoises = blackboard.detectNoises or {
		lastCheck = 0
	}

	local state = blackboard.detectNoises
	local now = os.clock()

	-- Cooldown de détection
	-- Évite de spammer DetectNoises() à chaque tick
	if now - state.lastCheck < DETECTION_COOLDOWN then
		return Status.FAILURE
	end

	state.lastCheck = now

	-- Détection du bruit via le chasseur
	-- Cette méthode devrait idéalement renvoyer :
	-- {
	--   source = <instance>,
	--   position = Vector3,
	--   intensity = number,
	--   type = "step" | "jump" | "fall" | etc.
	-- }
	local detectedNoise = chasseur:DetectNoises()

	-- Aucun bruit détecté
	if not detectedNoise then
		return Status.FAILURE
	end

	-- Mise à jour du blackboard
	-- IMPORTANT : on ne remplace PAS forcément une cible visible
	-- Une cible sonore est moins fiable qu’une cible visuelle
	blackboard.lastKnownPosition = detectedNoise.position
	blackboard.noiseSource = detectedNoise.source
	blackboard.hasHeardNoise = true

	-- On ne met PAS directement blackboard.target ici
	-- Le choix final appartient au Behaviour Tree (Selector / WeightedSelector)
	return Status.SUCCESS
end

return DetectNoises
