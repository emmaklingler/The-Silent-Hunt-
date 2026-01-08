local DetectionVision = {}
DetectionVision.__index = DetectionVision

local Status = require(script.Parent.Parent.Utiles.Status)
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

-- Champ de vision total = 200° (100° à gauche + 100° à droite)
local COS_HALF_FOV = math.cos(math.rad(100))

function DetectionVision.new(distance)
	return setmetatable({ distanceMax = distance }, DetectionVision)
end

--[[
    Noeud DetectionVision: vérifie si le chasseur peut voir une cible dans son champ de vision
    @param chasseur: classe du chasseur
    @param blackboard: table de données partagées
    @return Status.SUCCESS si une cible est trouvée, sinon Status.FAILURE
]]
function DetectionVision:Run(chasseur, blackboard)
	if not chasseur.Root then return Status.FAILURE end

	local origin = chasseur.Root.Position
	local forward = chasseur.Root.CFrame.LookVector

	-- Raycast : ignore le chasseur lui-même
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { chasseur.Model }

	for _, rabbit in PlayerManager:GetAllRabbits() do
		if rabbit.Root and rabbit:IsAlive() and not rabbit:DansCachette() then
			local toTarget = rabbit.Root.Position - origin
			local dist = toTarget.Magnitude

			-- 1) Trop loin → on ignore
			if dist <= self.distanceMax then
				local dir = toTarget.Unit

				-- 2) Pas devant → on ignore
				local dot = forward:Dot(dir)
				if dot >= COS_HALF_FOV then

					-- 3) Raycast : mur / arbre bloque la vue
					local result = workspace:Raycast(origin, toTarget, params)

					-- 4) Si on touche le lapin → il est visible
					if result and result.Instance:IsDescendantOf(rabbit.Model) then
                        blackboard:SetSeenTarget(rabbit)
                        return Status.SUCCESS
                    end

				end
			end
		end
	end
	blackboard:UnsetSeenTarget()
	return Status.FAILURE
end

return DetectionVision
