local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
end)