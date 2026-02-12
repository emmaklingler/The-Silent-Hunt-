local MakeTrap = {}
MakeTrap.__index = MakeTrap

local Status = require(script.Parent.Parent.Utiles.Status)

function MakeTrap.new(arriveRadius)
	local self = setmetatable({}, MakeTrap)
	self.arriveRadius = arriveRadius or 6
	return self
end

function MakeTrap:Run(chasseur, blackboard)

	-- cooldown anti spam BT
	if blackboard.trapCooldownUntil
		and os.clock() < blackboard.trapCooldownUntil then
		return Status.FAILURE
	end

	-- conditions
	if blackboard:HasValidTarget() then
		return Status.FAILURE
	end

	if not blackboard:HasMemory() then
		return Status.FAILURE
	end

	if (chasseur.trapsStock or 0) <= 0 then
		blackboard.trapCooldownUntil = os.clock() + 5
		return Status.FAILURE
	end

	local pos = blackboard.lastKnownPosition
	if not pos then return Status.FAILURE end

	-- attente arrivée
	local dist = (chasseur.Root.Position - pos).Magnitude
	if dist > self.arriveRadius then
		return Status.RUNNING
	end

	-- pose
	local ok = chasseur:TryPlaceTrapAt(pos)
	if ok then
		if blackboard.ClearMemory then
			blackboard:ClearMemory()
		else
			blackboard.lastKnownPosition = nil
		end

		blackboard.trapCooldownUntil = os.clock() + 3
		return Status.SUCCESS
	end

	blackboard.trapCooldownUntil = os.clock() + 2
	return Status.FAILURE
end

return MakeTrap
