local Blackboard = {}
Blackboard.__index = Blackboard

--[[
    Contients les données partagées entre les différents noeuds du Behaviour Tree
    
    target: la classe de la cible actuelle
    isBusy: empêche le changement d'action lorsqu'une action est en cours
    state: l'état actuel de l'entité (Idle, Patrolling, Chasing, ...)
]]
function Blackboard.new()
	local self = setmetatable({}, Blackboard)

	self.target = nil
	self.state = "Idle"

	return self
end

return Blackboard
