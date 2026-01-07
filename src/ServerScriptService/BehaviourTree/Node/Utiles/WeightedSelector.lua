local Status = require(script.Parent:WaitForChild("Status"))

local WeightedSelector = {}
WeightedSelector.__index = WeightedSelector

function WeightedSelector.new(children)
	return setmetatable({
		children = children or {},
		current = nil,
		currentKey = nil, -- optionnel (debug)
	}, WeightedSelector)
end

local function getWeight(child, entity, blackboard)
	local w = child.weight
	if type(w) == "function" then
		w = w(entity, blackboard)
	end
	w = tonumber(w) or 0
	return w
end

function WeightedSelector:PickChild(entity, blackboard)
	local total = 0
	local weights = {}

	for i, child in ipairs(self.children) do
		local w = getWeight(child, entity, blackboard)
		weights[i] = w
		if w > 0 then
			total += w
		end
	end

	if total <= 0 then return nil end

	local rnd = math.random() * total
	local acc = 0

	for i, child in ipairs(self.children) do
		local w = weights[i]
		if w > 0 then
			acc += w
			if rnd <= acc then
				return child.node, (child.key or tostring(i))
			end
		end
	end

	return nil
end

-- 🔥 Réactif + préemption
function WeightedSelector:Run(entity, blackboard)
	-- on repick à CHAQUE tick
	local picked, key = self:PickChild(entity, blackboard)

	-- rien à faire
	if not picked then
		self.current = nil
		self.currentKey = nil
		return Status.FAILURE
	end

	-- si un autre choix est meilleur => switch immédiat
	if self.current ~= picked then
		self.current = picked
		self.currentKey = key
	end

	local s = self.current:Run(entity, blackboard)

	-- si fini, reset (le prochain tick repick)
	if s ~= Status.RUNNING then
		self.current = nil
		self.currentKey = nil
	end

	return s
end

return WeightedSelector
