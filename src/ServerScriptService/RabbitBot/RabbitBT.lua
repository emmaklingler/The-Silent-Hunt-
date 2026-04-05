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
-- BEHAVIOUR TREE
-----------------------------------------------------

local tree = Selector.new({

    -- ======== PRIORITÉ 1 : FUIR ========
    -- Si le chasseur est visible → fuir immédiatement
    Sequence.new({
        HunterClose.new(),   -- vérifie si le chasseur est dans le rayon + ligne de vue
        Flee.new(),          -- fuite dans la direction opposée
    }),

    -- ======== PRIORITÉ 2 : MANGER ========
    -- Si le lapin a faim ET qu'une carotte est détectée → aller manger
    Sequence.new({
        IsHungry.new(),      -- Satiety < 70
        DetectCarrot.new(200), -- cherche dans workspace.Carrot, stocke dans blackboard
        GoToCarrot.new(),    -- se déplace vers bb.closestCarrot et mange
    }),

    -- ======== PRIORITÉ 3 : ERRER ========
    -- Fallback : se balader aléatoirement
    Wander.new(),
})

-----------------------------------------------------
-- PERCEPTION (mise à jour du blackboard chaque tick)
-----------------------------------------------------

local function UpdatePerception(rabbit, blackboard)
    blackboard:UpdatePerceptionRabbit(rabbit)
end

-----------------------------------------------------
-- START / STOP
-----------------------------------------------------

local connexion = nil

function RabbitBT.Start(rabbit)
    if connexion then
        connexion:Disconnect()
    end

    local blackboard = Blackboard.new()

    connexion = RunService.Heartbeat:Connect(function()
        if not rabbit or not rabbit.Root or not rabbit.Model.Parent then
            RabbitBT.Stop()
            return
        end

        -- Décroissance de la satiété
        rabbit.Satiety = math.max(0, rabbit.Satiety - (1 / 120))

        -- ← Log faim toutes les 10 unités
        local satInt = math.floor(rabbit.Satiety)
        if satInt % 10 == 0 and satInt ~= (rabbit._lastLoggedSatiety or -1) then
            print(string.format("[RabbitBot] 🍽️ Faim: %.0f/100", rabbit.Satiety))
            rabbit._lastLoggedSatiety = satInt
        end

        UpdatePerception(rabbit, blackboard)
        tree:Run(rabbit, blackboard)
    end)
end

function RabbitBT.Stop()
    if connexion then
        connexion:Disconnect()
        connexion = nil
    end
end

return RabbitBT