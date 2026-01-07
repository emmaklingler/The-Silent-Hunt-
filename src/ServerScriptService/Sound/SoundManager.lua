local SoundManager = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaySoundEvent = ReplicatedStorage.Remote:WaitForChild("PlaySound")

SoundManager.SoundId = {
    EatCarrot = "rbxassetid://140683600641534",
    JumpGrass = "rbxassetid://135162567109750"
}

function SoundManager.playSound(player, position, soundId, volume)
    PlaySoundEvent:FireAllClients(player, position, soundId, volume)
end

return SoundManager

