local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Verrouille la caméra en vue première personne
--player.CameraMode = Enum.CameraMode.LockFirstPerson

-- Change la cible de la caméra au respawn
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
end)

-- Empêche le joueur de changer le mode de la caméra
player:GetPropertyChangedSignal("CameraMode"):Connect(function()
	if player.CameraMode ~= Enum.CameraMode.LockFirstPerson then
		player.CameraMode = Enum.CameraMode.LockFirstPerson
	end
end)

--[[
Désactive la souris ou non : 
-- Activer FPS
local function EnableFPSMouse()
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false
end

-- Désactiver FPS (menu, pause, etc)
local function DisableFPSMouse()
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
end

]]