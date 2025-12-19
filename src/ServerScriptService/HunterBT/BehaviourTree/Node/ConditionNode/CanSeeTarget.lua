local actionNode = script.Parent
local Status = require(actionNode.Parent.Utiles.Status.Status)

local CanSeeTarget = {}
CanSeeTarget.__index = CanSeeTarget

-- création du noeud de vision avec distance et angle de vue
function CanSeeTarget.new(maxDist, fov)
    return setmetatable({
        maxDist = maxDist or 60,
        fov = fov or 120,
        memoryTime = 2, -- temps pour garder la cible en mémoire
        lastSeenTick = 0
    }, CanSeeTarget)
end

-- exécution de la détection de la cible
function CanSeeTarget:Run(hunter, bb)
    local target = hunter.Target
    if not target or not target.PrimaryPart then return Status.FAILURE end

    local hunterPart = hunter.Model.PrimaryPart
    local targetPart = target.PrimaryPart
    local vectorToTarget = targetPart.Position - hunterPart.Position
    local distance = vectorToTarget.Magnitude

    -- détection automatique si le joueur est collé au chasseur
    if distance < 15 then
        self.lastSeenTick = tick()
        return Status.SUCCESS
    end

    -- calcul pour savoir si la cible est dans le champ de vision
    local dot = hunterPart.CFrame.LookVector:Dot(vectorToTarget.Unit)
    local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
    
    if distance <= self.maxDist and angle <= (self.fov / 2) then
        -- vérification des obstacles avec un raycast
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {hunter.Model}
        local ray = workspace:Raycast(hunterPart.Position, vectorToTarget, params)
        
        if ray and ray.Instance:IsDescendantOf(target) then
            self.lastSeenTick = tick()
            return Status.SUCCESS
        end
    end

    -- maintien de la cible en mémoire pour éviter les saccades
    if tick() - self.lastSeenTick < self.memoryTime then
        return Status.SUCCESS
    end

    return Status.FAILURE
end

return CanSeeTarget