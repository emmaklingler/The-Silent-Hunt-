local RunService = game:GetService("RunService")

-- 1) On vérifie qu'on est bien dans Roblox Studio
if not RunService:IsStudio() then
    return
end

print("=== Début des tests Rabbit ===")

local RabbitClass = require(game.ServerScriptService.Player.RabbitClass)

-- Test 0 : création
local rabbit = RabbitClass.new(nil, nil)

-- Test 1 : RemoveSatiety
rabbit:RemoveSatiety(50)
assert(rabbit.Satiety == 50, "❌ La satiety devrait être 50")
rabbit:RemoveSatiety(20)
assert(rabbit.Satiety == 30, "❌ La satiety devrait être 30")
rabbit:RemoveSatiety(30)
assert(rabbit.Satiety == 0, "❌ La satiety devrait être 0")

--Test 2 : AddSatiety
rabbit:AddSatiety(50)
assert(rabbit.Satiety == 50, "❌ La satiety devrait être 50")
rabbit:AddSatiety(80)
assert(rabbit.Satiety == 100, "❌ La satiety devrait être 100")



print("✅ Tous les tests Lapin sont OK")