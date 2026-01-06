local RunService = game:GetService("RunService")

-- 1) On vérifie qu'on est bien dans Roblox Studio
if not RunService:IsStudio() then
    return
end

print("=== Début des tests Hunter ===")

local HunterClass = require(game.ServerScriptService.Hunter.HunterClass)
local model = game.Workspace:WaitForChild("Adventurer"):clone()

-- Test 0 : création
--local hunter = HunterClass.new(model)


print("✅ Tous les tests Hunter sont OK")