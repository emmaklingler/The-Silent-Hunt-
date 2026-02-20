-- local Players = game:GetService("Players")
-- local UserInputService = game:GetService("UserInputService")

-- local player = Players.LocalPlayer
-- local camera = workspace.CurrentCamera

-- -- Verrouille la caméra en vue première personne

-- -- Change la cible de la caméra au respawn
-- player.CharacterAdded:Connect(function(character)
--     local humanoid = character:WaitForChild("Humanoid")
--     camera.CameraType = Enum.CameraType.Custom
--     camera.CameraSubject = humanoid
-- end)

-- -- Empêche le joueur de changer le mode de la caméra
-- player:GetPropertyChangedSignal("CameraMode"):Connect(function()
-- 	if player.CameraMode ~= Enum.CameraMode.LockFirstPerson then
-- 		player.CameraMode = Enum.CameraMode.LockFirstPerson
-- 	end
-- end)


-- -- Activer FPS
-- local function EnableFPSMouse()
--     player.CameraMode = Enum.CameraMode.LockFirstPerson
--     UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
--     UserInputService.MouseIconEnabled = false
-- end


-- --task.delay(5, EnableFPSMouse)


-- --[[
-- -- Désactiver FPS (menu, pause, etc)
-- local function DisableFPSMouse()
--     UserInputService.MouseBehavior = Enum.MouseBehavior.Default
--     UserInputService.MouseIconEnabled = true
-- end

-- ]]


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local debugMode = false

------------------------------------------------
-- RESPAWN
------------------------------------------------

player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")

	if not debugMode then
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid
		player.CameraMode = Enum.CameraMode.LockFirstPerson
	end
end)

------------------------------------------------
-- BLOQUE FPS seulement si pas en debug
------------------------------------------------

player:GetPropertyChangedSignal("CameraMode"):Connect(function()
	if not debugMode then
		if player.CameraMode ~= Enum.CameraMode.LockFirstPerson then
			player.CameraMode = Enum.CameraMode.LockFirstPerson
		end
	end
end)

------------------------------------------------
-- DEBUG CAMERA BOT
------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	local rabbitBot = workspace:FindFirstChild("RabbitBot")

	-- B = suivre le bot
	if input.KeyCode == Enum.KeyCode.B then
		if rabbitBot and rabbitBot:FindFirstChild("Humanoid") then
			print("Camera -> RabbitBot")

			debugMode = true
			player.CameraMode = Enum.CameraMode.Classic
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = rabbitBot.Humanoid
		end
	end

	-- P = revenir au joueur
	if input.KeyCode == Enum.KeyCode.P then
		print("Camera -> Player")

		debugMode = false
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = player.Character:WaitForChild("Humanoid")
	end
end)
