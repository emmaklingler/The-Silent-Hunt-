-- Trap.lua
local Trap = {}
Trap.__index = Trap

local Players = game:GetService("Players")
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

----------------------------------------------------------
-- Folder monde
----------------------------------------------------------
local TrapsFolder = Workspace:FindFirstChild("Traps")
if not TrapsFolder then
	TrapsFolder = Instance.new("Folder")
	TrapsFolder.Name = "Traps"
	TrapsFolder.Parent = Workspace
end

----------------------------------------------------------
-- Assets
----------------------------------------------------------
local TrapFolder = ServerStorage:WaitForChild("Asset"):WaitForChild("Trap")
local TrapOpenTemplate = TrapFolder:WaitForChild("BearTrap_Open")
local TrapClosedTemplate = TrapFolder:WaitForChild("BearTrap_Closed")

----------------------------------------------------------
-- Utils
----------------------------------------------------------
local function SetupTrapModel(model)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = true
		end
	end
end

local function SnapModelToGround(model, groundPos)
	local _, size = model:GetBoundingBox()
	model:PivotTo(CFrame.new(
		groundPos.X,
		groundPos.Y + size.Y / 2,
		groundPos.Z
	))
end

local function GetRabbitFromHumanoid(humanoid)
	if not humanoid then return nil end

	local model = humanoid.Parent
	if not model then return nil end

	local player = Players:GetPlayerFromCharacter(model)
	if not player then return nil end

	return PlayerManager:GetRabbit(player)
end

----------------------------------------------------------
-- Constructor
----------------------------------------------------------
function Trap.new(hunter, position)
	local self = setmetatable({}, Trap)

	self.Hunter = hunter
	self.IsActive = true

	-- Spawn modèle ouvert
	self.Model = TrapOpenTemplate:Clone()
	self.Model.Parent = TrapsFolder
	SnapModelToGround(self.Model, position)
	SetupTrapModel(self.Model)

	-- Zone détection
	self.boxSize = Vector3.new(6, 3, 6)
	self.boxOffset = Vector3.new(0, 1.5, 0)

	-- Loop détection
	task.spawn(function()
		while self.IsActive and self.Model and self.Model.Parent do
			self:Check()
			task.wait(0.15)
		end
	end)

	return self
end

----------------------------------------------------------
-- Detection
----------------------------------------------------------
function Trap:Check()
	if not self.IsActive or not self.Model or not self.Model.Parent then
		return
	end

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {
		self.Model,
		self.Hunter and self.Hunter.Model,
		TrapsFolder
	}

	local cf = self.Model:GetPivot() * CFrame.new(self.boxOffset)

	local parts = Workspace:GetPartBoundsInBox(
		cf,
		self.boxSize,
		params
	)

	for _, part in ipairs(parts) do
		local model = part:FindFirstAncestorWhichIsA("Model")
		if model and model ~= (self.Hunter and self.Hunter.Model) then
			local hum =
				model:FindFirstChildOfClass("Humanoid")
				or model:FindFirstChild("Humanoid", true)

			if hum and hum.Health > 0 then
				self:Trigger(hum)
				return
			end
		end
	end
end

----------------------------------------------------------
-- Trigger
----------------------------------------------------------
function Trap:Trigger(humanoid)
	if not self.IsActive then return end
	self.IsActive = false

	------------------------------------------------------
	-- DÉGÂTS via ta logique Rabbit
	------------------------------------------------------
	local rabbit = GetRabbitFromHumanoid(humanoid)

	if rabbit then
		rabbit:RemoveHealth(30)
		print("[TRAP] Rabbit touché :", rabbit.Player.Name)
	else
		warn("[TRAP] Humanoid touché mais aucun Rabbit trouvé")
	end

	------------------------------------------------------
	-- Visuel fermé
	------------------------------------------------------
	local closed = TrapClosedTemplate:Clone()
	closed.Parent = TrapsFolder
	closed:PivotTo(self.Model:GetPivot())
	SetupTrapModel(closed)

	self.Model:Destroy()
	self.Model = closed

	------------------------------------------------------
	-- Auto destruction
	------------------------------------------------------
	task.delay(5, function()
		if self.Model then
			self.Model:Destroy()
			self.Model = nil
		end
	end)

	------------------------------------------------------
	-- Rendre piège au chasseur
	------------------------------------------------------
	if self.Hunter and self.Hunter.RecoverTrap then
		self.Hunter:RecoverTrap()
	end
end

return Trap
