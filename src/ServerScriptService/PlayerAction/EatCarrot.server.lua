local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)
local SoundManager = require(game.ServerScriptService.Sound.SoundManager)

local EatCarrotEvent = game.ReplicatedStorage.Remote:WaitForChild("EatCarrotEvent")
local HungerChangeEvent = game.ReplicatedStorage.Remote:WaitForChild("HungerChangeEvent")

--[[
    Gestion de l'événement lorsque le joueur mange une carotte.    
]]
EatCarrotEvent.OnServerEvent:Connect(function(player, Carrot)
    PlayerManager:GetRabbit(player):AddSatiety(40)                                  -- Ajoute 40 de satiety
    HungerChangeEvent:FireClient(player, PlayerManager:GetRabbit(player).Satiety)   -- Met à jour le client avec la nouvelle valeur de satiety
    Carrot:Destroy()
    SoundManager.playSound(player, Carrot.Position, SoundManager.SoundId.EatCarrot, 1)
end)