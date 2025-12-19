--- AttackTarget.lua 
local Node = script.Parent
assert(Node, "Selector.lua has no parent")

local Utiles = Node.Parent
assert(Utiles, "Selector.lua must be inside a folder under Utiles")

local StatusFolder = Utiles:WaitForChild("Status")
local Status = require(StatusFolder:WaitForChild("Status"))

local FollowTarget = {}
FollowTarget.__index = FollowTarget

function FollowTarget.new(stopDist)
	return setmetatable({ stopDist = stopDist or 6 }, FollowTarget)
end

local AttackTarget = {}
AttackTarget.__index = AttackTarget

function AttackTarget.new(range, cooldown)
	return setmetatable({
		range = range or 5,
		cooldown = cooldown or 1.2,
		lastAttack = 0,
	}, AttackTarget)
end

function AttackTarget:Run(hunter, bb)
	if not hunter.Target or not hunter.Target.PrimaryPart then
		return Status.FAILURE
	end

	local dist = hunter:GetDistanceTo(hunter.Target)
	if dist > self.range then
		return Status.FAILURE
	end

	self.lastAttack += (bb.dt or 0)
	if self.lastAttack < self.cooldown then
		return Status.RUNNING
	end

	self.lastAttack = 0
	print("Chasseur attaque chasse !")

	return Status.SUCCESS
end

return AttackTarget
