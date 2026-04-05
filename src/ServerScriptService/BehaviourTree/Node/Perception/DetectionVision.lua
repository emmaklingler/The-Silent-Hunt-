local DetectionVision = {}
DetectionVision.__index = DetectionVision

local Status = require(script.Parent.Parent.Utiles.Status)
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local COS_HALF_FOV = math.cos(math.rad(100))

local LOCK_DURATION = 3
local SWITCH_THRESHOLD = 0.7

function DetectionVision.new(distance)
	return setmetatable({
		distanceMax = distance
	}, DetectionVision)
end

function DetectionVision:Run(chasseur, blackboard)
	if not chasseur.Root then
		return Status.FAILURE
	end

	local origin = chasseur.Root.Position
	local forward = chasseur.Root.CFrame.LookVector

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { chasseur.Model }

	local visibleTargets = {}

	for _, rabbit in PlayerManager:GetAllTargets() do
		if rabbit.Root and rabbit:IsAlive() and not rabbit:DansCachette() then
			
			local toTarget = rabbit.Root.Position - origin
			local dist = toTarget.Magnitude

			if dist <= self.distanceMax then
				local dir = toTarget.Unit
				local dot = forward:Dot(dir)

				if dot >= COS_HALF_FOV then
					local result = workspace:Raycast(origin, toTarget, params)

					if result and result.Instance:IsDescendantOf(rabbit.Model) then
						table.insert(visibleTargets, {
							target = rabbit,
							distance = dist
						})
					end
				end
			end
		end
	end

	if #visibleTargets == 0 then
		blackboard:UnsetSeenTarget()
		return Status.FAILURE
	end

	table.sort(visibleTargets, function(a, b)
		return a.distance < b.distance
	end)

	local bestTarget = visibleTargets[1].target
	local bestDistance = visibleTargets[1].distance

	local currentTarget = blackboard.target
	local lockTime = blackboard.targetLockTime or 0
	local now = os.clock()

	if currentTarget and currentTarget:IsAlive() then
		
		local currentData = nil
		for _, data in visibleTargets do
			if data.target == currentTarget then
				currentData = data
				break
			end
		end

		if currentData then
			local currentDistance = currentData.distance

			if now < lockTime then
				return Status.SUCCESS
			end

			if bestTarget ~= currentTarget then
				if bestDistance < currentDistance * SWITCH_THRESHOLD then
					blackboard:SetSeenTarget(bestTarget)
					blackboard.targetLockTime = now + LOCK_DURATION
				end
			end

			return Status.SUCCESS
		end
	end

	blackboard:SetSeenTarget(bestTarget)
	blackboard.targetLockTime = now + LOCK_DURATION

	return Status.SUCCESS
end

return DetectionVision