local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer
local EatCarrotEvent = ReplicatedStorage.Remote:WaitForChild("EatCarrotEvent")

local Carrot = workspace:WaitForChild("Carrot",5)
local Prompt = Carrot.ProximityPrompt

--[[
    Gestion de l'événement lorsque le joueur interagit avec la carotte.
]]
Prompt.Triggered:Connect(function(playerHit)
    if playerHit == Player then
       EatCarrotEvent:FireServer(Carrot)
    end
end)