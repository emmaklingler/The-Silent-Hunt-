local EatCarrot = {}
EatCarrot.__index = EatCarrot

local Status = require(script.Parent.Parent.Utiles.Status)

function EatCarrot.new()
    return setmetatable({}, EatCarrot)
end

function EatCarrot:Run(rabbit, blackboard)
    -- Sécurité : si on n'a pas de carotte cible dans le blackboard
    if not blackboard.closestCarrot then
        return Status.FAILURE
    end

    local carrot = blackboard.closestCarrot
    local distance = (rabbit.Root.Position - carrot.Position).Magnitude

    -- ÉTAPE 1 : Se déplacer vers la carotte si on est trop loin
    if distance > 4 then
        rabbit:ChangeState("Running")
        rabbit.Humanoid:MoveTo(carrot.Position)
        return Status.RUNNING
    end

    -- ÉTAPE 2 : On est arrivé ! On déclenche l'action de manger
    -- On utilise une fonction dans RabbitBotClass pour gérer la disparition de la carotte
    local success = rabbit:ActionEat(carrot)

    if success then
        -- On vide la cible du blackboard pour ne pas remanger la même
        blackboard.closestCarrot = nil
        return Status.SUCCESS
    end

    return Status.FAILURE
end

return EatCarrot