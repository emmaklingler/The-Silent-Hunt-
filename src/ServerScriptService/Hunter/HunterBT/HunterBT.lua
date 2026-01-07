local HunterBT = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- importations des modules
local Node = game.ServerScriptService:WaitForChild("BehaviourTree"):WaitForChild("Node")
local Selector = require(Node.Utiles.Selector)
local WeightedSelector = require(Node.Utiles.WeightedSelector)
local Sequence = require(Node.Utiles.Sequence)



local FollowTarget = require(Node.ActionNode.FollowTarget)
local Patrol = require(Node.ActionNode.Patrol)
local CloseAttack = require(Node.ActionNode.CloseAttack)
local RangedAttack = require(Node.ActionNode.RangedAttack)
local NeedsReload = require(Node.ConditionNode.NeedsReload)
local ReloadWeapon = require(Node.ActionNode.ReloadWeapon)
local NeedsMunitions = require(Node.ConditionNode.NeedsMunitions)
local GetMunitions = require(Node.ActionNode.GetMunitions)
local DetectionAround = require(Node.ConditionNode.DetectionAround)
local DetectionVision = require(Node.ConditionNode.DetectionVision)



local Blackboard = require(Node.Utiles.Blackboard)

-- Définit le blackboard pour le chasseur
local blackboard = Blackboard.new()

-- Définition de l'arbre de comportement du chasseur
local BT = Selector.new({

 
 
   
    --  ATTAQUE AU CORPS À CORPS
    Sequence.new({
        DetectionAround.new(8),
        CloseAttack.new(),
    }),
    

    --  RECHARGER L'ARME
    Sequence.new({
        NeedsReload.new(),
        ReloadWeapon.new(),
    }),

    --  ATTAQUE À DISTANCE
    Sequence.new({
        DetectionVision.new(50),
        RangedAttack.new(),
    }),

    --  SUIVRE LA CIBLE
    Sequence.new({
        DetectionVision.new(100),
        FollowTarget.new(),
    }),

       --  RAVITAILLEMENT EN MUNITIONS
    Sequence.new({
        NeedsMunitions.new(),
        GetMunitions.new(),
    }),

    --  PATROUILLE
    Patrol.new(),
}) 


--[[
    Initialise et démarre l'arbre de comportement du chasseur
    @param hunter: classe du chasseur
]]
function HunterBT.Start(hunter)
    -- Boucle de mise à jour de l'arbre de comportement
    RunService.Heartbeat:Connect(function()
        BT:Run(hunter, blackboard)
    end)
end

return HunterBT