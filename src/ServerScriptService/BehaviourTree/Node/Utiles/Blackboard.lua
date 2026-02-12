local Blackboard = {}
Blackboard.__index = Blackboard
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangePerception = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangePerceptionEvent")

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

	self.perception = {
		vieLapin = 0,
		distanceLapin = math.huge,
		ligneDeVue = 0,
		position = 0,
	}

	self.poids = {}

	return self
end


function Blackboard:UpdatePerception(chasseur)
	if self:HasMemory() then
		self.perception.position = math.clamp(1 - (os.clock() - self.lastStimulusTime)/self.memoryDuration, 0, 1)
		self.perception.distanceLapin = math.clamp((chasseur.Root.Position - self.lastKnownPosition).Magnitude / 200, 0, 1)
	else
		self.perception.position = 0
		self.perception.distanceLapin = 1
	end

	if not self.target or not self.target.Root then
		if self:HasMemory() then
			self.perception.ligneDeVue = math.clamp(1 - (os.clock() - self.lastStimulusTime)/self.memoryDuration*4, 0, 1)
		else
			self.perception.ligneDeVue = 0
		end
		self.perception.vieLapin = 0
		ChangePerception:FireAllClients(self.perception)
		return
	end
	-- Distance
	local dist = (chasseur.Root.Position - self.target.Root.Position).Magnitude
	self.perception.distanceLapin = math.clamp(dist / 200, 0, 1)

	-- Vie
	self.perception.vieLapin = math.clamp(self.target.Health / self.target.MaxHealth, 0, 1)

	-- Ligne de vue
	self.perception.ligneDeVue = math.clamp(1 - (os.clock() - self.lastStimulusTime)/self.memoryDuration, 0, 1)

	ChangePerception:FireAllClients(self.perception)
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
	if self.target and self.target.Root and not self.target:IsAlive() then
		-- Si la cible est morte, on nettoie la mémoire
		self:ClearMemory()
	end
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


function Blackboard:SetPoids(poidsTable)
	self.poids = poidsTable
end
function Blackboard:GetPoids(action)
	return self.poids and self.poids[action] or 0
end


return Blackboard
