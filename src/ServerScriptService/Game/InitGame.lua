--Plus Tard
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)
local HungerSystem = require(game.ServerScriptService.Game.Systems.HungerSystem)
local System = require(game.ServerScriptService.Game.Systems.System)
local HunterClass = require(game.ServerScriptService.Hunter.HunterClass)
local HunterBT = require(game.ServerScriptService.Hunter.HunterBT.HunterBT)

local GameManager = {}
GameManager.__index = GameManager


-- Pour tp les joueurs plus tard
GameManager.State = "Lobby"

--[[
    Initialisation de la game
]]
function GameManager:StartGame()
    if self.State ~= "Lobby" then 
        return warn("Start une game alors qu'elle n'est pas en lobby") 
    end

    self.State = "InGame"

    --Init les systèmes
    HungerSystem:Init(PlayerManager:GetAllRabbits())

    print(System)
    --Démarre les systèmes
    task.spawn(function()
        System:Start()
    end)

    --Pour chaque joueur on spawn le character
    for _, rabbit in PlayerManager:GetAllRabbits() do
        rabbit:Spawn()
    end

    --Créer le chasseur : 
    local HunterModel = workspace:WaitForChild("Adventurer")
    local Hunter = HunterClass.new(HunterModel)

    HunterBT.Start(Hunter) 

    print("Game Started")
    return true
end

return GameManager
