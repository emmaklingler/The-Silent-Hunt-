-- Rabbit.lua
local Rabbit = {}
Rabbit.__index = Rabbit

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFolder = ReplicatedStorage:WaitForChild("Remote")
local LifeEvent = RemoteFolder:WaitForChild("LifeChangeEvent")

local PlayerSpawn = game.Workspace:FindFirstChild("PlayerSpawn")

local PlayerDeadEvent = ReplicatedStorage.Remote:WaitForChild("PlayerDeadServerEvent")

local ServerStorage = game:GetService("ServerStorage")
local NameTag = ServerStorage:WaitForChild("Asset"):WaitForChild("NameTag")

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

    self.DansTerrier = false

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
        if self.DansTerrier then amount *= 3 end -- Si le lapin est dans un terrier, il perd plus de satiety
        self.Satiety -= amount
        if self.Satiety <= 0 then
            self.Satiety = 0
        end
    else
        --Sinon il n'a plus de satiety, il perd de la vie
        self:RemoveHealth(amount*10)
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
        self.Root.Anchored = true
    else
        self.Root.Anchored = false
    end
    -- rend le caractère transparent ou non
    self.Model["Plane.001"].Transparency = self.EstCache and 1 or 0
end

function Rabbit:Terrier()
    self.DansTerrier = not self.DansTerrier
    
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
        PlayerDeadEvent:Fire(self.Player)
    end
    if self.Player then
        LifeEvent:FireClient(self.Player, self.Health)
    end

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

    local nameTag = NameTag:Clone()
    nameTag.TextLabel.Text = player.Name
    nameTag.PlayerToHideFrom = player
    nameTag.Parent = character

	character.Name = player.Name
	character.Parent = workspace
	
	player.Character = character
    
    --Ajout random
    local spawnPoint = PlayerSpawn:GetChildren()[math.random(1, #PlayerSpawn:GetChildren())]
    character:PivotTo(spawnPoint.CFrame+Vector3.new(0, 5, 0))
    
    -- Mettre à jour les références
    self.Model = character
    self.Humanoid = character:WaitForChild("Humanoid")
    self.Root = character:WaitForChild("HumanoidRootPart")
    self.Health = 100
    self.MaxHealth = 100
    self.Satiety = 100
    self.Stress = 0

end



return Rabbit