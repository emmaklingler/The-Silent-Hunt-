--Plus Tard
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)
local HungerSystem = require(game.ServerScriptService.Game.Systems.HungerSystem)

local GameManager = {}
GameManager.__index = GameManager

-- Pour tp les joueurs plus tard
GameManager.State = "Lobby"

--[[
    Initialisation de la game
]]
function GameManager:StartGame()
    if self.State ~= "Lobby" then return warn("Start une game alors qu'elle n'est pas en lobby") end
    self.State = "InGame"

    --Init les systèmes
    HungerSystem:Init(PlayerManager:GetAllRabbits())

    --Démarre les systèmes
    task.spawn(function()
        HungerSystem:Start()
    end)

    --Pour chaque joueur on spawn le character
    for _, rabbit in PlayerManager:GetAllRabbits() do
        rabbit:Spawn()
    end

    print("Game Started")
    return true
end

return GameManager
