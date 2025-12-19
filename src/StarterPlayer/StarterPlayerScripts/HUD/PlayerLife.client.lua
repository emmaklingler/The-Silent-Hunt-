local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local LifeEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("LifeChangeEvent")
local PlayerGui = Player.PlayerGui

--[[
	Met a jour la barre de vie en fonction du serveur
]]
LifeEvent.OnClientEvent:Connect(function(health)
	local BarreDeVie = PlayerGui:WaitForChild("HUD").SG_HUD.Vie.Bar.Frame
	BarreDeVie.Size = UDim2.new(health/100, 0, 1, 0)
end)
