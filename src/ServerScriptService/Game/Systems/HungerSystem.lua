local HungerSysteme = {}
local listPlayer = {} -- dictionnaire des joueurs et de leurs classes RabbitClass

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteHunger = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("HungerChangeEvent")

--[[
    Initialise le système de faim, fire les clients pour init le HUD
    @param players: dictionnaire de joueur->ClasseLapin
]]
function HungerSysteme:Init(players)
    listPlayer = players   
    for player, RabbitClass in listPlayer do
        RemoteHunger:FireClient(player, RabbitClass.Satiety)
    end
end

--[[
    Commence la boucle qui vas enlever de la faim à tous les joueurs
]]
function HungerSysteme:Start()
    while true do
        task.wait(1)
        for player, RabbitClass in listPlayer do
            RabbitClass:RemoveSatiety(1)
        end
    end
end


return HungerSysteme