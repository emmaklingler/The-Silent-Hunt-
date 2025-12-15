local ReplicateStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicateStorage.Remote

local Manager = {}

Manager.Profiles = {}

function Manager.AddMoney(player, value)
	local profile = Manager.Profiles[player]
	if not profile or value <= 0 then return end
	profile.Data.Money += value
	--REMOTE pour avertir le joueur client
end

return Manager
