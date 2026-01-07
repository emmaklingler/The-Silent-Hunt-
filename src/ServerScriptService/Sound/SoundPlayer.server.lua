local SoundManager = require(script.Parent.SoundManager)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaySoundEvent = ReplicatedStorage.Remote:WaitForChild("PlaySound")

PlaySoundEvent.OnServerEvent:Connect(function(player, position, soundName, volume)
    local soundId = SoundManager.SoundId[soundName]
    if soundId then
        SoundManager.playSound(player, position, soundId, volume)
    else
        warn("Sound name not found:", soundName)
    end
end)