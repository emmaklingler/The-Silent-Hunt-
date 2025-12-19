--- Patrol.lua
local scriptParent = script.Parent :: Instance
local nodeFolder = scriptParent.Parent :: Instance
local utilesFolder = nodeFolder:WaitForChild("Utiles")

local statusModule = utilesFolder:WaitForChild("Status"):WaitForChild("Status") :: ModuleScript
local Status = require(statusModule)

local Patrol = {}
Patrol.__index = Patrol

function Patrol.new()
    return setmetatable({ 
        anchorPos = nil,    -- Le point central de la patrouille
        nextPos = nil, 
        t = 0,
        isWaiting = false,  -- Pour gérer les pauses
        waitTime = 0        -- Durée de la pause actuelle
    }, Patrol)
end

function Patrol:Run(hunter, bb)
    local currentPos = hunter:GetPosition()
    
    -- Initialisation de l'ancre au premier lancement
    if not self.anchorPos then
        self.anchorPos = currentPos
    end

    -- Gestion du temps (Delta Time)
    self.t += (bb.dt or 0)

    -- 1. Logique de pause (rend le mouvement plus humain)
    if self.isWaiting then
        if self.t >= self.waitTime then
            self.isWaiting = false
            self.t = 0
            self:ChooseNewDestination(currentPos)
        else
            return Status.RUNNING -- On ne fait rien, on attend
        end
    end

    -- 2. Vérification de l'arrivée
    local distance = 0
    if self.nextPos then
        distance = (currentPos - self.nextPos).Magnitude
    end

    -- 3. Changement de destination (si arrivé ou coincé trop longtemps)
    if not self.nextPos or distance < 5 or self.t >= 10 then
        self.isWaiting = true
        self.waitTime = math.random(2, 5) -- Attend entre 2 et 5 secondes
        self.t = 0
        -- On s'arrête visuellement
        hunter:MoveTo(currentPos) 
        return Status.RUNNING
    end

    hunter:MoveTo(self.nextPos)
    return Status.RUNNING
end

function Patrol:ChooseNewDestination(currentPos)
    -- On choisit un point dans un cercle autour de l'ancre d'origine
    -- Cela évite que l'IA traverse toute la map
    local radius = 50
    local angle = math.rad(math.random(0, 360))
    local dist = math.random(15, radius)
    
    local offset = Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
    self.nextPos = self.anchorPos + offset
    
    -- Optionnel : Raycast ici pour vérifier si le point est marchable !
end

return Patrol