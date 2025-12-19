--Selector.lua
local Node = script.Parent
assert(Node, "Selector.lua has no parent")

local Utiles = Node.Parent
assert(Utiles, "Selector.lua must be inside a folder under Utiles")

local StatusFolder = Utiles:WaitForChild("Status")
local Status = require(StatusFolder:WaitForChild("Status"))


local Selector = {}
Selector.__index = Selector

function Selector.new(children)
	return setmetatable({ children = children or {} }, Selector)
end

function Selector:Run(entity, blackboard)
	for _, child in ipairs(self.children) do
		local s = child:Run(entity, blackboard)
		if s == Status.SUCCESS then return Status.SUCCESS end
		if s == Status.RUNNING then return Status.RUNNING end
	end
	return Status.FAILURE
end

return Selector
