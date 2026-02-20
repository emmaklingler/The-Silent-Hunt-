local RabbitUtility = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangePoids = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangePoidsEvent")

function RabbitUtility.CalculePoids(rabbit, blackboard)

	-- =========================
	-- PERCEPTION
	-- =========================
	local stats = blackboard.perceptionRabbit
	local rabbitStats = rabbit.poidStat

	-- hunterDistance = 0 → très proche
	-- hunterDistance = 1 → très loin

	-- =========================
	-- FLEE
	-- =========================
	local PoidsFlee =
		(1 - stats.hunterDistance)
		* rabbitStats.survie
		* (1 - rabbitStats.fatigue)

	-- =========================
	-- HIDE
	-- =========================
	local PoidsHide =
		stats.stress
		* rabbitStats.survie
		* (1 - stats.hunterDistance)

	-- =========================
	-- EAT CARROT
	-- =========================
	local PoidsEat =
		stats.hunger
		* (1 - stats.hunterDistance)
		* rabbitStats.faim

	-- =========================
	-- WANDER
	-- =========================
	local PoidsWander =
		(1 - stats.hunterDistance)
		* (1 - stats.hunger)
		* (1 - stats.stress)

	-- =========================
	-- TABLEAU FINAL
	-- =========================
	local list = {
		Flee = PoidsFlee,
		Hide = PoidsHide,
		EatCarrot = PoidsEat,
		Wander = PoidsWander,
	}

	ChangePoids:FireAllClients(list)

	return list
end

return RabbitUtility
