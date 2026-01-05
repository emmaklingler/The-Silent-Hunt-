local HunterClass = require(script.Parent.Parent.HunterClass)
local HunterBT = require(script.Parent.HunterBT)

local HunterModel = workspace:WaitForChild("Adventurer")
local Hunter = HunterClass.new(HunterModel)

HunterBT.Start(Hunter) 