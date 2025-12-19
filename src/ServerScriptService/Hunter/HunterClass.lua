local PathfindingService = game:GetService("PathfindingService")

local Hunter = {}
Hunter.__index = Hunter

-- reglages des vitesses
local SPEEDS = {
    PATROL = 14,
    CHASE = 24
}

-- création du chasseur et setup des paramètres
function Hunter.new(model: Model)
    local self = setmetatable({}, Hunter)
    self.Model = model
    self.Humanoid = model:FindFirstChildOfClass("Humanoid")
    self.lastPathCompute = 0 
    
    -- vérification de la partie principale du modèle
    if not self.Model.PrimaryPart then
        self.Model.PrimaryPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("RootPart")
    end

    -- configuration du pathfinding
    self.Path = PathfindingService:CreatePath({
        AgentRadius = 1.5, 
        AgentHeight = 6,
        AgentCanJump = true,
        WaypointSpacing = 3,
    })

    -- activation de la rotation et vitesse initiale
    if self.Humanoid then
        self.Humanoid.AutoRotate = true 
        self.Humanoid.WalkSpeed = SPEEDS.PATROL
    end

    -- gestion du network owner pour la fluidité
    if self.Model.PrimaryPart then
        pcall(function() self.Model.PrimaryPart:SetNetworkOwner(nil) end)
    end

    print("HunterClass: prete")
    return self
end

-- gestion des déplacements vers une cible
function Hunter:MoveTo(targetPosition: Vector3)
    if not self.Humanoid or not self.Model.PrimaryPart then return end
    
    local currentPos = self.Model.PrimaryPart.Position
    local vectorToTarget = targetPosition - currentPos
    local distance = vectorToTarget.Magnitude

    -- deplacement direct si la cible est proche
    if distance < 15 then
        self.Humanoid:Move(vectorToTarget.Unit)
        self.Humanoid.WalkSpeed = SPEEDS.CHASE
        return
    end

    -- calcul du chemin avec un petit delai
    local now = tick()
    if now - self.lastPathCompute < 0.5 then return end
    self.lastPathCompute = now

    local success, err = pcall(function()
        self.Path:ComputeAsync(currentPos, targetPosition)
    end)

    -- suivi des points du chemin
    if success and self.Path.Status == Enum.PathStatus.Success then
        local waypoints = self.Path:GetWaypoints()
        local nextPoint = waypoints[3] or waypoints[2]
        if nextPoint then
            if nextPoint.Action == Enum.PathWaypointAction.Jump then
                self.Humanoid.Jump = true
            end
            self.Humanoid:MoveTo(nextPoint.Position)
        end
    else
        -- mouvement par defaut si le pathfinding echoue
        self.Humanoid:MoveTo(targetPosition)
    end
end

-- arrêt du mouvement
function Hunter:StopMoving()
    if self.Humanoid then
        self.Humanoid:Move(Vector3.zero)
    end
end

-- récupération de la position actuelle
function Hunter:GetPosition()
    return self.Model.PrimaryPart and self.Model.PrimaryPart.Position or Vector3.zero
end

-- calcul de la distance
function Hunter:GetDistanceTo(target: Instance): number
    local targetPart = target:IsA("Model") and target.PrimaryPart or target:FindFirstChild("HumanoidRootPart")
    if self.Model.PrimaryPart and targetPart then
        return (targetPart.Position - self.Model.PrimaryPart.Position).Magnitude
    end
    return 9999
end

return Hunter