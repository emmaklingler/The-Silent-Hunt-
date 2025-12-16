----- Loaded Modules -----
local ProfileTemplate = require(game.ServerScriptService.ProfileService.ProfileTemplate)
local ProfileService = require(game.ServerScriptService.ProfileService.ProfileService)
local Manager = require(game.ServerScriptService.ProfileService.Manager)

local ReplicateStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicateStorage.Remote

local Players = game:GetService("Players")
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)


-- BASE DEV1 
local ProfileStore = ProfileService.GetProfileStore(
	"DEV1",
	ProfileTemplate
)


local function DoSomethingWithALoadedProfile(player, profile)
	--print(profile.Data)
	profile.Data = ProfileTemplate --Pour reset
	profile.Data.LogInTimes = profile.Data.LogInTimes + 1
    PlayerManager:CreateRabbit(player, profile):Spawn() --Pour Tester
	
end

local function PlayerAdded(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			Manager.Profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			Manager.Profiles[player] = profile
			DoSomethingWithALoadedProfile(player, profile)
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		player:Kick() 
	end
end

----- Initialize -----

-- In case Players have joined the server earlier than this script ran:
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

----- Connections -----

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	local profile = Manager.Profiles[player]
	if profile ~= nil then
		profile:Release()
	end
	
	--Clear le champ
end)