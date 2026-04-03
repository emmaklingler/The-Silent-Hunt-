local DetectNoises = {}
DetectNoises.__index = DetectNoises

local Status = require(script.Parent.Parent.Utiles.Status)
local NoiseEvent = game.ReplicatedStorage.Remote:WaitForChild("NoiseServerEvent")

-- Stockage global des bruits récents
local noises = {}

-- On écoute les bruits
NoiseEvent.Event:Connect(function(data)
	table.insert(noises, data)
end)

function DetectNoises.new(range)
	return setmetatable({
		hearingRadius = range
	}, DetectNoises)
end

function DetectNoises:Run(chasseur, blackboard)
	if not chasseur.Root then
		return Status.FAILURE
	end

	local now = os.clock()
	local origin = chasseur.Root.Position

	local bestNoise = nil
	local bestScore = math.huge

	for i = #noises, 1, -1 do
		local noise = noises[i]

		-- Nettoyage vieux bruits
		if now - noise.time > 4 then
			table.remove(noises, i)
			continue
		end

		local dist = (origin - noise.position).Magnitude

		if dist <= self.hearingRadius then
			if dist < bestScore then
				bestScore = dist
				bestNoise = noise
			end
		end
	end

	if not bestNoise then
		return Status.FAILURE
	end

	if blackboard.hasVisual then
		return Status.FAILURE
	end
	if blackboard:HasMemory() and blackboard.lastStimulusType == "Noise" then
		return Status.FAILURE
	end
	-- Push stimulus SANS target
	blackboard:PushStimulus({
		type = "Noise",
		position = bestNoise.position,
		time = bestNoise.time
	})

	return Status.SUCCESS
end

return DetectNoises