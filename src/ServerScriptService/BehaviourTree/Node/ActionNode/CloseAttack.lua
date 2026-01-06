local CloseAttack = {}
CloseAttack.__index = CloseAttack

-- Enum des statuts du Behaviour Tree (SUCCESS / FAILURE / RUNNING)
local Status = require(script.Parent.Parent.Utiles.Status)

-- Paramètres par défaut du noeud
-- range    : distance maximale pour attaquer
-- cooldown : temps minimal entre deux attaques
local DEFAULT_RANGE = 6          -- studs
local DEFAULT_COOLDOWN = 1.0     -- secondes
--[[
    Noeud CloseAttack: attaque la cible en corps à corps
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si l'attaque est effectuée, sinon Status.FAILURE
]]
    
-- Constructeur du noeud CloseAttack
-- opts permet de surcharger range et cooldown si besoin
function CloseAttack.new(opts)
	local self = setmetatable({}, CloseAttack)
	self.range = (opts and opts.range) or DEFAULT_RANGE
	self.cooldown = (opts and opts.cooldown) or DEFAULT_COOLDOWN
	return self
end

-- Vérifie que la cible est toujours valide
-- (existe, possède un Root, et n’a pas été détruite)
local function isValidTarget(target)
	return target
		and target.Root
		and target.Root.Parent ~= nil
end

-- Méthode principale appelée par le Behaviour Tree
-- Elle est exécutée à chaque tick tant que le noeud est actif
function CloseAttack:Run(chasseur, blackboard)

	-- Récupération de la cible depuis le blackboard
	local target = blackboard.target

	-- Si la cible n’est plus valide, on nettoie l’état interne
	-- et on échoue pour laisser l’arbre choisir une autre action
	if not isValidTarget(target) then
		blackboard.closeAttack = nil
		return Status.FAILURE
	end

	-- Initialisation de l’état interne du noeud
	-- Cet état persiste entre les ticks tant que l’attaque est en cours
	blackboard.closeAttack = blackboard.closeAttack or {
		started = false,        -- indique si l’attaque a déjà commencé
		lastStart = -math.huge  -- timestamp du dernier déclenchement
	}

	local state = blackboard.closeAttack

	-- Vérification de la position du chasseur
	local hunterPos = chasseur.Root and chasseur.Root.Position
	if not hunterPos then
		return Status.FAILURE
	end

	-- Calcul de la distance entre le chasseur et la cible
	local targetPos = target.Root.Position
	local dist = (targetPos - hunterPos).Magnitude

	-- Si la cible est trop loin, on échoue volontairement
	-- Cela permet à un noeud de déplacement (FollowTarget) de prendre le relais
	if dist > self.range then
		state.started = false
		return Status.FAILURE
	end

	-- Gestion du cooldown
	-- Empêche le chasseur d’attaquer en boucle à chaque tick
	local now = os.clock()
	if not state.started and (now - state.lastStart) < self.cooldown then
		return Status.FAILURE
	end

	-- Démarrage de l’attaque
	-- Cette partie n’est exécutée qu’une seule fois par attaque
	if not state.started then
		state.started = true
		state.lastStart = now
		-- Optionnel : permet de signaler que le chasseur est occupé
		blackboard.isBusy = true
	end

	-- Exécution de l’attaque
	-- La méthode Attack doit renvoyer :
	-- "running"  → l’attaque est en cours
	-- "finished" → l’attaque est terminée
	-- "failed"   → l’attaque a échoué
	local result = chasseur:Attack(target)

	-- Tant que l’attaque n’est pas terminée, on reste en RUNNING
	if result == "running" then
		return Status.RUNNING
	end

	-- Fin de l’attaque : nettoyage de l’état
	state.started = false
	blackboard.isBusy = false

	-- Résultat final de l’attaque
	if result == "finished" then
		return Status.SUCCESS
	end

	return Status.FAILURE
end

return CloseAttack
