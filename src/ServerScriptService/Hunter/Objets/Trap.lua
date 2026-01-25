-- Trap.lua
local Trap = {}
Trap.__index = Trap

local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local trapTemplate = ServerStorage:WaitForChild("Asset"):WaitForChild("Trap")

-- (optionnel) seed pour IDs random
math.randomseed(os.clock() * 1000000)

function Trap.new(hunter, position)
	local self = setmetatable({}, Trap)

	self.Hunter = hunter
	self.Position = position

	self.Part = trapTemplate:Clone()
	self.Part.Position = position
	self.Part.Parent = Workspace

	self.IsActive = true

	-- ID serveur-safe (pas de GetDebugId)
	self.Id = string.format("%s_%d_%d",
		(hunter.Model and hunter.Model.Name) or "Hunter",
		math.floor(os.clock() * 1000),
		math.random(1, 1e9)
	)

	-- réglages
	self.boxSize = Vector3.new(6, 4, 6)
	self.damage = 15

	return self
end

function Trap:Check()
	if not self.IsActive or not self.Part or not self.Part.Parent then
		return false
	end

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { self.Part, self.Hunter.Model }

	local parts = Workspace:GetPartBoundsInBox(self.Part.CFrame, self.boxSize, params)

	for _, p in ipairs(parts) do
		local model = p:FindFirstAncestorOfClass("Model")
		if model then
			local hum = model:FindFirstChildOfClass("Humanoid")
			local hrp = model:FindFirstChild("HumanoidRootPart")

			-- ✅ évite de te taper le chasseur lui-même (au cas où)
			if hum and hrp and model ~= self.Hunter.Model then
				print("[TRAP] Triggered on:", model.Name, "trapId=", self.Id)

				hum:TakeDamage(self.damage)
				self:Destroy()

				return true
			end
		end
	end

	return false
end

function Trap:Destroy()
	self.IsActive = false
	if self.Part and self.Part.Parent then
		self.Part:Destroy()
	end
	self.Part = nil
end

return Trap
