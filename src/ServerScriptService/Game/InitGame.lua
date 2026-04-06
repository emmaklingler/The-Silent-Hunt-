-- local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

-- local HungerSystem = require(game.ServerScriptService.Game.Systems.HungerSystem)
-- local TimerSystem = require(game.ServerScriptService.Game.Systems.TimerSystem)
-- local System = require(game.ServerScriptService.Game.Systems.System)

-- local HunterClass = require(game.ServerScriptService.Hunter.HunterClass)
-- local HunterBT = require(game.ServerScriptService.Hunter.HunterBT.HunterBT)

-- local RabbitBotClass = require(game.ServerScriptService.RabbitBot.RabbitBotClass)
-- local RabbitBT = require(game.ServerScriptService.RabbitBot.RabbitBT)

-- local TeleportService = game:GetService("TeleportService")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local Players = game:GetService("Players")

-- local GameManager = {}
-- GameManager.__index = GameManager

-- GameManager.State = "Lobby"

-- --------------------------------------------------------
-- -- TELEPORT
-- --------------------------------------------------------

-- local function ToMenu()
-- 	local PLACE_ID = 70426492448163
-- 	print("Teleporting players...")

-- 	TeleportService:TeleportPartyAsync(
-- 		PLACE_ID,
-- 		Players:GetPlayers()
-- 	)
-- end

-- --------------------------------------------------------
-- -- START GAME
-- --------------------------------------------------------

-- function GameManager:StartGame(teleportData)

-- 	if GameManager.State ~= "Lobby" then
-- 		warn("StartGame appelé alors que pas en Lobby")
-- 		return false
-- 	end

-- 	GameManager.State = "InGame"
-- 	GameManager.data = teleportData

-- 	print("=== START GAME ===")

-- 	----------------------------------------------------
-- 	-- INIT SYSTEMES
-- 	----------------------------------------------------

-- 	HungerSystem:Init(PlayerManager:GetAllRabbits())
-- 	TimerSystem:Init(PlayerManager:GetAllRabbits(), GameManager.EndGame)

-- 	task.spawn(function()
-- 		System:Start()
-- 	end)

-- 	----------------------------------------------------
-- 	-- SPAWN JOUEURS
-- 	----------------------------------------------------

-- 	for _, rabbit in PlayerManager:GetAllRabbits() do
-- 		rabbit:Spawn()
-- 	end

-- 	print("Players spawned")

-- 	----------------------------------------------------
-- 	-- SPAWN HUNTER
-- 	----------------------------------------------------

-- 	local HunterModel = workspace:FindFirstChild("Chasseur_Test")
-- 	if not HunterModel then
-- 		warn("Chasseur_Test introuvable dans workspace")
-- 		return false
-- 	end

-- 	local Hunter = HunterClass.new(HunterModel)
-- 	HunterBT.Start(Hunter)

-- 	print("Hunter started")

--     ----------------------------------------------------
--     -- SPAWN RABBIT BOT IA (TEST SIMPLE)
--     ----------------------------------------------------

--    ----------------------------------------------------
--     -- SPAWN RABBIT BOT IA
--     ----------------------------------------------------

--     local rabbitTemplate = game.ServerStorage:WaitForChild("Asset"):WaitForChild("rabbitbot")

--     local rabbitBotModel = rabbitTemplate:Clone()
--     rabbitBotModel.Name = "RabbitBot"
--     rabbitBotModel.Parent = workspace

--     print("RabbitBot cloné dans workspace")

--     -- Positionner au spawn joueur pour le voir
--     local spawnFolder = workspace:FindFirstChild("PlayerSpawn")
--     if spawnFolder then
--         local spawnPoint = spawnFolder:GetChildren()[1]
--         rabbitBotModel:PivotTo(spawnPoint.CFrame + Vector3.new(0,5,0))
--     end

--     local rabbitBot = RabbitBotClass.new(rabbitBotModel)
--     local rabbitBotBT = RabbitBT.new(rabbitBot)

--     rabbitBotBT:Start()
--     print("Bot position:", rabbitBotModel:GetPivot().Position)

--     print("RabbitBot IA démarré")

-- 	----------------------------------------------------
-- 	-- START EVENT CLIENT
-- 	----------------------------------------------------

-- 	StartEvent:FireAllClients(teleportData)

-- 	print("=== GAME STARTED ===")

-- 	return true
-- end

-- --------------------------------------------------------
-- -- END GAME
-- --------------------------------------------------------

-- function GameManager:EndGame()

-- 	if GameManager.State ~= "InGame" then
-- 		warn("EndGame appelé alors que pas InGame")
-- 		return false
-- 	end

-- 	GameManager.State = "Lobby"

-- 	System:Stop()
-- 	HunterBT.Stop()

-- 	print("Game Ended")

-- 	ToMenu()

-- 	return true
-- end

-- return GameManager























-- local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

-- local HungerSystem = require(game.ServerScriptService.Game.Systems.HungerSystem)
-- local TimerSystem = require(game.ServerScriptService.Game.Systems.TimerSystem)
-- local System = require(game.ServerScriptService.Game.Systems.System)

-- local HunterClass = require(game.ServerScriptService.Hunter.HunterClass)
-- local HunterBT = require(game.ServerScriptService.Hunter.HunterBT.HunterBT)

-- local TeleportService = game:GetService("TeleportService")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local StartEvent = ReplicatedStorage.Remote:WaitForChild("StartGameEvent")

-- local GameManager = {}
-- GameManager.__index = GameManager

-- GameManager.State = "Lobby"

-- local function ToMenu(list)
--     local PLACE_ID = 70426492448163
--     print("TP")
    
--     TeleportService:TeleportPartyAsync(
--         PLACE_ID,
--         game:GetService("Players"):GetPlayers()
--     )
-- end

-- --[[
--     Initialisation de la game
-- ]]
-- function GameManager:StartGame(teleportData)

--     GameManager.data = teleportData

--     if GameManager.State ~= "Lobby" then 
--         return warn("Start une game alors qu'elle n'est pas en lobby") 
--     end

--     GameManager.State = "InGame"

--     -- Init les systèmes
--     HungerSystem:Init(PlayerManager:GetAllRabbits())
--     TimerSystem:Init(PlayerManager:GetAllRabbits(), GameManager.EndGame)

--     -- Démarre les systèmes
--     task.spawn(function()
--         System:Start()
--     end)

--     -- Pour chaque joueur on spawn le character
--     for _, rabbit in PlayerManager:GetAllRabbits() do
--         rabbit:Spawn()
--     end

--     -- Créer le chasseur
--     local HunterModel = workspace:WaitForChild("Chasseur_Test")
--     local Hunter = HunterClass.new(HunterModel)

--     HunterBT.Start(Hunter) 

--     StartEvent:FireAllClients(teleportData)

--     return true
-- end
    
-- --[[
--     Termine la partie -> Envoie les joueur dans un menu pour qu'il quit
-- ]]
-- function GameManager:EndGame()

--     if GameManager.State ~= "InGame" then 
--         return warn("End une game alors qu'elle n'est pas en game") 
--     end

--     GameManager.State = "Lobby"

--     -- Arrête les systèmes
--     System:Stop()

--     HunterBT.Stop()
    
--     print("Game Ended")

--     ToMenu(PlayerManager:GetAllRabbits())

--     return true
-- end

-- return GameManager


local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)
local HungerSystem = require(game.ServerScriptService.Game.Systems.HungerSystem)
local TimerSystem = require(game.ServerScriptService.Game.Systems.TimerSystem)
local System = require(game.ServerScriptService.Game.Systems.System)
local HunterClass = require(game.ServerScriptService.Hunter.HunterClass)
local HunterBT = require(game.ServerScriptService.Hunter.HunterBT.HunterBT)
local RabbitBotClass = require(game.ServerScriptService.RabbitBot.RabbitBotClass)

local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local StartEvent = ReplicatedStorage.Remote:WaitForChild("StartGameEvent")
local EndGameEvent = ReplicatedStorage.Remote:WaitForChild("EndGameEvent")

local GameManager = {}
GameManager.__index = GameManager
GameManager.State = "Lobby"


function GameManager:StartGame(teleportData)
    print(teleportData.nbBots)
    if GameManager.State ~= "Lobby" then return false end
    GameManager.State = "InGame"
    GameManager.data = teleportData

    print("=== START GAME ===")

    -- 1. Init Systèmes
    HungerSystem:Init(PlayerManager:GetAllRabbits())
    TimerSystem:Init(PlayerManager:GetAllRabbits(), GameManager.EndGame)
    task.spawn(function() System:Start() end)

    -- 2. Spawn Joueurs
    for _, rabbit in PlayerManager:GetAllRabbits() do
        rabbit:Spawn()
    end

    -- 3. Spawn Hunter
    local HunterModel = workspace:FindFirstChild("Chasseur_Test")
    if HunterModel then
        local Hunter = HunterClass.new(HunterModel)
        HunterBT.Start(Hunter)
    end

    -- 4. Spawn RabbitBot (IA)
    for i = 1, teleportData.nbBots do
        local rabbitBot = RabbitBotClass.spawn()
        PlayerManager:AddBot(rabbitBot) -- Ajoute le bot à la liste des cibles pour la détection du chasseur
    end

    -- 5. Lancement Client
    StartEvent:FireAllClients(teleportData)
    print("=== GAME STARTED ===")
    return true
end

function GameManager:EndGame()
    if GameManager.State ~= "InGame" then return false end
    GameManager.State = "Lobby"
    System:Stop()
    HunterBT.Stop()

    for _, rabbit in PlayerManager:GetAllRabbits() do
        if rabbit:IsAlive() then
            EndGameEvent:FireClient(rabbit.Player, "Win")
        else
            EndGameEvent:FireClient(rabbit.Player, "Lose")
        end
    end
    

    local PLACE_ID = 70426492448163
	print("Teleporting players...")

    task.delay(5, function()
        TeleportService:TeleportPartyAsync(
            PLACE_ID,
            Players:GetPlayers()
        )
    end)

    return true
end

return GameManager