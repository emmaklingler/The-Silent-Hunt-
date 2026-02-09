local System = {}

local RunService = game:GetService("RunService")
local CarrotSystem = require(script.Parent.CarrotSystem)
local HungerSystem = require(script.Parent.HungerSystem)
local TimerSystem = require(script.Parent.TimerSystem)

local connection = nil
--[[
    Run avec une seule boucle tous les services
]]
function System:Start()
    connection = RunService.Heartbeat:Connect(function(dt)
        HungerSystem:Tick(dt)
        TimerSystem:Tick(dt)
        CarrotSystem:Tick(dt)
    end)
end
function System:Stop()
    if connection then
        connection:Disconnect()
    end
end



return System
