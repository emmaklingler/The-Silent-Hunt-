local IsHungry = {}
IsHungry.__index = IsHungry
local Status = require(script.Parent.Parent.Utiles.Status)

function IsHungry.new()
    return setmetatable({}, IsHungry)
end

function IsHungry:Run(rabbit)
    local satiety = rabbit.Satiety or 100
    return (satiety < 40) and Status.SUCCESS or Status.FAILURE
end

return IsHungry