-- local RunService = game:GetService("RunService")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local ServerStorage = game:GetService("ServerStorage")
-- local Workspace = game:GetService("Workspace")

-- -- 1) Studio only
-- if not RunService:IsStudio() then
-- 	return
-- end

-- print("=== Début des tests Hunter ===")

-- -- =========================================================
-- -- Helpers setup (assets + remote)
-- -- =========================================================

-- local function ensureFolder(parent, name)
-- 	local f = parent:FindFirstChild(name)
-- 	if not f then
-- 		f = Instance.new("Folder")
-- 		f.Name = name
-- 		f.Parent = parent
-- 	end
-- 	return f
-- end

-- -- Remote: ReplicatedStorage/Remote/ChangeStateHunterEvent
-- local remoteFolder = ensureFolder(ReplicatedStorage, "Remote")
-- local changeStateEvent = remoteFolder:FindFirstChild("ChangeStateHunterEvent")
-- if not changeStateEvent then
-- 	changeStateEvent = Instance.new("RemoteEvent")
-- 	changeStateEvent.Name = "ChangeStateHunterEvent"
-- 	changeStateEvent.Parent = remoteFolder
-- end

-- -- Trap template: ServerStorage/Asset/Trap (Part ou Model)
-- local assetFolder = ensureFolder(ServerStorage, "Asset")
-- local trapTemplate = assetFolder:FindFirstChild("Trap")
-- if not trapTemplate then
-- 	trapTemplate = Instance.new("Part")
-- 	trapTemplate.Name = "Trap"
-- 	trapTemplate.Size = Vector3.new(2, 1, 2)
-- 	trapTemplate.Anchored = true
-- 	trapTemplate.CanCollide = true
-- 	trapTemplate.Parent = assetFolder
-- end

-- -- RefillPoint (si besoin)
-- if not Workspace:FindFirstChild("RefillPoint") then
-- 	local rp = Instance.new("Part")
-- 	rp.Name = "RefillPoint"
-- 	rp.Size = Vector3.new(6, 1, 6)
-- 	rp.Anchored = true
-- 	rp.Position = Vector3.new(0, 1, 0)
-- 	rp.Parent = Workspace
-- end

-- -- =========================================================
-- -- Create a minimal Hunter model
-- -- =========================================================
-- local function createHunterModel()
-- 	local model = Instance.new("Model")
-- 	model.Name = "HunterTestModel"

-- 	local hrp = Instance.new("Part")
-- 	hrp.Name = "HumanoidRootPart"
-- 	hrp.Size = Vector3.new(2, 2, 1)
-- 	hrp.Anchored = false
-- 	hrp.Position = Vector3.new(0, 5, 0)
-- 	hrp.Parent = model

-- 	local humanoid = Instance.new("Humanoid")
-- 	humanoid.Name = "Humanoid"
-- 	humanoid.Parent = model

-- 	model.Parent = Workspace
-- 	return model
-- end

-- -- =========================================================
-- -- Stub Rabbit target for attacks
-- -- =========================================================
-- local function createRabbitStub(pos)
-- 	local rabbitModel = Instance.new("Model")
-- 	rabbitModel.Name = "RabbitStub"

-- 	local root = Instance.new("Part")
-- 	root.Name = "HumanoidRootPart"
-- 	root.Size = Vector3.new(2, 2, 1)
-- 	root.Anchored = true
-- 	root.Position = pos
-- 	root.Parent = rabbitModel

-- 	local hum = Instance.new("Humanoid")
-- 	hum.Name = "Humanoid"
-- 	hum.MaxHealth = 100
-- 	hum.Health = 100
-- 	hum.Parent = rabbitModel

-- 	rabbitModel.Parent = Workspace

-- 	local rabbit = {
-- 		Model = rabbitModel,
-- 		Root = root,
-- 		RemoveHealth = function(self, dmg)
-- 			hum:TakeDamage(dmg)
-- 		end
-- 	}

-- 	return rabbit, hum
-- end

-- -- =========================================================
-- -- Require HunterClass
-- -- =========================================================
-- local HunterClass = require(game.ServerScriptService.Hunter.HunterClass)

-- -- =========================================================
-- -- TESTS
-- -- =========================================================

-- -- Test 0 : création
-- local hunterModel = createHunterModel()
-- local hunter = HunterClass.new(hunterModel)

-- assert(hunter.Model == hunterModel, "❌ Hunter.Model incorrect")
-- assert(hunter.Humanoid ~= nil, "❌ Hunter.Humanoid nil")
-- assert(hunter.Root ~= nil, "❌ Hunter.Root nil")

-- -- Test 1 : NeedsReload / CanReload
-- hunter.ammoInMag = 0
-- hunter.ammoReserve = 2
-- assert(hunter:NeedsReload() == true, "❌ NeedsReload devrait être true (ammoInMag=0)")
-- assert(hunter:CanReload() == true, "❌ CanReload devrait être true (reserve>0 et mag pas full)")

-- hunter.ammoInMag = 2
-- hunter.ammoReserve = 2
-- assert(hunter:NeedsReload() == false, "❌ NeedsReload devrait être false (mag plein)")
-- assert(hunter:CanReload() == false, "❌ CanReload devrait être false (mag déjà plein)")

-- hunter.ammoInMag = 0
-- hunter.ammoReserve = 0
-- assert(hunter:CanReload() == false, "❌ CanReload devrait être false (reserve=0)")

-- -- Test 2 : TryReloadWeapon (impossible)
-- hunter.isReloading = false
-- hunter.reloadEndTime = 0
-- hunter.ammoInMag = 0
-- hunter.ammoReserve = 0
-- local st = hunter:TryReloadWeapon()
-- assert(st ~= nil, "❌ TryReloadWeapon doit retourner un Status")
-- -- normalement FAILURE


-- -- Test 3 : TryReloadWeapon (start -> running -> success)
-- hunter.ammoInMag = 0
-- hunter.ammoReserve = 2
-- hunter.isReloading = false

-- local stStart = hunter:TryReloadWeapon()
-- assert(stStart ~= nil, "❌ Start reload: status nil")
-- assert(hunter.isReloading == true, "❌ Reload devrait être en cours (isReloading=true)")

-- -- on force la fin du timer
-- hunter.reloadEndTime = os.clock() - 0.01
-- local stEnd = hunter:TryReloadWeapon()
-- assert(stEnd ~= nil, "❌ End reload: status nil")
-- assert(hunter.ammoInMag > 0, "❌ Après reload, ammoInMag devrait être > 0")
-- assert(hunter.ammoReserve >= 0, "❌ Après reload, ammoReserve >= 0")

-- -- Test 4 : RefillMunitions
-- hunter.ammoInMag = 0
-- hunter.ammoReserve = 0
-- local ok = hunter:RefillMunitions()
-- assert(ok == true, "❌ RefillMunitions doit retourner true")
-- assert(hunter.ammoReserve <= hunter.maxAmmoReserve, "❌ ammoReserve dépasse maxAmmoReserve")
-- assert(hunter.ammoInMag > 0, "❌ Refill devrait recharger le chargeur")

-- -- Test 5 : TryPlaceTrap (spawn + cooldown)
-- -- place 1
-- local beforeCount = #(Workspace:GetChildren())
-- local placed1 = hunter:TryPlaceTrap()
-- assert(placed1 == true, "❌ TryPlaceTrap devrait poser un piège (true)")

-- -- place 2 immédiatement => cooldown => false
-- local placed2 = hunter:TryPlaceTrap()
-- assert(placed2 == false, "❌ TryPlaceTrap devrait refuser (cooldown)")

-- -- force cooldown fini
-- hunter._nextTrapTime = os.clock() - 0.01
-- local placed3 = hunter:TryPlaceTrap()
-- assert(placed3 == true, "❌ TryPlaceTrap devrait reposer après cooldown")

-- print("✅ Tous les tests Hunter sont OK")
