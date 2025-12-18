-- DebugSpectate.client.lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 🔎 Trouve le chasseur
local function getHunter()
	return workspace:FindFirstChild("Humans_Master")
end

-- 🔎 Trouve le lapin (joueur)
local function getRabbit()
	local char = player.Character
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid") or char.PrimaryPart
end

-- 🎥 Spectate un modèle
local function spectateModel(model)
	if not model then return end

	local part =
		model.PrimaryPart
		or model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("RootPart")

	if not part then
		warn("❌ Impossible de spectate :", model.Name)
		return
	end

	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = part
end

-- 🎮 Inputs
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	-- F6 = spectate chasseur
	if input.KeyCode == Enum.KeyCode.F6 then
		print("👁️ Spectate Hunter")
		spectateModel(getHunter())
	end

	-- F7 = retour joueur
	if input.KeyCode == Enum.KeyCode.F7 then
		print("👤 Retour joueur")
		local subject = getRabbit()
		if subject then
			camera.CameraSubject = subject
		end
	end
end)
