local HunterBT = {}
local RunService = game:GetService("RunService")

local Node = game.ServerScriptService:WaitForChild("BehaviourTree"):WaitForChild("Node")

local WeightedSelector = require(Node.Utiles.WeightedSelector)
local Sequence = require(Node.Utiles.Sequence)

local CanSeeTarget = require(Node.ConditionNode.CanSeeTarget)
local NeedsReload  = require(Node.ConditionNode.NeedsReload)
local NeedsMunitions = require(Node.ConditionNode.NeedsMunitions)

local FollowTarget = require(Node.ActionNode.FollowTarget)
local Patrol = require(Node.ActionNode.Patrol)
local CloseAttack = require(Node.ActionNode.CloseAttack)
local RangedAttack = require(Node.ActionNode.RangedAttack)
local GetMunitions = require(Node.ActionNode.GetMunitions)
local ReloadWeapon = require(Node.ActionNode.ReloadWeapon)

local Blackboard = require(Node.Utiles.Blackboard)
local blackboard = Blackboard.new()

<<<<<<< HEAD
local BT = WeightedSelector.new({
=======
-- Définition de l'arbre de comportement du chasseur
local BT =  Selector.new({
    
    Sequence.new({
        CanSeeTarget.new(10),
        CloseAttack.new()
    }),
    -- Arbre simple ici, si le chasseur peut voir une cible, il la suit et l'attaque, sinon il patrouille
    Sequence.new({
        CanSeeTarget.new(100),
        FollowTarget.new()
    }),
    Patrol.new()
>>>>>>> 0f205542ae3acde7299e54d7f49577686a8352d3

	{
		key = "REFILL",
		node = Sequence.new({
			NeedsMunitions.new(),
			GetMunitions.new(),
		}),
		weight = function(hunter, bb)
			return hunter:NeedsMunitions() and 1000 or 0
		end
	},

	{
		key = "RELOAD",
		node = Sequence.new({
			NeedsReload.new(),
			ReloadWeapon.new(),
		}),
		weight = function(hunter, bb)
			return (hunter:NeedsReload() and hunter:CanReload()) and 600 or 0
		end
	},

	{
		key = "CLOSE",
		node = Sequence.new({
			CanSeeTarget.new(8),
			CloseAttack.new(),
		}),
		weight = function(hunter, bb)
			-- si on a déjà une target et qu’elle est proche, on priorise fort
			local t = bb.target
			if t and t.Root and hunter.Root then
				local d = (t.Root.Position - hunter.Root.Position).Magnitude
				return (d <= 8) and 500 or 0
			end
			return 200 -- sinon ça peut tenter CanSeeTarget, mais moins
		end
	},

	{
		key = "RANGED",
		node = Sequence.new({
			CanSeeTarget.new(50),
			RangedAttack.new(),
		}),
		weight = function(hunter, bb)
			-- si pas de munitions, ranged ne sert à rien
			if hunter:NeedsMunitions() then return 0 end
			return 300
		end
	},

	{
		key = "FOLLOW",
		node = Sequence.new({
			CanSeeTarget.new(100),
			FollowTarget.new(),
		}),
		weight = function(hunter, bb)
			-- si on a déjà une target, follow devient pertinent
			return (bb.target ~= nil) and 220 or 120
		end
	},

	{
		key = "PATROL",
		node = Patrol.new(),
		weight = 10
	},
})

function HunterBT.Start(hunter)
	RunService.Heartbeat:Connect(function()
		BT:Run(hunter, blackboard)
	end)
end

return HunterBT
