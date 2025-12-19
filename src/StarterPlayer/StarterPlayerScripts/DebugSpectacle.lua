local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- On utilise une variable pour le nom pour pouvoir le changer facilement
local HUNTER_NAME = "Humans_Master_off" 

local function spectate(target)
    if not target then return end
    
    -- Pour un modèle, on cible l'Humanoid pour que la caméra soit fluide
    local subject = target:FindFirstChildOfClass("Humanoid") or target.PrimaryPart
    
    if subject then
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = subject
        print("🎥 Caméra fixée sur :", target.Name)
    end
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.C then
        spectate(workspace:FindFirstChild(HUNTER_NAME))
    elseif input.KeyCode == Enum.KeyCode.L then
        spectate(player.Character)
    end
end)