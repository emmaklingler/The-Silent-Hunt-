local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer
local SeCacherEvent = ReplicatedStorage.Remote:WaitForChild("SeCacherEvent")

--[[
    Gestion de l'événement lorsque le joueur interagit avec la carotte.
]]

local buisson = workspace.Asset.Bushs:WaitForChild("Bush_Common") 
-- attendre que tout soit bien répliqué
local prompt = buisson:WaitForChild("ProximityPrompt")

prompt.Triggered:Connect(function(playerHit)
    if playerHit == Player then
        SeCacherEvent:FireServer(buisson)
    end
end)

