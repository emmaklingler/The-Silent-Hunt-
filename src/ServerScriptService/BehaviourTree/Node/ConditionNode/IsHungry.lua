local IsHungry = {}
IsHungry.__index = IsHungry
local Status = require(script.Parent.Parent.Utiles.Status)

function IsHungry.new()
    return setmetatable({}, IsHungry)
end

function IsHungry:Run(rabbit)
    -- On considère qu'il a faim s'il est en dessous de 70%
    if rabbit.Satiety < 70 then
        return Status.SUCCESS
    end
    return Status.FAILURE
end

return IsHungry