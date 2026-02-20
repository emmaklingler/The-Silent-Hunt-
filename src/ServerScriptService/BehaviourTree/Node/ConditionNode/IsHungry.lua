local IsHungry = {}
IsHungry.__index = IsHungry
local Status = require(script.Parent.Parent.Utiles.Status)


function IsHungry:Run(rabbit)
    if rabbit.Satiety < 40 then
        return Status.SUCCESS
    end
    return Status.FAILURE
end

return IsHungry
