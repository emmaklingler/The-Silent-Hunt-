local Status = require(script.Parent:WaitForChild("Status"))

local WeightedSelector = {}
WeightedSelector.__index = WeightedSelector

function WeightedSelector.new(children)
	return setmetatable({
		children = children or {},
		current = nil
	}, WeightedSelector)
end

function WeightedSelector:PickChild(blackboard)
	local totalWeight = 0

	for _, child in ipairs(self.children) do
		local w = type(child.weight) == "function"
			and child.weight(blackboard)
			or child.weight
		totalWeight += w
	end

	local rnd = math.random() * totalWeight
	local acc = 0

	for _, child in ipairs(self.children) do
		local w = type(child.weight) == "function"
			and child.weight(blackboard)
			or child.weight
		acc += w
		if rnd <= acc then
			return child.node
		end
	end
end

function WeightedSelector:Run(entity, blackboard)
	-- Si un node est déjà en cours, on continue
	if self.current then
		local s = self.current:Run(entity, blackboard)
		if s ~= Status.RUNNING then
			self.current = nil
		end
		return s
	end

	-- Sinon on choisit
	self.current = self:PickChild(blackboard)
	if not self.current then
		return Status.FAILURE
	end

	return self.current:Run(entity, blackboard)
end

return WeightedSelector
