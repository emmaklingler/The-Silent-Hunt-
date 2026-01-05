local player = game:GetService("Players").LocalPlayer

local ReplicateStorage = game:GetService("ReplicatedStorage")
local CheckGameEvent = ReplicateStorage.Remote:WaitForChild("CheckGameEvent") 
local StartGameEvent = ReplicateStorage.Remote:WaitForChild("StartGameEvent")

local Menu = player.PlayerGui:WaitForChild("Menu")
local GUI = Menu.StartGui
local Button = GUI.Frame.TextButton
local NumberPlayerLabel = GUI.Frame.Number
local TimeLabel = GUI.Frame.Time

NumberPlayerLabel.Text = "..."
TimeLabel.Text = "..."

GUI.Enabled = true

CheckGameEvent:FireServer()
CheckGameEvent.OnClientEvent:Connect(function(State)
	TimeLabel.Text = State
end)

Button.MouseButton1Click:Connect(function()
	StartGameEvent:FireServer()
end)