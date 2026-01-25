local HunterBT = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- importations des modules
local Node = game.ServerScriptService:WaitForChild("BehaviourTree"):WaitForChild("Node")
local Selector = require(Node.Utiles.Selector)
local WeightedSelector = require(Node.Utiles.WeightedSelector)
local Sequence = require(Node.Utiles.Sequence)
local MemorySequence = require(Node.Utiles.MemorySequence)

local FollowTarget = require(Node.ActionNode.FollowTarget)
local Patrol = require(Node.ActionNode.Patrol)
local CloseAttack = require(Node.ActionNode.CloseAttack)
local RangedAttack = require(Node.ActionNode.RangedAttack)
local ReloadWeapon = require(Node.ActionNode.ReloadWeapon)
local GetMunitions = require(Node.ActionNode.GetMunitions)

local NeedsReload = require(Node.ConditionNode.NeedsReload)
local NeedsMunitions = require(Node.ConditionNode.NeedsMunitions)
local InRange = require(Node.ConditionNode.InRange)
local HasTarget = require(Node.ConditionNode.HasTarget)
local HasLastSeenPosition = require(Node.ConditionNode.HasLastSeenPosition)

local DetectionVision = require(Node.Perception.DetectionVision)



local Blackboard = require(Node.Utiles.Blackboard)

-- Définit le blackboard pour le chasseur
local blackboard = Blackboard.new()

-- Définition de l'arbre de comportement du chasseur
local BT = Selector.new({

	-- =========================
	-- COMBAT (prioritaire)
	-- =========================
	MemorySequence.new({
		HasTarget.new(), -- condition basée sur le blackboard
		
		Selector.new({

			-- close combat
			Sequence.new({
				InRange.new(0, 8),
				CloseAttack.new(),
			}),

			-- ranged combat
			MemorySequence.new({
				InRange.new(8, 80),
				RangedAttack.new(),
			}),

			-- sinon → follow
			FollowTarget.new(),
		}),
	}),
	
    Sequence.new({
        HasLastSeenPosition.new(), -- condition basée sur le blackboard
        
        FollowTarget.new(),
    }),

	-- =========================
	-- SURVIE / LOGISTIQUE
	-- =========================
	Sequence.new({
		NeedsReload.new(),
		ReloadWeapon.new(),
	}),

	Sequence.new({
		NeedsMunitions.new(),
		GetMunitions.new(),
	}),

	-- =========================
	-- PATROUILLE
	-- =========================
	Patrol.new(),
})


local PerceptionVision = DetectionVision.new(150)
local function PerceptionUpdate(hunter)
    PerceptionVision:Run(hunter, blackboard)
end

--[[
    Initialise et démarre l'arbre de comportement du chasseur
    @param hunter: classe du chasseur
]]
function HunterBT.Start(hunter)
    -- Boucle de mise à jour de l'arbre de comportement
    RunService.Heartbeat:Connect(function()
        PerceptionUpdate(hunter)
        BT:Run(hunter, blackboard)
    end)
end

return HunterBT