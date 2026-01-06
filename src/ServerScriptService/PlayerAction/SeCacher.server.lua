local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local SeCacherEvent = game.ReplicatedStorage.Remote:WaitForChild("SeCacherEvent")

--[[
    Gestion de l'événement lorsque le joueur se cache dans un buisson.    
]]
SeCacherEvent.OnServerEvent:Connect(function(player, Bush_Common: Instance)
    print(PlayerManager:GetRabbit(player))
    PlayerManager:GetRabbit(player):SeCacher()
end)