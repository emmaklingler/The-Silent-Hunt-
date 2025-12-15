local Players = game:GetService("Players")

--Plus Tard
local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)

local GameManager = {}
GameManager.__index = GameManager

GameManager.State = "Lobby" -- Lobby | InGame | End

function GameManager:StartGame(player:Player)
    if self.State ~= "Lobby" then return end
    self.State = "InGame"
    print("Game Started by "..player)
end

return GameManager
