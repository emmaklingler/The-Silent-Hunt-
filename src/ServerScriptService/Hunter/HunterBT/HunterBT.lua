local HunterBT = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- importations des modules
local Node = game.ServerScriptService:WaitForChild("BehaviourTree"):WaitForChild("Node")
local HunterUtility = require(script.Parent.HunterUtility)

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
local BT2 = WeightedSelector.new({

	-- =========================
	-- COMBAT
	-- =========================
	{
		nom = "AttaquePied",
		weight = function()
			return blackboard:GetPoids("AttaquePied")
		end,
		block = true,
		priority = 3,
		node = Sequence.new({
			InRange.new(0, 8),
			CloseAttack.new(),
		}),
	},

	{
		nom = "Tir",
		weight = function()
			return blackboard:GetPoids("Tir")
		end,
		block = true,
		priority = 4,
		node = MemorySequence.new({
			InRange.new(0, 120),
			RangedAttack.new(),
		}),
	},

	{
		nom = "Poursuite",
		weight = function()
			return blackboard:GetPoids("Poursuite")
		end,
		block = false,
		priority = 1,
		node = FollowTarget.new(),
	},

	

	-- =========================
	-- LOGISTIQUE / SURVIE
	-- =========================

	{
		nom = "Recharge",
		weight = function()
			return blackboard:GetPoids("Recharge")
		end,
		block = true,
		priority = 2,
		node = ReloadWeapon.new(),
	},

	{
		nom = "ChercheMunitions",
		weight = function()
			return blackboard:GetPoids("ChercheMunitions")
		end,
		block = true,
		priority = 1,
		node = GetMunitions.new(),
	},

	{
		nom = "PoursuitePosition",
		weight = function()
			return blackboard:GetPoids("PoursuitePosition")
		end,
		block = false,
		priority = 1,
		node = FollowTarget.new()
	},

	{
		nom = "PlacePiege",
		weight = function()
			return blackboard:GetPoids("PlacePiege")
		end,
		block = true,
		priority = 2,
		node = MakeTrap.new()
	},


	-- =========================
	-- EXPLORATION
	-- =========================
	{
		nom = "Exploration",
		weight = function()
			return blackboard:GetPoids("Exploration")
		end,
		block = false,
		priority = 0,
		node = PatrolZone.new(),
	},
})


local function CalculePoids(hunter, blackboard)
	local poids = HunterUtility.CalculePoids(hunter, blackboard) -- recalcule les poids en fonction de la situation actuelle
	blackboard:SetPoids(poids)
end


local delay = 0.25
local lastUpdate = 0
local function UpdatePoids(hunter, blackboard)
	if (tick() - lastUpdate) < delay then
		return
	end
	lastUpdate = tick()
	blackboard:UpdatePerception(hunter) -- met à jour les données de perception (distance, vie, etc.)
	CalculePoids(hunter, blackboard) -- recalcule les poids en fonction de la situation actuelle
end

local PerceptionVision = DetectionVision.new(200)
local function PerceptionUpdate(hunter)
	PerceptionVision:Run(hunter, blackboard)
end


local connexion = nil
function HunterBT.Start(hunter)
	connexion = RunService.Heartbeat:Connect(function()
		UpdatePoids(hunter, blackboard)
		PerceptionUpdate(hunter)
		BT2:Run(hunter, blackboard)
	end)
end

function HunterBT.Stop()
	connexion:Disconnect()
end


return HunterBT
