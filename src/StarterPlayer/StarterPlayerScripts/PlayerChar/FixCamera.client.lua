local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Verrouille la caméra en vue première personne

-- Change la cible de la caméra au respawn
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
end)

-- Empêche le joueur de changer le mode de la caméra
player:GetPropertyChangedSignal("CameraMode"):Connect(function()
	if player.CameraMode ~= Enum.CameraMode.LockFirstPerson and camera.CameraType ~= Enum.CameraType.Orbital then
		player.CameraMode = Enum.CameraMode.LockFirstPerson
	end
end)


-- Activer FPS
local function EnableFPSMouse()
    player.CameraMode = Enum.CameraMode.LockFirstPerson
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false
end

if not RunService:IsStudio() then
    task.delay(5, EnableFPSMouse)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LifeEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("LifeChangeEvent")


-- Désactiver FPS (menu, pause, etc)
local function DisableFPSMouse()
    player.CameraMode = Enum.CameraMode.Classic
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
end

LifeEvent.OnClientEvent:Connect(function(health)
    if health <= 0 then
        DisableFPSMouse()
    end
end)