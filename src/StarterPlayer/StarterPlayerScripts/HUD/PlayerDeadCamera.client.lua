local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LifeEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("LifeChangeEvent")
local StartGameEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("StartGameEvent")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui


local GUIVie = nil
local GUICamera = nil
local buttonNext = nil
local buttonPrev = nil
local textLabel = nil

local index = 1

local camera = workspace.CurrentCamera

local function UpdateCamera(playerCible)
    local character = playerCible.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = character.HumanoidRootPart.Position + Vector3.new(0, 5, 10)
        camera.CFrame = CFrame.new(targetPosition, character.HumanoidRootPart.Position)
        camera.CameraSubject = character:FindFirstChild("Humanoid")
        textLabel.Text = playerCible.Name
    end
end

StartGameEvent.OnClientEvent:Connect(function()
    GUIVie = PlayerGui:WaitForChild("HUD").SG_HUD
    GUICamera = PlayerGui:WaitForChild("CameraPlayerGUI")

    buttonNext = GUICamera.Frame:WaitForChild("Next")
    buttonPrev = GUICamera.Frame:WaitForChild("Prev")

    textLabel = GUICamera.Frame:WaitForChild("TextLabel")

    buttonNext.MouseButton1Click:Connect(function()
        local players = Players:GetPlayers()
        index += 1
        if index > #players then index = 1 end
        UpdateCamera(players[index])
    end)
    buttonPrev.MouseButton1Click:Connect(function()
        local players = Players:GetPlayers()
        index -= 1
        if index < 1 then index = #players end
        UpdateCamera(players[index])
    end)
end)


--Si le joueur meurt, on affiche la caméra de mort
LifeEvent.OnClientEvent:Connect(function(lifeValue)
    if lifeValue <= 0 then
        GUIVie.Enabled = false
        GUICamera.Enabled = true
        camera.FieldOfView = 70
        camera.CameraType = Enum.CameraType.Custom

        Player.CameraMode = Enum.CameraMode.Classic -- IMPORTANT

        Player.CameraMinZoomDistance = 15
        Player.CameraMaxZoomDistance = 15

        camera.CameraSubject = nil -- reset
        UpdateCamera(Player)
    end
end)