-- Rabbit.lua
local Rabbit = {}
Rabbit.__index = Rabbit

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
    self.Hunger -= amount
    --Si hunger < 0 Meurt
end

function Rabbit:TakeDamage(amount)
    self.Health -= amount
    --Si health < 0 Meurt
end

function Rabbit:MakeNoise(value)
    --self.NoiseLevel = math.clamp(self.NoiseLevel + value, 0, 100)
end

function Rabbit:Spawn()
    local character = self.Player.Character or self.Player.CharacterAdded:Wait()
    
    local spawnPoint = workspace.SpawnLocation
    character:PivotTo(spawnPoint.CFrame)

    self.Health = 100
    self.Hunger = 100
    self.Stress = 0
end



return Rabbit
