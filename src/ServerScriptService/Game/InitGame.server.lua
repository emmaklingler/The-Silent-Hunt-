local Players = game:GetService("Players")

--Plus Tard
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)
local HungerSystem = require(game.ServerScriptService.Game.Systems.HungerSystem)

local GameManager = {}
GameManager.__index = GameManager

-- Pour tp les joueurs plus tard
GameManager.State = "Lobby"

function GameManager:StartGame()
    if self.State ~= "Lobby" then return warn("Start une game alors qu'elle n'est pas en lobby") end
    self.State = "InGame"
    --Init les systèmes
    HungerSystem:Init(PlayerManager:GetAllRabbits())
    --Démarre les systèmes
    HungerSystem:Start()

    --Pour chaque joueur on spawn le character
    for _, player in pairs(Players:GetPlayers()) do
        local rabbit = PlayerManager:GetRabbit(player)
        rabbit:Spawn()    
    end

    print("Game Started")
end

return GameManager
