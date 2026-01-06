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


local time = 0
local delay = 1
--[[
    Toutes les secondes enlèvent de la faim à tous les joueur
]]
function HungerSysteme:Tick(dt)
    time += dt
    if time >= delay then
        time = 0
        for player, RabbitClass in listPlayer do
            if RabbitClass:IsAlive() then
                RabbitClass:RemoveSatiety(1)
            end
        end
    end  
end


return HungerSysteme