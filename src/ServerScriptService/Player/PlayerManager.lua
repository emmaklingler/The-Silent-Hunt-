local Rabbit = require(script.Parent.RabbitClass)

local PlayerManager = {}
PlayerManager.__index = PlayerManager

local rabbits = {}
local bots = {}  -- ← table des RabbitBot IA

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

-- ← Ajoute un bot IA
function PlayerManager:AddBot(rabbitBot)
    table.insert(bots, rabbitBot)
end

-- ← Retire un bot IA
function PlayerManager:RemoveBot(rabbitBot)
    for i, b in ipairs(bots) do
        if b == rabbitBot then
            table.remove(bots, i)
            return
        end
    end
end

-- ← Retourne joueurs + bots (utilisé par DetectionVision)
function PlayerManager:GetAllTargets()
    local all = {}
    for _, rabbit in pairs(rabbits) do
        table.insert(all, rabbit)
    end
    for _, bot in ipairs(bots) do
        table.insert(all, bot)
    end
    return all
end

return PlayerManager