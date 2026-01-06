local Hunter = {}
Hunter.__index = Hunter
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeStateHunterEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateHunterEvent")
local Status = require(game.ServerScriptService.BehaviourTree.Node.Utiles.Status)
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
	Arrête le mouvement du chasseur
]]
function Hunter:StopMove()
	self.moveState = nil
	self.patrolState = nil
	self.Humanoid:Move(Vector3.zero)
	self:ChangeState("Idle")
end


--[[
    Déplace le chasseur vers une position cible
    @param targetPosition: Vector3 - la position vers laquelle se déplacer
]]
function Hunter:Follow(position, timeout)
	timeout = timeout or 5

	-- target invalide → stop
	if not position then
		self:StopMove()
		return Status.FAILURE
	end

	-- start move si nécessaire
	if not self.moveState then
		self.moveState = {
			target = position,
			startTime = os.clock(),
			timeout = timeout
		}

		self:ChangeState("Walk")
		self.Humanoid:MoveTo(position)
		return Status.RUNNING
	end

	-- réajuster si la cible a bougé
	if (self.moveState.target - position).Magnitude > 2 then
		self.moveState.target = position
		self.Humanoid:MoveTo(position)
	end

	-- timeout
	if os.clock() - self.moveState.startTime > self.moveState.timeout then
		self:StopMove()
		return Status.FAILURE
	end

	-- arrivé
	if (self.Root.Position - self.moveState.target).Magnitude < 4 then
		self:StopMove()
		return Status.SUCCESS
	end

	return Status.RUNNING
end


--[[
    Déplace le chasseur vers une position cible
    @param targetPosition: Vector3 - la position vers laquelle se déplacer
]]
function Hunter:Patrol(radius)
	-- Si pas de state ou on est arrivé, générer nouvelle destination
	if not self.patrolState or (self.Root.Position - self.patrolState.target).Magnitude < 4 then
		self:StopMove()

		local offset = Vector3.new(
			math.random(-radius, radius),
			0,
			math.random(-radius, radius)
		)

		self.patrolState = {
			target = self.Root.Position + offset
		}

		self:ChangeState("Walk")
		self.Humanoid:MoveTo(self.patrolState.target)
		return Status.RUNNING
	end

	-- Si on est encore en route
	if self.patrolState then
		self.Humanoid:MoveTo(self.patrolState.target)
		return Status.RUNNING
	end

	return Status.SUCCESS
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
			return Status.SUCCESS
		end
		return Status.RUNNING
	end
	
	-- conditions
	local dist = (self.Root.Position - target.Root.Position).Magnitude
	if dist > self.attackRange then
		return Status.FAILURE
	end

	-- cooldown
	if os.clock() < (self.nextAttackTime or 0) then
		return Status.FAILURE
	end

	-- start attack
	self.isAttacking = true
	self.attackEndTime = os.clock() + self.attackDuration
	self.nextAttackTime = os.clock() + self.attackCooldown

	self:ChangeState("AttackPied")
	target:RemoveHealth(self.attackDamage)

	return Status.RUNNING
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