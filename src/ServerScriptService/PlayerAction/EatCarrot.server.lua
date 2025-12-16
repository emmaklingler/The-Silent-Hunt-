local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local Event = game.ReplicatedStorage.Remote:WaitForChild("EatCarrotEvent")

Event.OnServerEvent:Connect(function(player)
    print(PlayerManager:GetRabbit(player))
    PlayerManager:GetRabbit(player):TakeDamage(10)
    PlayerManager:GetRabbit(player):TakeHunger(10)
end)