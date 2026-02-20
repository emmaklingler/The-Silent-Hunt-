local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local VFXManager = require(script.Parent.Parent:WaitForChild("VFX"):WaitForChild("VFXManager"))

local Player = Players.LocalPlayer
local LifeEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("LifeChangeEvent")
local StartGameEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("StartGameEvent")
local PlayerGui = Player.PlayerGui

local healthSave = 100

local BarreDeVie = nil
local AnimationDegat = nil

--[[
	Met a jour la barre de vie en fonction du serveur
]]
local function UpdateVie(health)
	if not BarreDeVie or not AnimationDegat then return end
	BarreDeVie.Size = UDim2.new(health/100, 0, 1, 0)
	if health < healthSave and healthSave-health > 20 then
		-- jouer l'animation de degat
		AnimationDegat.ImageTransparency = 0.6
		local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TS:Create(AnimationDegat, tweenInfo, {ImageTransparency = 1})
		tween:Play()
		VFXManager:EmitParticle(Player.Character.HumanoidRootPart.Position, "Blood", 3)
	end
	healthSave = health
end

StartGameEvent.OnClientEvent:Connect(function()
	BarreDeVie = PlayerGui:WaitForChild("HUD").SG_HUD.Vie.Bar.Frame
	AnimationDegat = PlayerGui:WaitForChild("HUD").Damage.ImageLabel
	UpdateVie(healthSave)
end)

LifeEvent.OnClientEvent:Connect(function(health)
	UpdateVie(health)
end)
