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

local rabbits = {}

local function UpdatePerception(rabbit, blackboard)
    blackboard:UpdatePerceptionRabbit(rabbit)
end

RunService.Heartbeat:Connect(function()
    for i = #rabbits, 1, -1 do
        local data = rabbits[i]
        local rabbit = data.rabbit
        local blackboard = data.blackboard

        if not rabbit or not rabbit.Root or not rabbit.Model.Parent then
            table.remove(rabbits, i)
            continue
        end

        rabbit.Satiety = math.max(0, rabbit.Satiety - (1 / 120))

        local satInt = math.floor(rabbit.Satiety)
        if satInt % 10 == 0 and satInt ~= (rabbit._lastLoggedSatiety or -1) then
            print(string.format("[%s] 🍽️ Faim: %.0f/100", rabbit.Model.Name, rabbit.Satiety))
            rabbit._lastLoggedSatiety = satInt
        end

        UpdatePerception(rabbit, blackboard)
        
        data.tree:Run(rabbit, blackboard)  -- ← arbre propre à chaque bot
    end
end)

function RabbitBT.Start(rabbit)
    table.insert(rabbits, {
        rabbit = rabbit,
        blackboard = Blackboard.new(),
        tree = Selector.new({  -- ← arbre propre à chaque bot
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