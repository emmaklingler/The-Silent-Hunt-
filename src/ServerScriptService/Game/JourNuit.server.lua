local light = game:GetService("Lighting")

local speed = 0.2

local start = 17

local minute = start*60

while true do
    minute+=1
    light:SetMinutesAfterMidnight(minute)
    task.wait(speed)
end