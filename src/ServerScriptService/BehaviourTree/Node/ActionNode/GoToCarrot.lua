local GoToCarrot = {}
GoToCarrot.__index = GoToCarrot

local Status = require(script.Parent.Parent.Utiles.Status)

--[[
    Noeud GoToCarrot : déplace le lapin vers la carotte stockée dans le blackboard,
    puis la mange une fois à portée.
    Dépend de DetectCarrot ayant été exécuté avant dans la Sequence.
]]
function GoToCarrot.new()
    return setmetatable({}, GoToCarrot)
end

function GoToCarrot:Run(rabbit, blackboard)
    local carrot = blackboard.closestCarrot

    -- Sécurité : la carotte a peut-être été détruite entre deux ticks
    if not carrot or not carrot.Parent then
        blackboard:SetClosestCarrot(nil)
        return Status.FAILURE
    end

    return rabbit:GoToAndEat(carrot)
end

return GoToCarrot