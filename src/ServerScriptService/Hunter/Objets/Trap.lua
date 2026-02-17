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
local AssetFolder = ServerStorage:WaitForChild("Asset")
local TrapFolderModel = AssetFolder:WaitForChild("Trap")

----------------------------------------------------------
-- Utils
----------------------------------------------------------
local function SetupTrapModel(model)
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true         
			part.CanCollide = false
			part.CanTouch = false
		end
	end
end

-- 🔑 colle le modèle AU SOL, pas au pivot
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
	print("new TRAP at", position)
	local self = setmetatable({}, Trap)

	self.Hunter = hunter
	self.IsActive = true

	-- spawn visuel OUVERT
	self.Model = TrapFolderModel.TrapOpen:Clone()
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

	for _, part in parts do
		local model = part:FindFirstAncestorWhichIsA("Model")
		if model and model ~= self.Hunter.Model then
			local char = Players:GetPlayerFromCharacter(model)
			local rabbit = PlayerManager:GetRabbit(char)

			if rabbit and rabbit.Health > 0 then
				self:Trigger(rabbit)
				return
			end
		end
	end
end

----------------------------------------------------------
-- Trigger
----------------------------------------------------------
function Trap:Trigger(rabbit)
	if not self.IsActive then return end
	self.IsActive = false

	------------------------------------------------------
	-- DÉGÂTS via ta logique Rabbit
	------------------------------------------------------
	rabbit:RemoveHealth(50)

	------------------------------------------------------
	-- Visuel fermé
	------------------------------------------------------
	local closed = TrapFolderModel.TrapClose:Clone()
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