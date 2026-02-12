local Status = require(script.Parent:WaitForChild("Status"))

local WeightedSelector = {}
WeightedSelector.__index = WeightedSelector

function WeightedSelector.new(children)
	return setmetatable({
		children = children or {},
		current = nil,
		locked = false,
		decisionCooldown = 0.25,
		nextDecisionTime = 0,
	}, WeightedSelector)
end

-- utilitaire poids
local function getWeight(child, entity, blackboard)
	if type(child.weight) == "function" then
		return child.weight(entity, blackboard)
	end
	return child.weight or 0
end

function WeightedSelector:PickChild(entity, blackboard)

	local bestChild = nil
	local bestWeight = -math.huge
	local total = 0
	local weights = {}

	for _, child in ipairs(self.children) do
		local w = math.max(0, getWeight(child, entity, blackboard))
		weights[child] = w
		total += w

		if w > bestWeight then
			bestWeight = w
			bestChild = child
		end
	end

	if total <= 0 then
		return nil, 0
	end

	-- 60% max / 40% random
	if math.random() < 0.6 then
		return bestChild, bestWeight
	end

	-- random soft
	local rnd = math.random() * total
	local acc = 0
	for child, w in pairs(weights) do
		acc += w
		if rnd <= acc then
			return child, w
		end
	end
end


function WeightedSelector:Run(entity, blackboard)

	-------------------------------------------------
	-- ACTION BLOQUÉE
	-------------------------------------------------
	if self.locked and self.current then
		local s = self.current.node:Run(entity, blackboard)

		if s ~= Status.RUNNING then
			self.locked = false
			self.current = nil
		end

		return s
	end

	-------------------------------------------------
	-- CHOIX UTILITAIRE
	-------------------------------------------------
	local chosen, chosenWeight = self:PickChild(entity, blackboard)
	if not chosen then
		return Status.FAILURE
	end

	-------------------------------------------------
	-- GESTION PRIORITÉ (INTERRUPTION UNIQUEMENT)
	-------------------------------------------------
	if self.current and self.currentStatus == Status.RUNNING then
	
		local currentPriority = self.current.priority or 0
		local chosenPriority = chosen.priority or 0

		-- Si la nouvelle action a une priorité STRICTEMENT plus haute
		if chosenPriority > currentPriority then
			-- on interrompt
			self.current = nil
		else
			-- sinon on continue l'action actuelle
			chosen = self.current
		end
	end


	-------------------------------------------------
	-- ANTI-JITTER (HYSTERESIS)
	-------------------------------------------------
	if self.current then
		local currentWeight = getWeight(self.current, entity, blackboard)

		-- si l'action actuelle reste "assez bonne", on la garde
		if currentWeight >= chosenWeight * 0.85 then
			chosen = self.current
		end
	end

	-------------------------------------------------
	-- CHANGEMENT D'ACTION
	-------------------------------------------------
	local now = os.clock()

	local canReevaluate = now >= self.nextDecisionTime

	if canReevaluate then
		-- On choisit une nouvelle action
		self.nextDecisionTime = now + self.decisionCooldown
		if chosen.nom ~= "Logistique" and chosen.nom ~= "Combat" then 	
			print(chosen.nom)
		end
	else
		-- si pas encore le droit de réévaluer, on garde l'actuelle
		chosen = self.current or chosen
	end

	self.current = chosen

	-- si action non interruptible → lock
	if chosen.block then
		self.locked = true
	end

	

	local status = chosen.node:Run(entity, blackboard)
	self.currentStatus = status
	
	-- si terminé immédiatement
	if status ~= Status.RUNNING then
		self.locked = false
		self.current = nil
		self.currentStatus = nil
	end


	return status
end

return WeightedSelector
