local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local HunterBT = script.Parent
local Node = HunterBT.BehaviourTree.Node

-- importations des modules
local Selector = require(Node.Utiles.Selector.Selector)
local Sequence = require(Node.Utiles.Sequence.Sequence)
local CanSeeTarget = require(Node.ConditionNode.CanSeeTarget)
local FollowTarget = require(Node.ActionNode.FollowTarget)
local Patrol = require(Node.ActionNode.Patrol)
local AttackTarget = require(Node.ActionNode.AttackTarget)

-- création de l'instance du chasseur
local HunterClass = require(HunterBT.Parent.Hunter.HunterClass)
local hunter = HunterClass.new(workspace:WaitForChild("Humans_Master_off"))

local bb = { lastTick = 0, tickRate = 0.2 }

-- création de la structure de l'arbre de comportement
local root = Selector.new({
    Sequence.new({
        CanSeeTarget.new(60),
        FollowTarget.new(6),
        AttackTarget.new(7, 1.2)
    }),
    Patrol.new(),
})

print("Systeme: cerveau du chasseur active")

-- boucle principale d'exécution
RunService.Heartbeat:Connect(function(dt)
    bb.dt = dt
    bb.lastTick += dt
    
    if bb.lastTick >= bb.tickRate then
        bb.lastTick = 0
        
        -- détection des joueurs possédant le tag IsRabbit
        local potentialTarget = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("IsRabbit") then
                potentialTarget = p.Character
                break
            end
        end
        
        hunter.Target = potentialTarget
        
        -- logs de diagnostic pour la cible
        if hunter.Target then
            print("Cible trouvee: " .. hunter.Target.Name)
        else
            -- ajout automatique du tag pour le test si personne n'est trouve
            local localPlayer = Players:GetPlayers()[1]
            if localPlayer and localPlayer.Character and not localPlayer.Character:FindFirstChild("IsRabbit") then
                local tag = Instance.new("BoolValue")
                tag.Name = "IsRabbit"
                tag.Parent = localPlayer.Character
                print("Debug: tag IsRabbit ajoute a " .. localPlayer.Name)
            end
        end

        -- exécution de l'arbre
        root:Run(hunter, bb)
    end
end)