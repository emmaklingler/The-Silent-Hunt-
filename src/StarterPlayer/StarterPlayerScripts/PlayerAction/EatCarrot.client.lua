local Carrot = workspace:WaitForChild("Carrot")
local Prompt = Carrot.ProximityPrompt
local Player = game.Players.LocalPlayer
local Event = game.ReplicatedStorage.Remote.EatCarrotEvent

Prompt.Triggered:Connect(function(playerHit)
    if playerHit == Player then
       Event:FireServer()
    end
end)