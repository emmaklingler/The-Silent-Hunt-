local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local EatCarrotEvent = game.ReplicatedStorage.Remote:WaitForChild("EatCarrotEvent")
local HungerChangeEvent = game.ReplicatedStorage.Remote:WaitForChild("HungerChangeEvent")


EatCarrotEvent.OnServerEvent:Connect(function(player)
    PlayerManager:GetRabbit(player):TakeHunger(-40)
    HungerChangeEvent:FireClient(player, PlayerManager:GetRabbit(player).Hunger)
end)