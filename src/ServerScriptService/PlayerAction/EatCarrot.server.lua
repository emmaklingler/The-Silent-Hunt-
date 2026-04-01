-- local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)
-- local SoundManager = require(game.ServerScriptService.Sound.SoundManager)

-- local EatCarrotEvent = game.ReplicatedStorage.Remote:WaitForChild("EatCarrotEvent")
-- local HungerChangeEvent = game.ReplicatedStorage.Remote:WaitForChild("HungerChangeEvent")

-- --[[
--     Gestion de l'événement lorsque le joueur mange une carotte.    
-- ]]
-- EatCarrotEvent.OnServerEvent:Connect(function(player, Carrot)
--     PlayerManager:GetRabbit(player):AddSatiety(40)                                  -- Ajoute 40 de satiety
--     HungerChangeEvent:FireClient(player, PlayerManager:GetRabbit(player).Satiety)   -- Met à jour le client avec la nouvelle valeur de satiety
--     Carrot:Destroy()
--     SoundManager.playSound(player, Carrot.Position, SoundManager.SoundId.EatCarrot, 1)
-- end)
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)
local SoundManager = require(game.ServerScriptService.Sound.SoundManager)

local EatCarrotEvent = game.ReplicatedStorage.Remote:WaitForChild("EatCarrotEvent")
local HungerChangeEvent = game.ReplicatedStorage.Remote:WaitForChild("HungerChangeEvent")

-- Fonction centrale pour détruire la carotte et mettre à jour les stats
local function ProcessEatCarrot(rabbitObject, carrotPart, player)
    if not carrotPart or not carrotPart.Parent then return end

    -- 1. Mise à jour de la Satiété
    if rabbitObject.AddSatiety then
        rabbitObject:AddSatiety(40)
    else
        -- Pour ton RabbitBot (classe simple)
        rabbitObject.Satiety = math.min(100, (rabbitObject.Satiety or 0) + 40)
    end

    -- 2. DESTRUCTION VISUELLE TOTALE
    -- On joue le son à l'endroit de la carotte
    SoundManager.playSound(nil, carrotPart.Position, SoundManager.SoundId.EatCarrot, 1)

    -- On rend l'objet invisible immédiatement au cas où le Destroy met du temps
    if carrotPart:IsA("BasePart") then
        carrotPart.Transparency = 1
        carrotPart.CanCollide = false
    end
    
    -- On détruit tout (enfants inclus : Mesh, Decals, etc.)
    carrotPart:Destroy()

    -- 3. Si c'est un joueur humain, on met à jour son interface
    if player then
        HungerChangeEvent:FireClient(player, rabbitObject.Satiety)
    end
end

-- Écouteur pour les JOUEURS réels
EatCarrotEvent.OnServerEvent:Connect(function(player, carrotPart)
    local rabbit = PlayerManager:GetRabbit(player)
    if rabbit then
        ProcessEatCarrot(rabbit, carrotPart, player)
    end
end)

-- EXPOSER la fonction pour que les BOTS puissent l'utiliser via RabbitBotClass
_G.BotEatCarrot = ProcessEatCarrot