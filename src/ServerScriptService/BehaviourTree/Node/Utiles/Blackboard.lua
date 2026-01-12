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

	self.state = "Idle"

    self.target = nil       

	self.lastKnownPosition = nil   

	self.lastStimulusTime = 0
	self.lastStimulusType = nil
    self.memoryDuration = 20
	

	self.hasVisual = false

	return self
end


function Blackboard:PushStimulus(stimulus)
	self.lastKnownPosition = stimulus.position
	self.lastStimulusTime = stimulus.time or os.clock()
	self.lastStimulusType = stimulus.type

	if stimulus.type == "Vision" and stimulus.source then
		self.target = stimulus.source
		self.hasVisual = true
	end
end

function Blackboard:SetSeenTarget(target)
	self:PushStimulus({
		type = "Vision",
		source = target,
		position = target.Root.Position,
		time = os.clock(),
	})
end

function Blackboard:UnsetSeenTarget()
	self.hasVisual = false
	self.target = nil
end

function Blackboard:HasValidTarget()
	if not self.target or not self.hasVisual then
		return false
	end

	if (os.clock() - self.lastStimulusTime) > self.memoryDuration then
		return false
	end

	if not self.target.Root or not self.target:IsAlive() or self.target:DansCachette() then
		return false
	end

	return true
end

function Blackboard:HasMemory()
	return self.lastKnownPosition ~= nil
	   and (os.clock() - self.lastStimulusTime) <= self.memoryDuration
end

function Blackboard:GetBestTargetOrPosition()
	if self:HasValidTarget() then
		return self.target, "Target"
	end

	if self:HasMemory() then
		return self.lastKnownPosition, "Position"
	end

	return nil, "None"
end

function Blackboard:ClearMemory()
	self.lastKnownPosition = nil
end



return Blackboard
