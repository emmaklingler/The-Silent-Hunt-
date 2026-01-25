local Status = require(script.Parent:WaitForChild("Status"))

local MemorySequence = {}
MemorySequence.__index = MemorySequence

--[[
	MemorySequence node: Comme un Sequence, mais se souvient de l'enfant en cours d'exécution.
    Si un enfant est en cours d'exécution, le MemorySequence reprendra à partir de cet enfant lors du prochain Tick.
    Si un enfant échoue, le MemorySequence retourne FAILURE et réinitialise son état.

    Permet par exemple de regarder si il a une cible au début et ensuite de continuer les actions même si la cible est perdue.

	@children: table - une liste de noeuds enfants
]]
function MemorySequence.new(children)
    local self = setmetatable({}, MemorySequence)
    self.children = children
    self.currentIndex = 1
    return self
end

function MemorySequence:Run(hunter, blackboard)
    while self.currentIndex <= #self.children do
        local status = self.children[self.currentIndex]:Run(hunter, blackboard)

        if status == Status.RUNNING then
            return Status.RUNNING
        end

        if status == Status.FAILURE then
            self.currentIndex = 1
            return Status.FAILURE
        end

        self.currentIndex += 1
    end

    self.currentIndex = 1
    return Status.SUCCESS
end

return MemorySequence