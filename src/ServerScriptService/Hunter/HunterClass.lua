local Hunter = {}
Hunter.__index = Hunter
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeStateHunterEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateHunterEvent")
--[[
    Classe Hunter: gère le comportement et les actions d'un chasseur dans le jeu.
    @param model: Model - le modèle du chasseur dans le jeu
]]
function Hunter.new(model: Model)
    local self = setmetatable({}, Hunter)
    self.Model = model
    self.Humanoid = model:WaitForChild("Humanoid")
	self.Root = model:WaitForChild("HumanoidRootPart")

    -- Animation, ...
    self:ChangeState("Idle")  -- État initial du chasseur
    return self
end

--[[
    Déplace le chasseur vers une position cible
    @param targetPosition: Vector3 - la position vers laquelle se déplacer
]]
function Hunter:MoveTo(targetPosition)
    self:ChangeState("Walk")
    self.Humanoid:MoveTo(targetPosition)
    self.Humanoid.MoveToFinished:Wait()
    self:ChangeState("Idle")
end

--[[
    Attaque d'une cible
    @param target: RabbitClass - la cible à attaquer
]]
function Hunter:Attack(target)
    
    local distance = (self.Root.Position - target.Root.Position).Magnitude
    if distance > 8 then
        return false
    end
    self:ChangeState("AttackPied")

    print("Hunter: Attaque " .. target.Player.Name)
    -- Logique d'attaque ici (animations, dégâts, etc.)
    target:RemoveHealth(10)
	task.wait(5) -- Simule l'action d'attaque
    self:ChangeState("Idle")
    return true
end


--[[
    Change l'état du chasseur et envoie au Client pour faire l'animation
    @param state: string - le nouvel état du chasseur
]]
function Hunter:ChangeState(state)
    self.state = state
    --envoie au client
    ChangeStateHunterEvent:FireAllClients(self.Model, state)
end

return Hunter