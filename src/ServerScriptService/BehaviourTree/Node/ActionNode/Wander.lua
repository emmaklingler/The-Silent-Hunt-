local Wander = {}
Wander.__index = Wander

local Status = require(script.Parent.Parent.Utiles.Status)

function Wander.new()
    return setmetatable({}, Wander)
end

function Wander:Run(rabbit, blackboard)
    -- On délègue TOUTE la logique à la classe RabbitBot
    -- C'est elle qui gère si elle doit continuer à marcher ou choisir une nouvelle cible
    return rabbit:Wander()
end

return Wander