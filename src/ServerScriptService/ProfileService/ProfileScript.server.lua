----- SERVICES -----
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

----- MODULES -----
local ProfileTemplate = require(game.ServerScriptService.ProfileService.ProfileTemplate)
local ProfileService = require(game.ServerScriptService.ProfileService.ProfileService)
local Manager = require(game.ServerScriptService.ProfileService.Manager)
local InitGame = require(ServerScriptService.Game.InitGame)
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

----- PROFILE -----
local ProfileStore = ProfileService.GetProfileStore("DEV1", ProfileTemplate)

----- VARIABLES -----
local template = nil
local GAME_STARTED = false
local TIMEOUT = 10 -- ⏱ max d'attente en secondes

local startTime = os.time()

----- START GAME -----
local function TryStartGame()
	if GAME_STARTED then return end
	if not template then return end

	local currentPlayers = #Players:GetPlayers()

	print("Players:", currentPlayers, "/", template.nbPlayers)

	-- ✅ Tous les joueurs sont là
	if currentPlayers >= template.nbPlayers then
		print("All players joined → start")
		GAME_STARTED = true
		task.wait(2)
		InitGame:StartGame(template)
		return
	end

	-- ⏱ Timeout atteint → start quand même
	if os.time() - startTime >= TIMEOUT then
		print("Timeout reached → start with", currentPlayers, "players")
		GAME_STARTED = true
		task.wait(2)
		InitGame:StartGame(template)
	end
end

----- PROFILE LOADED -----
local function DoSomethingWithALoadedProfile(player, profile)
	if GAME_STARTED then
		player:Kick("Game already in progress")
		return
	end

	profile.Data = table.clone(ProfileTemplate)

	local joinData = player:GetJoinData()
	local teleportData = joinData and joinData.TeleportData

	if teleportData then
		print("TeleportData:", teleportData)
	else
		print("No teleport data → fallback")
		teleportData = {
			nbPlayers = 1,
			nbBots = 10,
			lobbyName = "DefaultLobby"
		}
	end

	-- ✅ SET TEMPLATE UNE SEULE FOIS
	if not template then
		template = teleportData
		template.nbPlayers = template.nbPlayers or 1
		template.nbBots = template.nbBots or 0
	end

	profile.Data.LogInTimes += 1
	PlayerManager:CreateRabbit(player, profile)

	-- 🔥 CHECK START
	task.delay(1, TryStartGame)
end

----- PLAYER ADDED -----
local function PlayerAdded(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			Manager.Profiles[player] = nil
			player:Kick()
		end)

		if player:IsDescendantOf(Players) then
			Manager.Profiles[player] = profile
			DoSomethingWithALoadedProfile(player, profile)
		else
			profile:Release()
		end
	else
		player:Kick()
	end
end

----- INIT -----
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = Manager.Profiles[player]

	PlayerManager:RemoveRabbit(player)

	if profile then
		profile:Release()
	end

	if GAME_STARTED then return end

	-- 🔥 si quelqu’un quitte → on recheck
	task.delay(1, TryStartGame)
end)