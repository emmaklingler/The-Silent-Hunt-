local HunterBT = {}
HunterBT.__index = HunterBT

local RunService = game:GetService("RunService")

-- Import modules
local Node = game.ServerScriptService:WaitForChild("BehaviourTree"):WaitForChild("Node")
local HunterUtility = require(script.Parent.HunterUtility)

local WeightedSelector = require(Node.Utiles.WeightedSelector)
local Sequence = require(Node.Utiles.Sequence)
local MemorySequence = require(Node.Utiles.MemorySequence)

local FollowTarget = require(Node.ActionNode.FollowTarget)
local PatrolZone = require(Node.ActionNode.PatrolZone)
local CloseAttack = require(Node.ActionNode.CloseAttack)
local RangedAttack = require(Node.ActionNode.RangedAttack)
local ReloadWeapon = require(Node.ActionNode.ReloadWeapon)
local GetMunitions = require(Node.ActionNode.GetMunitions)
local MakeTrap = require(Node.ActionNode.MakeTrap)

local InRange = require(Node.ConditionNode.InRange)

local DetectionVision = require(Node.Perception.DetectionVision)
local Blackboard = require(Node.Utiles.Blackboard)

-----------------------------------------------------
-- BLACKBOARD (un seul hunter → OK global)
-----------------------------------------------------

local blackboard = Blackboard.new()

-----------------------------------------------------
-- BEHAVIOUR TREE
-----------------------------------------------------

local BT2 = WeightedSelector.new({

	-- ================= COMBAT =================

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

	-- ================= LOGISTIQUE =================

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
		block = false,
		priority = 0,
		node = GetMunitions.new(),
	},

	{
		nom = "PoursuitePosition",
		weight = function()
			return blackboard:GetPoids("PoursuitePosition")
		end,
		block = false,
		priority = 1,
		node = FollowTarget.new(),
	},

	{
		nom = "PlacePiege",
		weight = function()
			return blackboard:GetPoids("PlacePiege")
		end,
		block = true,
		priority = 2,
		node = MakeTrap.new(),
	},

	-- ================= EXPLORATION =================

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

-----------------------------------------------------
-- POIDS
-----------------------------------------------------

local function CalculePoids(hunter)
	local poids = HunterUtility.CalculePoids(hunter, blackboard)
	blackboard:SetPoids(poids)
end

local delay = 0.25
local lastUpdate = 0

local function UpdatePoids(hunter)
	if (tick() - lastUpdate) < delay then
		return
	end

	lastUpdate = tick()

	blackboard:UpdatePerception(hunter)
	CalculePoids(hunter)
end

-----------------------------------------------------
-- PERCEPTION
-----------------------------------------------------

local PerceptionVision = DetectionVision.new(200)

local function PerceptionUpdate(hunter)
	PerceptionVision:Run(hunter, blackboard)
end

-----------------------------------------------------
-- START / STOP
-----------------------------------------------------

local connexion = nil

function HunterBT.Start(hunter)

	if connexion then
		connexion:Disconnect()
	end

	connexion = RunService.Heartbeat:Connect(function()

		if not hunter or not hunter.Root then
			return
		end

		UpdatePoids(hunter)
		PerceptionUpdate(hunter)
		BT2:Run(hunter, blackboard)

	end)
end

function HunterBT.Stop()
	if connexion then
		connexion:Disconnect()
		connexion = nil
	end
end

return HunterBT
