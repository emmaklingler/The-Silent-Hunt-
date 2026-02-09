local HungerSysteme = {}
local listPlayer = {} -- dictionnaire des joueurs et de leurs classes RabbitClass

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteHunger = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("HungerChangeEvent")

local rate = 1 -- taux de faim par seconde
local last = os.clock()

--[[
    Initialise le système de faim, fire les clients pour init le HUD
    @param players: dictionnaire de joueur->ClasseLapin
]]
function HungerSysteme:Init(players)
    last = os.clock()
    listPlayer = players   
    for player, RabbitClass in listPlayer do
        RemoteHunger:FireClient(player, RabbitClass.Satiety)
    end
end


--[[
    Toutes les secondes enlèvent de la faim à tous les joueur
]]
function HungerSysteme:Tick(dt)
    local now = os.clock()
    local newdt = now - last
    last = now

    local satietyToRemove = rate * newdt
    for player, RabbitClass in listPlayer do
        if RabbitClass:IsAlive() then
            RabbitClass:RemoveSatiety(satietyToRemove)
        end
    end
end


return HungerSysteme