local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local HungerEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("HungerChangeEvent")
local PlayerGui = Player.PlayerGui


HungerEvent.OnClientEvent:Connect(function(hunger)
	local BarreDeFaim = PlayerGui:WaitForChild("HUD").SG_HUD.Faim.Bar.Frame
	BarreDeFaim.Size = UDim2.new(hunger/100, 0, 1, 0)
end)
