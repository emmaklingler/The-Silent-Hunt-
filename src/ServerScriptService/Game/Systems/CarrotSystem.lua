local CarrotSystem = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EatCarrotEvent = ReplicatedStorage.Remote:WaitForChild("EatCarrotEvent")
local CreateCarrotEvent = ReplicatedStorage.Remote:WaitForChild("CreateCarrotEvent")

local Carrot = script.Carrot
local CarrotSpawn = workspace:WaitForChild("CarrotSpawn")

local tablePos = {}
for _, part in CarrotSpawn:GetChildren() do
    tablePos[part.Position] = false
end

local function getPosLibre()
    local libres = {}

    for pos, occupe in pairs(tablePos) do
        if not occupe then
            table.insert(libres, pos)
        end
    end

    if #libres == 0 then
        return nil
    end

    local choix = libres[math.random(#libres)]
    tablePos[choix] = true
    return choix
end


local MaxCarrot = 2
local time = 0
local delay = 1
local totaleCarrot = 0
local id = 0

local function spawnCarrot(position)
    local clone = Carrot:Clone()
    clone.Name = "Carrot"..id
    id+=1
    clone.Position = position
    clone.Parent = workspace
    
    totaleCarrot+=1
    
    --Envoie au client
    CreateCarrotEvent:FireAllClients(clone.Name)
end

EatCarrotEvent.OnServerEvent:Connect(function(player, carrot)
    tablePos[carrot.Position] = false
    totaleCarrot -= 1
end)

--[[
    Toutes les 5 secondes à 50% de chance de faire apparaître une carrotte avec max 2 carrotte
]]
function CarrotSystem:Tick(dt)
    time += dt
    if time >= delay then
        time = 0
        if math.random(0, 10) > 5 then
            if totaleCarrot < MaxCarrot then
                spawnCarrot(getPosLibre())
            end
        end
    end
end



return CarrotSystem
