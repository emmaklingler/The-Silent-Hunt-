local TimeSystem = {}

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TimeChangeEvent = ReplicatedStorage.Remote:WaitForChild("TimeChangeEvent")
local PlayerDeadEvent = ReplicatedStorage.Remote:WaitForChild("PlayerDeadServerEvent")

local debut = os.clock()
local tempsEcoule = 0
local tempsMax = 150

local eventTick = 0
local eventFire = 100

local startHour = 8
local endHour = 20

local startMinutes = startHour * 60
local endMinutes = endHour * 60

local endFunction = nil

--[[
    Initialise le système de faim, fire les clients pour init le HUD
    @param players: dictionnaire de joueur->ClasseLapin
]]
function TimeSystem:Init(players, func)
    debut = os.clock()
    endFunction = func
    TimeChangeEvent:FireAllClients(tempsEcoule, tempsMax)
    Lighting:SetMinutesAfterMidnight(startMinutes)
end


--[[
    Toutes les secondes enlèvent de la faim à tous les joueur
]]
function TimeSystem:Tick(dt)
    local now = os.clock()
    local newdt = now - debut
    debut = now

    tempsEcoule = tempsEcoule + newdt
    eventTick += 1

    if eventTick >= eventFire then
        eventTick = 0
        TimeChangeEvent:FireAllClients(tempsEcoule, tempsMax)
    end

    local progress = math.clamp(tempsEcoule / tempsMax, 0, 1)
    progress = progress * progress -- easing simple

    local currentMinutes = startMinutes + (endMinutes - startMinutes) * progress

    Lighting:SetMinutesAfterMidnight(currentMinutes)

    if tempsEcoule >= tempsMax then
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