local MakeTrap = {}
MakeTrap.__index = MakeTrap

local Status = require(script.Parent.Parent.Utiles.Status)

function MakeTrap.new(arriveRadius)
	local self = setmetatable({}, MakeTrap)
	self.arriveRadius = arriveRadius or 6
	return self
end
--[[
	Noeud MakeTrap: fait poser un piège au chasseur à la dernière position vue de la cible
	@param chasseur: classe du chasseur
	@param blackboard: table de données partagées
	@return Status.SUCCESS si le piège a été posé,
			Status.FAILURE sinon
]]
function MakeTrap:Run(chasseur, blackboard)
	-- DEBUG (optionnel)
	-- Fais gaffe: blackboard.lastKnownPosition peut être nil
	local age = os.clock() - (blackboard.lastStimulusTime or 0)
	print("[MakeTrap] mem=", blackboard:HasMemory(),
		"validTarget=", blackboard:HasValidTarget(),
		"age=", age,
		"pos=", tostring(blackboard.lastKnownPosition))

	-- On ne pose un piège que si on est en mode mémoire (plus de visuel)
	if blackboard:HasValidTarget() then
		return Status.FAILURE
	end

	if not blackboard:HasMemory() then
		return Status.FAILURE
	end

	local pos = blackboard.lastKnownPosition
	if not pos then
		return Status.FAILURE
	end

	local dist = (chasseur.Root.Position - pos).Magnitude
	print("[MakeTrap] dist=", dist, "arriveRadius=", self.arriveRadius)

	-- Pas encore arrivé au point mémoire -> pas de piège
	if dist > self.arriveRadius then
		return Status.FAILURE
	end

	-- Pose le piège exactement à la dernière position vue
	if not chasseur.TryPlaceTrapAt then
		warn("[MakeTrap] Hunter has no TryPlaceTrapAt(position) method")
		return Status.FAILURE
	end

	local ok = chasseur:TryPlaceTrapAt(pos)

	if ok then
		-- Nettoie la mémoire pour éviter le spam de pièges
		if blackboard.ClearMemory then
			blackboard:ClearMemory()
		else
			blackboard.lastKnownPosition = nil
		end
		return Status.SUCCESS
	end

	return Status.FAILURE
end

return MakeTrap
