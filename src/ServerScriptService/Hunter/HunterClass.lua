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

    -- Paramètres d'attaque
    self.attackRange = 10
    self.attackDamage = 20
    self.attackCooldown = 3
    self.attackDuration = 1.5
    self.isAttacking = false

    -- Animation, ...
    self.state = ""
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
function Hunter:TryAttack(target)
	if self.isAttacking then
		if os.clock() >= self.attackEndTime then
			self.isAttacking = false
			self:ChangeState("Idle")
			return "finished"
		end
		return "running"
	end

	-- conditions
	local dist = (self.Root.Position - target.Root.Position).Magnitude
	if dist > self.attackRange then
		return "failed"
	end

	-- cooldown
	if os.clock() < (self.nextAttackTime or 0) then
		return "failed"
	end

	-- start attack
	self.isAttacking = true
	self.attackEndTime = os.clock() + self.attackDuration
	self.nextAttackTime = os.clock() + self.attackCooldown

	self:ChangeState("AttackPied")
	target:RemoveHealth(self.attackDamage)

	return "running"
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