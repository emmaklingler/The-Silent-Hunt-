local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local Event = game.ReplicatedStorage.Remote.EatCarrotEvent

Event.OnServerEvent:Connect(function(player)
    print("EatCarrotEvent received from player: " .. player.Name)
end)