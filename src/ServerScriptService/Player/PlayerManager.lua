local Players = game:GetService("Players")

local Rabbit = require(script.Parent.RabbitClass)

local PlayerManager = {}
PlayerManager.__index = PlayerManager

local rabbits = {}

function PlayerManager:CreateRabbit(player, profile)
    local rabbit = Rabbit.new(player, profile)
    rabbits[player] = rabbit
    return rabbit
end

function PlayerManager:GetRabbit(player)
    return rabbits[player]
end

function PlayerManager:RemoveRabbit(player)
    rabbits[player] = nil
end

function PlayerManager:GetAllRabbits()
    return rabbits
end


return PlayerManager
