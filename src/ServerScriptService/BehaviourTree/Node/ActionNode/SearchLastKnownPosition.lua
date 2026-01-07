local SearchLastKnownPosition = {}
SearchLastKnownPosition.__index = SearchLastKnownPosition

local Status = require(script.Parent.Parent.Utiles.Status)

-- durée max de recherche après perte de vue (en secondes)
local SEARCH_DURATION = 3.0

-- distance à laquelle on considère que la zone est atteinte
local ARRIVAL_DIST = 4

function SearchLastKnownPosition.new()
	return setmetatable({}, SearchLastKnownPosition)
end

function SearchLastKnownPosition:Run(hunter, blackboard)
	-- pas de position connue → inutile
	if not blackboard.lastKnownPosition or not blackboard.lostTargetTime then
		return Status.FAILURE
	end

	local now = os.clock()

	-- temps écoulé depuis la perte
	if (now - blackboard.lostTargetTime) > SEARCH_DURATION then
		-- abandon de la recherche
		blackboard.lastKnownPosition = nil
		return Status.FAILURE
	end

	if not hunter.Root then
		return Status.FAILURE
	end

	-- distance à la dernière position connue
	local dist = (hunter.Root.Position - blackboard.lastKnownPosition).Magnitude

	-- arrivé dans la zone
	if dist <= ARRIVAL_DIST then
		return Status.SUCCESS
	end

	-- on avance vers la dernière position
	local result = hunter:Follow(blackboard.lastKnownPosition, 5)
	return result or Status.RUNNING
end

return SearchLastKnownPosition
