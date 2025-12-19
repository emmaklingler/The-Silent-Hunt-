local Players = game:GetService("Players")

local Rabbit = require(script.Parent.RabbitClass)

local PlayerManager = {}
PlayerManager.__index = PlayerManager

local rabbits = {}

--[[
    Crée une instance de Rabbit pour le joueur donné et l'ajoute à la liste des lapins.
    player: Instance du joueur
    profile: Profil du joueur (ProfileService)
]]
function PlayerManager:CreateRabbit(player, profile)
    local rabbit = Rabbit.new(player, profile)
    rabbits[player] = rabbit
    return rabbit
end

--[[
    Récupère l'instance de Rabbit associée au joueur donné.
    player: Instance du joueur
    Retourne l'instance de Rabbit ou nil si le joueur n'a pas de lapin.
]]
function PlayerManager:GetRabbit(player)
    return rabbits[player]
end

--[[
    Supprime l'instance de Rabbit associée au joueur donné.
    player: Instance du joueur
]]
function PlayerManager:RemoveRabbit(player)
    rabbits[player] = nil
end

--[[
    Récupère toutes les instances de Rabbit.
    Retourne une table contenant toutes les instances de Rabbit.
]]
function PlayerManager:GetAllRabbits()
    return rabbits
end


return PlayerManager
