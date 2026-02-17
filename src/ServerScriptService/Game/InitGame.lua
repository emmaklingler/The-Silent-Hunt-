local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local HungerSystem = require(game.ServerScriptService.Game.Systems.HungerSystem)
local TimerSystem = require(game.ServerScriptService.Game.Systems.TimerSystem)
local System = require(game.ServerScriptService.Game.Systems.System)

local HunterClass = require(game.ServerScriptService.Hunter.HunterClass)
local HunterBT = require(game.ServerScriptService.Hunter.HunterBT.HunterBT)

local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StartEvent = ReplicatedStorage.Remote:WaitForChild("StartGameEvent")


local RabbitBotClass = require(game.ServerScriptService.RabbitBot.RabbitBotClass)
local RabbitBT = require(game.ServerScriptService.RabbitBot.RabbitBT)

local GameManager = {}
GameManager.__index = GameManager


GameManager.State = "Lobby"

local function ToMenu(list)
    local PLACE_ID = 70426492448163
	print("TP")
	-- Téléportation de tous les joueurs
	TeleportService:TeleportPartyAsync(
		PLACE_ID,
        game:GetService("Players"):GetPlayers()
	)
end

--[[
    Initialisation de la game
]]
function GameManager:StartGame(teleportData)
    GameManager.data = teleportData
    if GameManager.State ~= "Lobby" then 
        return warn("Start une game alors qu'elle n'est pas en lobby") 
    end
    GameManager.State = "InGame"
    --Init les systèmes
    HungerSystem:Init(PlayerManager:GetAllRabbits())
    TimerSystem:Init(PlayerManager:GetAllRabbits(), GameManager.EndGame)

    --Démarre les systèmes
    task.spawn(function()
        System:Start()
    end)

    --Pour chaque joueur on spawn le character
    for _, rabbit in PlayerManager:GetAllRabbits() do
        rabbit:Spawn()
    end

    --Créer le chasseur : 
    local HunterModel = workspace:WaitForChild("Chasseur_Test")
    local Hunter = HunterClass.new(HunterModel)

    HunterBT.Start(Hunter) 
    -- =========================
    -- SPAWN BOT LAPIN IA
    -- =========================
    local rabbitBotModel = workspace:WaitForChild("rabbitbot")
    local rabbitBot = RabbitBotClass.new(rabbitBotModel)
    local rabbitBotBT = RabbitBT.new(rabbitBot)

    rabbitBotBT:Start(Hunter)

    StartEvent:FireAllClients(teleportData)

    return true

    
end
    
--[[
    Termine la partie -> Envoie les joueur dans un menu pour qu'il quit
]]
function GameManager:EndGame()
    if GameManager.State ~= "InGame" then 
        return warn("End une game alors qu'elle n'est pas en game") 
    end
    GameManager.State = "Lobby"

    --Arrête les systèmes
    System:Stop()

    
    HunterBT.Stop()
    
    print("Game Ended")
    ToMenu(PlayerManager:GetAllRabbits())
    return true
end




return GameManager
