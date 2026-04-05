local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local StartGameEvent = ReplicatedStorage.Remote:WaitForChild("StartGameEvent")
local EndGameEvent = ReplicatedStorage.Remote:WaitForChild("EndGameEvent")

local EndScreen

-- 🔄 Re-fetch GUI après respawn / start
local function RefreshGUI()
	local playerGui = player:WaitForChild("PlayerGui")
	EndScreen = playerGui:WaitForChild("EndScreen")
end

StartGameEvent.OnClientEvent:Connect(function()
	RefreshGUI()
end)

player.CharacterAdded:Connect(function()
	task.wait(0.2) -- laisse le temps au GUI de charger
	RefreshGUI()
end)

local function PlayEndScreen(result)
	if not EndScreen then return end

	local frame = EndScreen:FindFirstChild(result)
	if not frame then
		warn("Frame not found:", result)
		return
	end

	frame.Visible = true

	for i, obj in frame:GetChildren() do
		
        if obj:IsA("ImageLabel") then
            obj.ImageTransparency = 1
            TweenService:Create(obj, TweenInfo.new(1.5), {
                ImageTransparency = 0
            }):Play()
        elseif obj:IsA("TextLabel") then
            obj.TextTransparency = 1
            TweenService:Create(obj, TweenInfo.new(1.5), {
                TextTransparency = 0
            }):Play()
        end
        
    end
end

EndGameEvent.OnClientEvent:Connect(function(result)
	PlayEndScreen(result)
end)