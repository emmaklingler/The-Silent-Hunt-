local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HungerEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("HungerChangeEvent")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local satiety = 0
local start = false

--[[
	Met a jour la barre de faim en fonction de la satiety
]]
local function UpdateBar()
	local BarreDeFaim = PlayerGui:WaitForChild("HUD").SG_HUD.Faim.Bar.Frame
	BarreDeFaim.Size = UDim2.new(satiety/100, 0, 1, 0)
end

--[[
	Début de la boucle de diminution de la faim
]]
local function Start()
    while true do
        task.wait(1)
		if satiety > 0 then
			satiety-=1
		end
		UpdateBar()
    end
end

--[[
	Événement déclenché lorsque la valeur de la faim change côté serveur
]]
HungerEvent.OnClientEvent:Connect(function(satietyValue)
	satiety = satietyValue
	if not start then
		-- Si pas encore démarré, lance la boucle de diminution de la faim
		start = true
		task.spawn(Start)
	end
end)
