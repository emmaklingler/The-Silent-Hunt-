local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteHunger = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("HungerChangeEvent")

local SeCacherEvent = game.ReplicatedStorage.Remote:WaitForChild("SeCacherEvent")


local function TeleportationBuisson(player, buisson)
    local RabbitClass = PlayerManager:GetRabbit(player)
    RabbitClass.Model:MoveTo(buisson.Position)
    RabbitClass:RemoveSatiety(20)
    RemoteHunger:FireClient(player, RabbitClass.Satiety)
end
--[[
    Gestion de l'événement lorsque le joueur se cache dans un buisson.    
]]
SeCacherEvent.OnServerEvent:Connect(function(player, Bush_Common)
    print(PlayerManager:GetRabbit(player))
    PlayerManager:GetRabbit(player):SeCacher()
    TeleportationBuisson(player, Bush_Common)
end)