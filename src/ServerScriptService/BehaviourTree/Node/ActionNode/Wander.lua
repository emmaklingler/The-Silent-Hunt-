local Wander = {}
Wander.__index = Wander

local Status = require(script.Parent.Parent.Utiles.Status)

function Wander.new()
    return setmetatable({}, Wander)
end

--[[
    Noeud Wander: Fait errer le lapin au hasard
    @param rabbit: Instance de RabbitBotClass
]]
function Wander:Run(rabbit, blackboard)
    -- On vérifie si le lapin est déjà en train de bouger (pathState)
    -- Si oui, on continue le mouvement via la fonction Follow de la classe
    if rabbit.pathState then
        local result = rabbit:Follow(rabbit.pathState.target)
        
        -- Si on bouge, on s'assure d'être en état "Running" pour l'animation
        if result == Status.RUNNING then
            rabbit:ChangeState("Running")
        end
        
        return result
    end

    -- Sinon, on choisit une nouvelle destination aléatoire
    local randomPos = rabbit.Root.Position + Vector3.new(
        math.random(-30, 30), 
        0, 
        math.random(-30, 30)
    )

    -- On lance le mouvement
    return rabbit:Follow(randomPos)
end

return Wander