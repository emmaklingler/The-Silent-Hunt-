local GoToCarrot = {}
GoToCarrot.__index = GoToCarrot

local Status = require(script.Parent.Parent.Utiles.Status)

function GoToCarrot.new()
    return setmetatable({}, GoToCarrot)
end

function GoToCarrot:Run(rabbit, blackboard)
    local carrot = blackboard.closestCarrot

    if not carrot or not carrot.Parent then
        blackboard:SetClosestCarrot(nil)
        return Status.FAILURE
    end

    local result = rabbit:GoToAndEat(carrot)
    
    if result == Status.FAILURE then
        blackboard:SetClosestCarrot(nil)  -- ← force une nouvelle carotte au prochain tick
    end
    
    return result
end

return GoToCarrot