-- Rabbit.lua
local Rabbit = {}
Rabbit.__index = Rabbit

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFolder = ReplicatedStorage:WaitForChild("Remote")
local LifeEvent = RemoteFolder:WaitForChild("LifeChangeEvent")

function Rabbit.new(player, profile)
    local self = setmetatable({}, Rabbit)
    self.Player = player
    self.Model = nil                -- Initialisé lors du spawn
    self.Humanoid = nil             -- Initialisé lors du spawn
	self.Root = nil                 -- Initialisé lors du spawn

    self.Profile = profile          -- ProfileService
    
    self.Alive = true

    self.Health = 100
    self.Satiety = 100

    self.Stress = 0
    self.NoiseLevel = 0

    self.EstCache = false

    return self
end

--[[
    Vérifie si le lapin est vivant
    @return boolean - true si vivant, false sinon
]]
function Rabbit:IsAlive()
    return self.Alive
end

--[[
    Enleve de la satiety au lapin. 
    Si la satiety est a 0, enleve de la vie.
    @param amount: nombre a enlever
]]
function Rabbit:RemoveSatiety(amount)
    if self.Satiety > 0 then
        self.Satiety -= amount
        --Si satiety < 0 Meurt
    else
        self:RemoveHealth(amount)
    end
end

--[[
    Ajoute de la satiety au lapin.
    @param amount: nombre a ajouter
]]
function Rabbit:AddSatiety(amount)
    self.Satiety += amount
    if self.Satiety > 100 then
        self.Satiety = 100
    end
end

--[[
    Met le lapin en mode caché.
]]
function Rabbit:SeCacher()
    self.EstCache = not self.EstCache
    -- bloque ou débloque le mouvement (il faut aussi bloquer le saut)
    if self.EstCache then
        self.Humanoid.WalkSpeed = 0
    else
        self.Humanoid.WalkSpeed = 16
    end
    -- rend le caractère transparent ou non
    self.Model["Plane.001"].Transparency = self.EstCache and 1 or 0
    print(self.Player.Name .. " est caché: " .. tostring(self.EstCache))
end

function Rabbit:DansCachette()
    return self.EstCache
end

--[[
    Enleve de la vie au lapin.
    @param amount: nombre a enlever
]]
function Rabbit:RemoveHealth(amount)
    if self.Health > 0 then
        self.Health -= amount
    end
    --Si health < 0 Meurt
    if self.Health <= 0 then
        self.Health = 0
        self.Alive = false
        print(self.Player.Name .. " est mort.")
    end
    LifeEvent:FireClient(self.Player, self.Health)
end

--[[
    Fait du bruit
    @param value: le volume du bruit
]]
function Rabbit:MakeNoise(value)
    --self.NoiseLevel = math.clamp(self.NoiseLevel + value, 0, 100)
end

local rabbitChar = game.ServerStorage.Asset:WaitForChild("RabbitCharacter")
--[[
    Fait spawn le lapin dans le monde
]]
function Rabbit:Spawn()
    local player = self.Player
 
	-- Supprimer l'ancien character s'il existe
	if player.Character then
		player.Character:Destroy()
	end
	
    -- Cloner et positionner le character
	local character = rabbitChar:Clone()
	character.Name = player.Name
	character.Parent = workspace
	
	player.Character = character
    
    local spawnPoint = workspace.SpawnLocation
    character:PivotTo(spawnPoint.CFrame+Vector3.new(0, 5, 0))
    
    -- Mettre à jour les références
    self.Model = character
    self.Humanoid = character:WaitForChild("Humanoid")
    self.Root = character:WaitForChild("HumanoidRootPart")
    self.Health = 100
    self.Satiety = 100
    self.Stress = 0

end

return Rabbit
