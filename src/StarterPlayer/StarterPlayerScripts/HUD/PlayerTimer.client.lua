local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TimeChangeEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("TimeChangeEvent")
local StartGameEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("StartGameEvent")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local bar = nil

local timer = 0
local maxTimer = 0 
local start = false
local last = nil

StartGameEvent.OnClientEvent:Connect(function()
	bar = PlayerGui:WaitForChild("HUD").Time.Frame.Bar
end)

--[[
	Affiche le timer
]]
local function Update()
	if not bar then return end
	local progress = math.clamp(timer / maxTimer, 0, 1)
	bar.Bar.Size = UDim2.new(progress, 0, 1, 0)
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
TimeChangeEvent.OnClientEvent:Connect(function(newTime, newMaxTime)
	last = os.clock()
	timer = newTime
	maxTimer = newMaxTime
	if not start then
		-- Si pas encore démarré, lance la boucle de diminution de la timer
		start = true
		task.spawn(Start)
	end
	Update()
end)
