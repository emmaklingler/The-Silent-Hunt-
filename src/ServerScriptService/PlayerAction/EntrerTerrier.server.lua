local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local EntrerTerrierEvent = game.ReplicatedStorage.Remote:WaitForChild("EntrerTerrierEvent")

local function TeleportationTerrier(player, porte)
    local RabbitClass = PlayerManager:GetRabbit(player)
    print(RabbitClass.Model)
    RabbitClass.Model:MoveTo(porte.Position)
    RabbitClass.DansTerrier = not RabbitClass.DansTerrier
    print(RabbitClass.DansTerrier)
end
--[[
    Gestion de l'événement lorsque le joueur entre ou sort d'un terrier
]]
EntrerTerrierEvent.OnServerEvent:Connect(function(player, porte)
    local porte_1_sortie = workspace.Terrier.Sortie:WaitForChild("Porte_1") 
    print(PlayerManager:GetRabbit(player))
    TeleportationTerrier(player, porte_1_sortie)
end)

