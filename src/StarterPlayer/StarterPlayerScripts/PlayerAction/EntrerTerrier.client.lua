local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer
local EntrerTerrierEvent = ReplicatedStorage.Remote:WaitForChild("EntrerTerrierEvent")

--[[
    Gestion de l'événement lorsque le joueur interagit avec la carotte.
]]

local porte_1 = workspace.Terrier.Entre:WaitForChild("Porte_1") 
-- attendre que tout soit bien répliqué
local prompt = porte_1:WaitForChild("ProximityPrompt")

prompt.Triggered:Connect(function(playerHit)
    if playerHit == Player then
        EntrerTerrierEvent:FireServer(porte_1)
    end
end)

