local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer
local SeCacherEvent = ReplicatedStorage.Remote:WaitForChild("SeCacherEvent")

--[[
    Gestion de l'événement lorsque le joueur interagit avec la carotte.
]]
local function SetUpBuisson(buisson)
    local prompt = buisson:WaitForChild("ProximityPrompt")

    prompt.Triggered:Connect(function(playerHit)
        if playerHit == Player then
            SeCacherEvent:FireServer(buisson)
        end
    end)
end

local buissonFolder = game.Workspace:WaitForChild("Buisson")

for _, buisson in buissonFolder:GetChildren() do
    SetUpBuisson(buisson)
end

buissonFolder.ChildAdded:Connect(function(buisson)
    SetUpBuisson(buisson)
end)

