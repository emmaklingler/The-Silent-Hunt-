local HunterUtility = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangePoids = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangePoidsEvent")


-- Fonction pour calculer les poids en fonction de la situation actuelle
function HunterUtility.CalculePoids(hunter, blackboard)
	--Combat
	local stats = blackboard.perception
	local hunterStats = hunter.poidStat

	local PoidsCorpsACorps = hunterStats.aggressivite * (1 - stats.distanceLapin) * (1 - hunterStats.fatigue)
	if (stats.distanceLapin >  0.08) then
		PoidsCorpsACorps = 0
	end

	local CourbeBalleChargeur = math.min(1,math.sqrt(hunterStats.balleChargeur) * 1.2)
	local CourbeDistanceLapin = math.max(0, math.min(1,1-((math.abs(stats.distanceLapin - 0.4)+0.25)^3)))
	local CourbeFatigue = math.max(0,(hunterStats.fatigue^3) * 0.8)

	local PoidsTir = CourbeBalleChargeur*math.max(0,CourbeDistanceLapin-CourbeFatigue)
	local PoidsPoursuite = (1-hunterStats.fatigue) * stats.ligneDeVue * hunterStats.patience

	--Logistique

	local PoidsRecharge = (1-hunterStats.balleChargeur) * hunterStats.balleReserve
	local PoidsGetMunitions = (1-hunterStats.balleReserve) * (1-stats.ligneDeVue) * (1-hunterStats.fatigue/2)
	local PoidsPoursuitePosition = hunterStats.patience * (1-stats.ligneDeVue) * (1-hunterStats.fatigue)/2 * stats.position

	local CourbeStockBalle = ((hunterStats.trapsStock-0.2)^3)/1.5 + 0.1
	local CourbeFatiguePiege = math.sin((hunterStats.fatigue-0.1)+2)

	local PoidsPlacePiege = ((stats.position * CourbeFatiguePiege * CourbeStockBalle)-stats.ligneDeVue)/50

	--Exploration
	local PoidsExploration = ((1-stats.ligneDeVue) * (1-math.max(PoidsRecharge, PoidsGetMunitions, PoidsPoursuitePosition)))


	
	local list = {
		AttaquePied = PoidsCorpsACorps,
		Tir = PoidsTir,
		Poursuite = PoidsPoursuite,

		Recharge = PoidsRecharge,
		ChercheMunitions = PoidsGetMunitions,
		PoursuitePosition = PoidsPoursuitePosition,
		PlacePiege = PoidsPlacePiege,
		
		Exploration = PoidsExploration,
	}
	ChangePoids:FireAllClients(list)
	return list
end

return HunterUtility