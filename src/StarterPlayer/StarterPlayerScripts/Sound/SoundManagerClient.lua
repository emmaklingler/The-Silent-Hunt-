local SoundManager = {}

local LocalPlayer = game.Players.LocalPlayer
local Debris = game:GetService("Debris")

function SoundManager.playSound(player, position, soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume or 1
    sound.PlayOnRemove = true
    sound.Looped = false

    --Ajoute du random au son pour pas que ce soit toujours pareil
    local effect = Instance.new("PitchShiftSoundEffect")
    effect.Octave = 1 + math.random(-1, 1) * 0.1
    effect.Parent = sound


    if player and player == LocalPlayer then
        --Si c'est le même joueur
        sound.Parent = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        sound:Play()
    
    else
        --Si c'est pas le même joueur alors le son est joué à la position
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 1
        part.Position = position
        part.Parent = workspace

        sound.Parent = part

        sound:Play()
        Debris:AddItem(part, sound.TimeLength)
    end

    
end

return SoundManager

