local TimeSystem = {}
local listPlayer = {} -- dictionnaire des joueurs et de leurs classes RabbitClass

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TimeChangeEvent = ReplicatedStorage.Remote:WaitForChild("TimeChangeEvent")

local debut = os.clock()
local tempsEcoule = 0
local tempsMax = 100

local eventTick = 0
local eventFire = 100

local endFunction = nil

--[[
    Initialise le système de faim, fire les clients pour init le HUD
    @param players: dictionnaire de joueur->ClasseLapin
]]
function TimeSystem:Init(players, func)
    debut = os.clock()
    listPlayer = players   
    endFunction = func
    TimeChangeEvent:FireAllClients(tempsEcoule)
end


--[[
    Toutes les secondes enlèvent de la faim à tous les joueur
]]
function TimeSystem:Tick(dt)
    local now = os.clock()
    local newdt = now - debut
    debut = now
    tempsEcoule = tempsEcoule + newdt
    eventTick+=1
    if eventTick >= eventFire then
        eventTick = 0
        TimeChangeEvent:FireAllClients(tempsEcoule)
    end
    if tempsEcoule >= tempsMax then
        -- Faire quelque chose lorsque le temps est écoulé
        print("Temps écoulé !")
        endFunction()
    end
end


return TimeSystem