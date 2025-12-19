local Status = require(script.Parent:WaitForChild("Status"))

local Sequence = {}
Sequence.__index = Sequence

--[[
	Sequence node: éxécute chaque enfant dans l'ordre jusqu'à ce qu'un enfant échoue ou soit en cours d'exécution.
	Si un enfant échoue, le Sequence retourne FAILURE.
	@children: table - une liste de noeuds enfants
]]
function Sequence.new(children)
	return setmetatable({ children = children or {} }, Sequence)
end

-- Exécute le noeud Sequence
function Sequence:Run(entity, blackboard)
	for _, child in self.children do
		local s = child:Run(entity, blackboard)
		if s == Status.FAILURE then return Status.FAILURE end
		if s == Status.RUNNING then return Status.RUNNING end
	end
	return Status.SUCCESS
end

return Sequence
