local GetMunitions = {}
GetMunitions.__index = GetMunitions

local Status = require(script.Parent.Parent.Utiles.Status)

-- Distance à laquelle on considère être "arrivé" à la cabane
local ARRIVAL_DISTANCE = 4 -- studs

function GetMunitions.new()
	local self = setmetatable({}, GetMunitions)
	return self
end

--[[
    Noeud GetMunitions: va récupérer des munitions à un point dédié
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si les munitions sont récupérées,
            Status.RUNNING si le déplacement ou la récupération est en cours,
            Status.FAILURE si les munitions ne peuvent pas être récupérées
]]

function GetMunitions:Run(chasseur, blackboard)

	-- Si le chasseur n’a pas besoin de munitions, on échoue volontairement
	if not chasseur:NeedsMunitions() then
		return Status.FAILURE
	end

	-- Position de la cabane (point fixe connu du chasseur)
	local hutPosition = chasseur:GetHutPosition()
	if not hutPosition then
		return Status.FAILURE
	end

	-- Initialisation de l’état interne
	blackboard.getMunitions = blackboard.getMunitions or {
		moving = false
	}

	local state = blackboard.getMunitions
	local hunterPos = chasseur.Root and chasseur.Root.Position
	if not hunterPos then
		return Status.FAILURE
	end

	local dist = (hutPosition - hunterPos).Magnitude

	-- Si on n’est pas encore arrivé
	if dist > ARRIVAL_DISTANCE then
		if not state.moving then
			-- Lancement du déplacement une seule fois
			state.moving = true
			chasseur:MoveTo(hutPosition)
		end
		return Status.RUNNING
	end

	-- Arrivé à la cabane → récupération des munitions
	chasseur:RefillMunitions()

	-- Cleanup
	state.moving = false
	blackboard.getMunitions = nil

	return Status.SUCCESS
end

return GetMunitions
