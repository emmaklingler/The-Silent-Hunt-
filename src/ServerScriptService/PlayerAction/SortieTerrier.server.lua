local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local SortieTerrierEvent = game.ReplicatedStorage.Remote:WaitForChild("SortieTerrierEvent")

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
SortieTerrierEvent.OnServerEvent:Connect(function(player, porte)
    local porte_1_entre = workspace.Terrier.Entre:WaitForChild("Porte_1") 
    print(PlayerManager:GetRabbit(player))
    TeleportationTerrier(player, porte_1_entre)
end)

