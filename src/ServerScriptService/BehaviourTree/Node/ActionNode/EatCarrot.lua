local EatCarrot = {}
EatCarrot.__index = EatCarrot

local Status = require(script.Parent.Parent.Utiles.Status)

function EatCarrot.new()
    return setmetatable({}, EatCarrot)
end

function EatCarrot:Run(rabbit, blackboard)
    local carrot = blackboard.closestCarrot
    
    -- Sécurité
    if not carrot or not carrot.Parent then
        return Status.FAILURE
    end

    local distance = (rabbit.Root.Position - carrot.Position).Magnitude

    -- DEBUG : On affiche la distance en temps réel
    print(string.format("🥕 [DEBUG] Le lapin est à %.2f mètres de la carotte", distance))

    if distance > 4 then
        -- Le lapin court vers la carotte
        rabbit:ChangeState("Running")
        rabbit.Humanoid:MoveTo(carrot.Position)
        return Status.RUNNING -- Très important : on dit au BT qu'on est en train de marcher
    else
        -- ON EST ARRIVÉ
        print("😋 [MIAM] Le lapin commence à manger !")
        rabbit:ActionEat(carrot)
        return Status.SUCCESS
    end
end
return EatCarrot