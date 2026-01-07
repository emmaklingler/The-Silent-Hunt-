local SoundManagerClient = require(script.Parent.SoundManagerClient)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaySoundEvent = ReplicatedStorage.Remote:WaitForChild("PlaySound")

PlaySoundEvent.OnClientEvent:Connect(function(player, position, soundId, volume)
    print(player, position, soundId, volume)
    SoundManagerClient.playSound(player, position, soundId, volume)
end)