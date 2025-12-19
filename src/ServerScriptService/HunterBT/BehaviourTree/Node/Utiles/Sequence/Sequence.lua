--- Sequence.lua
local Node = script.Parent
assert(Node, "Selector.lua has no parent")

local Utiles = Node.Parent
assert(Utiles, "Selector.lua must be inside a folder under Utiles")

local StatusFolder = Utiles:WaitForChild("Status")
local Status = require(StatusFolder:WaitForChild("Status"))


local Sequence = {}
Sequence.__index = Sequence

function Sequence.new(children)
	return setmetatable({ children = children or {} }, Sequence)
end

function Sequence:Run(entity, blackboard)
	for _, child in ipairs(self.children) do
		local s = child:Run(entity, blackboard)
		if s == Status.FAILURE then return Status.FAILURE end
		if s == Status.RUNNING then return Status.RUNNING end
	end
	return Status.SUCCESS
end

return Sequence
