local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXEvent = ReplicatedStorage:WaitForChild("Remote").VFXEvent

local VFXManager = require(script.Parent:WaitForChild("VFXManager"))

VFXEvent.OnClientEvent:Connect(function(data)
    if data.type == "Shoot" then
        VFXManager:PlayBeam(data.origin, data.hitPosition, 0.15, "Tire")
        VFXManager:EmitParticle(data.origin, "Fire", 1)
        VFXManager:PlayParticle(data.origin, "Smoke", 0.5)
    end
end)
