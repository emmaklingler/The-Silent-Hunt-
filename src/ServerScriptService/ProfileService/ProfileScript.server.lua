----- Loaded Modules -----
local ProfileTemplate = require(game.ServerScriptService.ProfileService.ProfileTemplate)
local ProfileService = require(game.ServerScriptService.ProfileService.ProfileService)
local Manager = require(game.ServerScriptService.ProfileService.Manager)

local ReplicateStorage = game:GetService("ReplicatedStorage")
local PlayerJoinedEvent = ReplicateStorage.Remote:WaitForChild("PlayerJoinedEvent")
local PlayerReadyEvent = ReplicateStorage.Remote:WaitForChild("PlayerReadyEvent")

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local InitGame = require(ServerScriptService.Game.InitGame)
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

-- BASE DEV1 
local ProfileStore = ProfileService.GetProfileStore(
	"DEV1",
	ProfileTemplate
)
local template = nil
local nbPlayers = 0

local GRACE_DELAY = 2
local FINAL_COUNTDOWN = 5

local graceTask = nil
local countdownTask = nil

local function CancelTimers()
	if graceTask then
		task.cancel(graceTask)
		graceTask = nil
	end

	if countdownTask then
		task.cancel(countdownTask)
		countdownTask = nil
	end
end

function StartFinalCountdown(teleportData)
	countdownTask = task.spawn(function()
		for i = FINAL_COUNTDOWN, 1, -1 do
			print(i)
			task.wait(1)

			if InitGame.State ~= "Lobby" then
				return
			end
		end
	
		-- Countdown fini → start game
		task.wait(3)
		InitGame:StartGame(teleportData)
	end)
end

local function StartGracePeriod(teleportData)
	CancelTimers()

	graceTask = task.spawn(function()
		task.wait(GRACE_DELAY)

		-- Personne n’a rejoint pendant 5s → lancer le countdown
		StartFinalCountdown(teleportData)
	end)
end

PlayerReadyEvent.OnServerEvent:Connect(function()
	nbPlayers += 1
	PlayerJoinedEvent:FireAllClients(nbPlayers, template)

	-- Tous les joueurs sont là → start immédiat
	if nbPlayers >= template.nbPlayers then
		task.wait(3)
		CancelTimers()
		InitGame:StartGame(template)
		return
	end

	-- Un joueur vient d’arriver → reset la logique
	StartGracePeriod(template)
end)

local function DoSomethingWithALoadedProfile(player, profile)
	if InitGame.State ~= "Lobby" then
		-- Si la game a déjà commencé, on  kick le joueur
		player:Kick("Game already in progress")
		return
	end
	profile.Data = ProfileTemplate --Pour reset les données
	--print(profile.Data)
	local joinData = player:GetJoinData()
    local teleportData = joinData.TeleportData
	if teleportData then
		print("TeleportData found:", teleportData)
	else
		warn("Pas de data")
		teleportData = {
			nbPlayers = 1,
			nbBots = 0,
			lobbyName = "DefaultLobby"
		}
	end
	if not template then
		template = teleportData
	end
	profile.Data.LogInTimes += 1
	PlayerManager:CreateRabbit(player, profile)
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
	PlayerManager:RemoveRabbit(player)
	if profile ~= nil then
		profile:Release()
	end
	
	if InitGame.State ~= "Lobby" then return end
	nbPlayers -= 1
	PlayerJoinedEvent:FireAllClients(nbPlayers, template)
end)