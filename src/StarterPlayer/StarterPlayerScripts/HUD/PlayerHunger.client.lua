local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local HungerEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("HungerChangeEvent")
local LifeEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("LifeChangeEvent")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local satiety = 0
local start = false
local isAlive = true

--[[
	Met a jour la barre de faim en fonction de la satiety
]]
local function UpdateBar()
	local BarreDeFaim = PlayerGui:WaitForChild("HUD").SG_HUD.Faim.Bar.Frame
	BarreDeFaim.Size = UDim2.new(satiety/100, 0, 1, 0)
end

local rate = 1 -- taux de faim par seconde
local last = os.clock()
--[[
	Début de la boucle de diminution de la faim
]]
local function Start()
    RunService.Heartbeat:Connect(function(dt)
		if not start or not isAlive then
			return
		end
		local now = os.clock()
		local newdt = now - last
		last = now

		local satietyToRemove = rate * newdt
		
		if satiety > 0 then
			satiety -= satietyToRemove
		end
		UpdateBar()
    end)
end

--[[
	Événement déclenché lorsque la valeur de la faim change côté serveur
]]
HungerEvent.OnClientEvent:Connect(function(satietyValue)
	satiety = satietyValue
	UpdateBar()
	if not start then
		-- Si pas encore démarré, lance la boucle de diminution de la faim
		start = true
		task.spawn(Start)
	end
end)

LifeEvent.OnClientEvent:Connect(function(newLife)
	if newLife <= 0 then
		isAlive = false
		start = false
	end
end)
