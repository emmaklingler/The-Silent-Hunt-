local CanSeeTarget = {}
CanSeeTarget.__index = CanSeeTarget
local Status = require(script.Parent.Parent.Utiles.Status)
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager) -- Liste des classes de joueurs

function CanSeeTarget.new(distance)
    local self = setmetatable({}, CanSeeTarget)
    self.distanceMax = distance -- distance maximale de détection
    return self
end

--[[
    Noeud CanSeeTarget: vérifie si le chasseur peut voir une cible proche
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si une cible est trouvée, sinon Status.FAILURE
]]
function CanSeeTarget:Run(chasseur, blackboard)
    -- Si le chasseur est occupé, il ne peut pas voir de nouvelle cible
	if blackboard.isBusy then return Status.FAILURE end

    -- Recherche de la cible la plus proche parmi les lapins
	for _, rabbitClass in PlayerManager:GetAllRabbits() do
		if rabbitClass.Root then
            -- Calcul de la distance entre le chasseur et le lapin
			local dist = (rabbitClass.Root.Position - chasseur.Root.Position).Magnitude
			if dist < self.distanceMax and rabbitClass:IsAlive() and not rabbitClass:DansCachette() then
                -- Mise à jour de la cible dans le blackboard
				blackboard.target = rabbitClass
				return Status.SUCCESS
			end
		end
	end

	return Status.FAILURE
end

return CanSeeTarget