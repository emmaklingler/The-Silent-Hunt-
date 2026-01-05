local ReplicateStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CheckGameEvent = ReplicateStorage.Remote:WaitForChild("CheckGameEvent") 
local StartGameEvent = ReplicateStorage.Remote:WaitForChild("StartGameEvent")

local InitGame = require(ServerScriptService.Game.InitGame)


CheckGameEvent.OnServerEvent:Connect(function(player)
	CheckGameEvent:FireClient(player, InitGame.State)
end)

StartGameEvent.OnServerEvent:Connect(function(player)
	InitGame:StartGame()
	CheckGameEvent:FireAllClients(InitGame.State)
end)
