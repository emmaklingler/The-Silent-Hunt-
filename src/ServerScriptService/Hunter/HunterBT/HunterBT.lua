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
local PatrolZone = require(Node.ActionNode.PatrolZone)
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
local MakeTrap = require(Node.ActionNode.MakeTrap)

local Blackboard = require(Node.Utiles.Blackboard)

-- Définit le blackboard pour le chasseur
local blackboard = Blackboard.new()

-- Définition de l'arbre de comportement du chasseur
-- local BT = Selector.new({

-- 	-- =========================
-- 	-- COMBAT (prioritaire)
-- 	-- =========================
-- 	MemorySequence.new({
-- 		HasTarget.new(), -- condition basée sur le blackboard
		
-- 		Selector.new({

-- 			-- close combat
-- 			Sequence.new({
-- 				InRange.new(0, 8),
-- 				CloseAttack.new(),
-- 			}),

-- 			-- ranged combat
-- 			MemorySequence.new({
-- 				InRange.new(8, 80),
-- 				RangedAttack.new(),
-- 			}),


-- 			-- sinon → follow
-- 			FollowTarget.new(),
-- 		}),
-- 	}),

-- 	-- =========================
--     -- SUIVRE DERNIÈRE POSITION
--     -- =========================
--     Sequence.new({
--         HasLastSeenPosition.new(),
--         FollowTarget.new()
--        	MakeTrap.new(6), -- pose un piège à la dernière position vue si on est proche (ex: pour couvrir une fuite)
--     }),

-- 	-- =========================
-- 	-- SURVIE / LOGISTIQUE
-- 	-- =========================
-- 	Sequence.new({
-- 		NeedsReload.new(),
-- 		ReloadWeapon.new(),
-- 	}),

-- 	Sequence.new({
-- 		NeedsMunitions.new(),
-- 		GetMunitions.new(),
-- 	}),

-- 	-- =========================
-- 	-- PATROUILLE
-- 	-- =========================
-- 	PatrolZone.new(),
-- })

local BT = Selector.new({

	-- 1️⃣ Si la cible est encore visible → on la suit (pas de piège)
	Sequence.new({
		HasTarget.new(),
		FollowTarget.new(),
	}),

	-- 2️⃣ Si la cible est PERDUE mais mémorisée
	MemorySequence.new({
		HasLastSeenPosition.new(),

		-- va à la dernière position connue
		FollowTarget.new(),

		-- pose UN piège (grâce au flag blackboard)
		MakeTrap.new(12),
	}),
})

local PerceptionVision = DetectionVision.new(150)
local function PerceptionUpdate(hunter)
	PerceptionVision:Run(hunter, blackboard)
end

local connexion = nil
function HunterBT.Start(hunter)
	connexion = RunService.Heartbeat:Connect(function()
		PerceptionUpdate(hunter)
		BT:Run(hunter, blackboard)
	end)
end

function HunterBT.Stop()
	connexion:Disconnect()
end


return HunterBT
