local TimeSystem = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TimeChangeEvent = ReplicatedStorage.Remote:WaitForChild("TimeChangeEvent")
local PlayerDeadEvent = ReplicatedStorage.Remote:WaitForChild("PlayerDeadServerEvent")

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

local nbDead = 0
PlayerDeadEvent.Event:Connect(function(player)
    nbDead += 1
    if nbDead >= #Players:GetPlayers() then
        print("Tous les joueurs sont morts !")
        endFunction()
    end
end)


return TimeSystem