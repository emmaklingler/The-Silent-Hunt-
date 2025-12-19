local Status = require(script.Parent:WaitForChild("Status"))


local Selector = {}
Selector.__index = Selector

--[[
	Selector node: éxécute chaque enfant dans l'ordre jusqu'à ce qu'un enfant réussisse ou soit en cours d'exécution.
	Si un enfant réussit, le Selector retourne SUCCESS.
	@children: table - une liste de noeuds enfants
]]
function Selector.new(children)
	return setmetatable({ children = children or {} }, Selector)
end

-- Exécute le noeud Selector
function Selector:Run(entity, blackboard)
	for _, child in self.children do
		local s = child:Run(entity, blackboard)
		if s == Status.SUCCESS then return Status.SUCCESS end
		if s == Status.RUNNING then return Status.RUNNING end
	end
	return Status.FAILURE
end

return Selector
