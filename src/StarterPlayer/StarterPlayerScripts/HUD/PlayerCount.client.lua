local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDeadClientEvent = ReplicatedStorage.Remote:WaitForChild("PlayerDeadClientEvent")
local StartGameEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("StartGameEvent")

local player = game.Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui"):WaitForChild("HUD").Time.Joueur


StartGameEvent.OnClientEvent:Connect(function(data)
	GUI = player.PlayerGui:WaitForChild("HUD").Time.Joueur
    local count = data.nbPlayers
    GUI.Text = "Joueurs restants : " .. count
end)

PlayerDeadClientEvent.OnClientEvent:Connect(function(count)  
    GUI.Text = "Joueurs restants : " .. count
end)