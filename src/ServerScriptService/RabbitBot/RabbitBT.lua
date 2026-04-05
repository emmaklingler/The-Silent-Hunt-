local RabbitBT = {}
RabbitBT.__index = RabbitBT

local RunService = game:GetService("RunService")
local Node = game.ServerScriptService:WaitForChild("BehaviourTree"):WaitForChild("Node")

local Selector = require(Node.Utiles.Selector)
local Blackboard = require(Node.Utiles.Blackboard)
local Status = require(Node.Utiles.Status)

local Wander = require(Node.ActionNode.Wander)
local EatCarrot = require(Node.ActionNode.EatCarrot)
local DetectCarrot = require(Node.Perception.DetectCarrot)

function RabbitBT.new(rabbit)
    local self = setmetatable({}, RabbitBT)
    self.rabbit = rabbit
    self.blackboard = Blackboard.new()
    self.blackboard:InitRabbitData() 
    
    self.perceptionCarrot = DetectCarrot.new(60)
    self.connexion = nil

    local eatActionNode = EatCarrot.new()
    local wanderActionNode = Wander.new()

    self.tree = Selector.new({
        
        -- PRIORITÉ 1 : LA FUITE
        {
            Run = function(_, r, bb)
                if bb.hunterRoot then
                    r.wanderTarget = nil -- Reset wander si on a peur
                    return r:TryFlee(bb.hunterRoot.Position)
                end
                return Status.FAILURE
            end
        },

        -- PRIORITÉ 2 : MANGER
        {
            Run = function(_, r, bb)
                if r.Satiety < 60 and bb.closestCarrot then
                    r.wanderTarget = nil -- Reset wander si on va manger
                    return eatActionNode:Run(r, bb)
                end
                return Status.FAILURE
            end
        },

        -- PRIORITÉ 3 : ERRER
        {
            Run = function(_, r, bb)
                return wanderActionNode:Run(r, bb)
            end
        }
    })

    return self
end

function RabbitBT:Start()
    if self.connexion then self.connexion:Disconnect() end
    print("🚀 [BT] Cerveau du lapin démarré.")

    self.connexion = RunService.Heartbeat:Connect(function()
        local rabbit = self.rabbit
        if not rabbit or not rabbit.Root or not rabbit.Model.Parent then 
            self:Stop()
            return 
        end

        -- Cycle de faim
        rabbit.Satiety = math.max(0, rabbit.Satiety - 0.015)

        -- Logs de diagnostic toutes les 5 secondes
        if math.floor(os.clock() % 5) == 0 and not self._lastLog then
            print(string.format("📊 [DEBUG] Faim: %.1f | Cible: %s", rabbit.Satiety, self.blackboard.closestCarrot and "Carotte" or "Rien"))
            self._lastLog = true
        elseif math.floor(os.clock() % 5) ~= 0 then
            self._lastLog = false
        end

        -- Perception
        self.perceptionCarrot:Run(rabbit, self.blackboard)
        self.blackboard:UpdatePerceptionRabbit(rabbit)

        -- Exécution
        self.tree:Run(rabbit, self.blackboard)
    end)
end

function RabbitBT:Stop()
    if self.connexion then
        self.connexion:Disconnect()
        self.connexion = nil
    end
end

return RabbitBT