-- Rabbit.lua
local Rabbit = {}
Rabbit.__index = Rabbit

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFolder = ReplicatedStorage:WaitForChild("Remote")
local LifeEvent = RemoteFolder:WaitForChild("LifeChangeEvent")

function Rabbit.new(player, profile)
    local self = setmetatable({}, Rabbit)
    self.Player = player
    self.Profile = profile -- ProfileService
    
    self.Alive = true

    self.Health = 100
    self.Hunger = 100
    self.Stress = 0
    self.NoiseLevel = 0

    return self
end

function Rabbit:TakeHunger(amount)
    if self.Hunger > 0 or amount == -40 then
        self.Hunger -= amount
        --Si hunger < 0 Meurt
        if self.Hunger > 100 then
            self.Hunger = 100
        end
    else
        self:TakeDamage(1)
    end
end

local RemoteLife = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("LifeChangeEvent")
function Rabbit:TakeDamage(amount)
    if self.Health > 0 then
        self.Health -= amount
    end
    --Si health < 0 Meurt
    RemoteLife:FireClient(self.Player, self.Health)
end

function Rabbit:MakeNoise(value)
    --self.NoiseLevel = math.clamp(self.NoiseLevel + value, 0, 100)
end

local rabbitChar = game.ServerStorage.Asset:WaitForChild("RabbitCharacter")
function Rabbit:Spawn()
    local player = self.Player

	-- Supprimer l'ancien character s'il existe
	if player.Character then
		player.Character:Destroy()
	end
	
	local character = rabbitChar:Clone()
	character.Name = player.Name
	character.Parent = workspace
	
	player.Character = character
    
    local spawnPoint = workspace.SpawnLocation
    character:PivotTo(spawnPoint.CFrame+Vector3.new(0, 5, 0))
    

    self.Health = 100
    self.Hunger = 100
    self.Stress = 0

end



return Rabbit
