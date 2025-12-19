local actionNode = script.Parent
local Status = require(actionNode.Parent.Utiles.Status.Status)

local Patrol = {}
Patrol.__index = Patrol

-- création du noeud de patrouille
function Patrol.new()
    return setmetatable({ 
        nextPos = nil, 
        t = 0 
    }, Patrol)
end

-- exécution de la patrouille aléatoire
function Patrol:Run(hunter, bb)
    local currentPos = hunter:GetPosition()
    self.t += (bb.dt or 0)

    -- calcul de la distance avec le point de patrouille
    local distance = (self.nextPos and (currentPos - self.nextPos).Magnitude) or 0

    -- décision pour changer de cible si arrivé ou bloqué
    if not self.nextPos or distance < 8 or self.t >= 6 then
        if not self.nextPos then
            print("Patrol: lancement initial")
        elseif distance < 8 then
            print("Patrol: destination atteinte")
        else
            print("Patrol: changement de direction force")
        end
        
        self.t = 0
        self:ChooseNewRandomDestination(currentPos)
    end

    -- ordre de mouvement permanent
    hunter:MoveTo(self.nextPos)
    return Status.RUNNING
end

-- choix d'une nouvelle position aléatoire
function Patrol:ChooseNewRandomDestination(currentPos)
    local angle = math.rad(math.random(0, 360))
    local dist = math.random(40, 80)
    self.nextPos = currentPos + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
    print("Patrol: nouvelle cible a " .. math.floor(dist) .. " studs")
end

return Patrol