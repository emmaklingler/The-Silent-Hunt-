local DetectTrace = {}
DetectTrace.__index = DetectTrace

local Status = require(script.Parent.Parent.Utiles.Status)

-- Évite de faire des checks 60x/s (surtout si DetectTrace fait des raycasts)
local DETECTION_COOLDOWN = 0.3 -- secondes
--[[
    Noeud DetectTrace: détecte les traces laissées par une cible
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si une trace est détectée,
            Status.FAILURE si aucune trace pertinente n'est détectée
]]

function DetectTrace.new()
	local self = setmetatable({}, DetectTrace)
	return self
end

--[[ 
    Noeud DetectTrace
    Rôle :
    - Cherche des traces (empreintes / odeurs / marqueurs) laissées par une cible
    - Met à jour le blackboard avec une "piste"
    - Ne remplace PAS directement une cible visuelle (target)
]]
function DetectTrace:Run(chasseur, blackboard)

	-- État interne du noeud (persistant)
	blackboard.detectTrace = blackboard.detectTrace or { lastCheck = 0 }
	local state = blackboard.detectTrace

	local now = os.clock()
	if now - state.lastCheck < DETECTION_COOLDOWN then
		return Status.FAILURE
	end
	state.lastCheck = now

	-- Si tu as un état "combat verrouillé", tu peux choisir d'ignorer ici
	-- (mais idéalement tu le gères dans le BT avec IsNotInCombat)
	-- if blackboard.combat and blackboard.combat.inProgress then
	--     return Status.FAILURE
	-- end

	local detectedTrace = chasseur:DetectTrace()
	if not detectedTrace then
		return Status.FAILURE
	end

	-- Une trace = une info de piste, pas une cible confirmée
	-- Donc on stocke une "trace" exploitable par un noeud Investigate / FollowTrace
	blackboard.hasTrace = true
	blackboard.trace = {
		source = detectedTrace.source,            -- optionnel (si fiable)
		position = detectedTrace.position,        -- hyper utile
		strength = detectedTrace.strength or 1,   -- utile pour poids
		timestamp = now,
	}

	-- On peut aussi mettre à jour une destination de recherche
	blackboard.lastKnownPosition = detectedTrace.position

	return Status.SUCCESS
end

return DetectTrace
