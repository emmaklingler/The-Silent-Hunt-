local System = {}

local RunService = game:GetService("RunService")
local CarrotSystem = require(script.Parent.CarrotSystem)
local HungerSystem = require(script.Parent.HungerSystem)

--[[
    Run avec une seule boucle tous les services
]]
function System:Start()
    RunService.Heartbeat:Connect(function(dt)
        HungerSystem:Tick(dt)
        CarrotSystem:Tick(dt)
    end)
end



return System
