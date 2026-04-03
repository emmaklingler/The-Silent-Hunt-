local SoundManager = require(script.Parent.SoundManager)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaySoundEvent = ReplicatedStorage.Remote:WaitForChild("PlaySound")
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

PlaySoundEvent.OnServerEvent:Connect(function(player, position, soundName, volume)
    local soundId = SoundManager.SoundId[soundName]
    if soundId then
        SoundManager.playSound(player, position, soundId, volume)

        local rabbit = PlayerManager:GetRabbit(player)
        if rabbit then
            rabbit:MakeNoise(position, volume or 1)
        end
    else
        warn("Sound name not found:", soundName)
    end
end)