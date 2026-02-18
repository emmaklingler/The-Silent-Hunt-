local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TimeChangeEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("TimeChangeEvent")
local StartGameEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("StartGameEvent")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local label = nil

local timer = 0
local start = false
local last = nil

StartGameEvent.OnClientEvent:Connect(function()
	label = PlayerGui:WaitForChild("HUD").Text.Timer
end)

--[[
	Affiche le timer
]]
local function Update()
	if not label then return end
	label.Text = math.round(timer)
end

--[[
	Début de la boucle de diminution de la faim
]]
local function Start()
    RunService.Heartbeat:Connect(function(dt)
		if not start then
			return
		end
		local now = os.clock()
		local newdt = now - last
		last = now
    	timer = timer + newdt
		Update()
    end)
end

--[[
	Événement déclenché lorsque la valeur de temps change côté serveur
]]
TimeChangeEvent.OnClientEvent:Connect(function(newTime)
	last = os.clock()
	timer = newTime
	if not start then
		-- Si pas encore démarré, lance la boucle de diminution de la timer
		start = true
		task.spawn(Start)
	end
	Update()
end)
