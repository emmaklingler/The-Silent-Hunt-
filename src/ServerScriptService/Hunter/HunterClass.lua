local Hunter = {}
Hunter.__index = Hunter

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

    return self
end

--[[
    Déplace le chasseur vers une position cible
    @param targetPosition: Vector3 - la position vers laquelle se déplacer
]]
function Hunter:MoveTo(targetPosition)
    self.Humanoid:MoveTo(targetPosition)
    self.Humanoid.MoveToFinished:Wait()
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

    print("Hunter: Attaque " .. target.Player.Name)
    -- Logique d'attaque ici (animations, dégâts, etc.)
    target:RemoveHealth(10)
	task.wait(5) -- Simule l'action d'attaque
    return true
end

return Hunter