local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local EntrerTerrierEvent = game.ReplicatedStorage.Remote:WaitForChild("EntrerTerrierEvent")

local function TeleportationTerrier(player, porte)
    local RabbitClass = PlayerManager:GetRabbit(player)
    RabbitClass.Model:MoveTo(porte.Position)
    RabbitClass.DansTerrier = not RabbitClass.DansTerrier
end
--[[
    Gestion de l'événement lorsque le joueur entre ou sort d'un terrier
]]
EntrerTerrierEvent.OnServerEvent:Connect(function(player, porte)
    print(porte)
    TeleportationTerrier(player, porte)
end)

