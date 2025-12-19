local actionNode = script.Parent
local utilesFolder = actionNode.Parent:WaitForChild("Utiles")
local Status = require(utilesFolder:WaitForChild("Status"):WaitForChild("Status"))

local FollowTarget = {}
FollowTarget.__index = FollowTarget

-- création du noeud de poursuite avec distance d'arrêt
function FollowTarget.new(stopDist)
    return setmetatable({ stopDist = stopDist or 6 }, FollowTarget)
end

-- exécution du déplacement vers la cible
function FollowTarget:Run(hunter, bb)
    local target = hunter.Target
    if not target or not target.PrimaryPart then return Status.FAILURE end

    local dist = hunter:GetDistanceTo(target)

    -- réglage de la vitesse de course
    if hunter.Humanoid then
        hunter.Humanoid.WalkSpeed = 24 
    end

    -- gestion de la proximité pour rester collé à la cible pendant l'attaque
    if dist <= self.stopDist then
        hunter:MoveTo(target.PrimaryPart.Position)
        print("FollowTarget: cible a portee, maintien de la position")
        return Status.SUCCESS
    end

    -- poursuite classique
    print("FollowTarget: poursuite de " .. target.Name)
    hunter:MoveTo(target.PrimaryPart.Position)
    
    return Status.RUNNING
end

return FollowTarget