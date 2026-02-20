local GoToCarrot = {}
GoToCarrot.__index = GoToCarrot
local Status = require(script.Parent.Parent.Utiles.Status)

function GoToCarrot:Run(rabbit, blackboard)

    local carrotPos = blackboard:GetCarrotPosition()

    if not carrotPos then
        return Status.FAILURE
    end

    return rabbit:Follow(carrotPos)
end

return GoToCarrot
