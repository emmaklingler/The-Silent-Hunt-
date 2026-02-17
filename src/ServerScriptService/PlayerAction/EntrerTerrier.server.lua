local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local EntrerTerrierEvent = game.ReplicatedStorage.Remote:WaitForChild("EntrerTerrierEvent")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteHUDHunger = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("HungerHUDChangeEvent")

local function TeleportationTerrier(player, porte)
    local RabbitClass = PlayerManager:GetRabbit(player)
    RabbitClass.Model:MoveTo(porte.CFrame.LookVector * 5)
    RabbitClass:Terrier()
    RemoteHUDHunger:FireClient(player, RabbitClass.Hunger)
end
--[[
    Gestion de l'événement lorsque le joueur entre ou sort d'un terrier
]]
EntrerTerrierEvent.OnServerEvent:Connect(function(player, porte)
    print(porte)
    TeleportationTerrier(player, porte)
end)

