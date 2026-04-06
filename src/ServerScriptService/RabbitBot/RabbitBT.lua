local RabbitBT = {}
RabbitBT.__index = RabbitBT

local RunService = game:GetService("RunService")
local Node = game.ServerScriptService:WaitForChild("BehaviourTree"):WaitForChild("Node")

local Selector = require(Node.Utiles.Selector)
local Sequence = require(Node.Utiles.Sequence)
local Blackboard = require(Node.Utiles.Blackboard)

local Flee       = require(Node.ActionNode.Flee)
local GoToCarrot = require(Node.ActionNode.GoToCarrot)
local Wander     = require(Node.ActionNode.Wander)

local IsHungry    = require(Node.ConditionNode.IsHungry)
local HunterClose = require(Node.ConditionNode.HunterClose)

local DetectCarrot = require(Node.Perception.DetectCarrot)

-----------------------------------------------------
-- TREE
-----------------------------------------------------

local tree = Selector.new({

    Sequence.new({
        HunterClose.new(),
        Flee.new(),
    }),

    Sequence.new({
        IsHungry.new(),
        DetectCarrot.new(200),
        GoToCarrot.new(),
    }),

    Wander.new(),
})

-----------------------------------------------------
-- STORAGE DES LAPINS
-----------------------------------------------------

local rabbits = {} -- liste des bots actifs

-----------------------------------------------------
-- PERCEPTION
-----------------------------------------------------

local function UpdatePerception(rabbit, blackboard)
    blackboard:UpdatePerceptionRabbit(rabbit)
end

-----------------------------------------------------
-- LOOP UNIQUE
-----------------------------------------------------

RunService.Heartbeat:Connect(function()
    for i = #rabbits, 1, -1 do
        local data = rabbits[i]
        local rabbit = data.rabbit
        local blackboard = data.blackboard

        -- Clean si mort
        if not rabbit or not rabbit.Root or not rabbit.Model.Parent then
            table.remove(rabbits, i)
            continue
        end

        -- Décroissance faim
        rabbit.Satiety = math.max(0, rabbit.Satiety - (1 / 120))

        -- Log
        local satInt = math.floor(rabbit.Satiety)
        if satInt % 10 == 0 and satInt ~= (rabbit._lastLoggedSatiety or -1) then
            print(string.format("[RabbitBot] 🍽️ Faim: %.0f/100", rabbit.Satiety))
            rabbit._lastLoggedSatiety = satInt
        end

        -- BT
        UpdatePerception(rabbit, blackboard)
        tree:Run(rabbit, blackboard)
    end
end)

-----------------------------------------------------
-- API
-----------------------------------------------------

function RabbitBT.Start(rabbit)
    table.insert(rabbits, {
        rabbit = rabbit,
        blackboard = Blackboard.new()
    })
end


function RabbitBT.Stop(rabbit)
    for i, data in ipairs(rabbits) do
        if data.rabbit == rabbit then
            table.remove(rabbits, i)
            break
        end
    end
end

return RabbitBT