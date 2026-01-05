local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer
local EatCarrotEvent = ReplicatedStorage.Remote:WaitForChild("EatCarrotEvent")
local CreateCarrotEvent = ReplicatedStorage.Remote:WaitForChild("CreateCarrotEvent")

--[[
    Gestion de l'événement lorsque le joueur interagit avec la carotte.
]]
CreateCarrotEvent.OnClientEvent:Connect(function(carrotName)
    if not carrotName then return end
    local carrot = workspace:WaitForChild(carrotName) 
    -- attendre que tout soit bien répliqué
    local prompt = carrot:WaitForChild("ProximityPrompt")

    prompt.Triggered:Connect(function(playerHit)
        if playerHit == Player then
            EatCarrotEvent:FireServer(carrot)
        end
    end)
end)
