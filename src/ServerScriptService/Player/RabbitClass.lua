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

    return self
end

--[[
    Enleve de la satiety au lapin. 
    Si la satiety est a 0, enleve de la vie.
    amount: nombre a enlever
]]
function Rabbit:RemoveSatiety(amount)
    if self.Satiety > 0 or amount == -40 then
        self.Satiety -= amount
        --Si satiety < 0 Meurt
        if self.Satiety > 100 then
            self.Satiety = 100
        end
    else
        self:RemoveHealth(1)
    end
end

--[[
    Ajoute de la satiety au lapin.
    amount: nombre a ajouter
]]
function Rabbit:AddSatiety(amount)
    self.Satiety += amount
    if self.Satiety > 100 then
        self.Satiety = 100
    end
end

--[[
    Enleve de la vie au lapin.
    amount: nombre a enlever
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
