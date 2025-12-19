local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HungerEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("HungerChangeEvent")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local faim = 0
local start = false

local function UpdateBar()
	local BarreDeFaim = PlayerGui:WaitForChild("HUD").SG_HUD.Faim.Bar.Frame
	BarreDeFaim.Size = UDim2.new(faim/100, 0, 1, 0)
end

local function Start()
    while true do
        task.wait(1)
		if faim > 0 then
			faim-=1
		end
		UpdateBar()
    end
end


HungerEvent.OnClientEvent:Connect(function(hunger)
	faim = hunger
	if not start then
		start = true
		task.spawn(Start)
	end
end)
