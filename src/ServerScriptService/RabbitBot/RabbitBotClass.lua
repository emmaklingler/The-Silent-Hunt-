local RabbitBot = {}
RabbitBot.__index = RabbitBot

local PathfindingService = game:GetService("PathfindingService")
local Status = require(game.ServerScriptService.BehaviourTree.Node.Utiles.Status)

function RabbitBot.new(model)
    local self = setmetatable({}, RabbitBot)

    -- =============================
    -- Références modèle
    -- =============================
    self.Model = model
    self.Humanoid = model:WaitForChild("Humanoid")
    self.Root = model:WaitForChild("HumanoidRootPart")

    -- =============================
    -- Stats vitales
    -- =============================
    self.MaxHealth = 100
    self.Health = self.MaxHealth
    self.Satiety = 100
    self.Stress = 0

    -- =============================
    -- Paramètres IA
    -- =============================
    self.panicRadius = 60
    self.fleeDistance = 80
    self.fleeSpeed = 28
    self.normalSpeed = 16
    self.fleeDuration = 3

    -- =============================
    -- États internes
    -- =============================
    self.state = "Idle"
    self.fleeState = nil
    self.pathState = nil

    self.poidStat = {
        survie = 1,
        faim = 1,
        fatigue = 0,
    }

    self.jumpCooldown = 0
    self.jumpForce = 80
    self.upForce = 40



    return self
end

function RabbitBot:TryFlee(hunterPosition)

	if not self.Root or not hunterPosition then
		return Status.FAILURE
	end

	-- ======================
	-- Fuite déjà en cours
	-- ======================
	if self.fleeState then

		-- saut aléatoire pendant la fuite
		if math.random() < 0.08 then
			self:Jump()
		end

		if os.clock() >= self.fleeState.endTime then
			self.fleeState = nil
			self.Humanoid.WalkSpeed = self.normalSpeed
			self:ChangeState("Idle")
			return Status.SUCCESS
		end

		return Status.RUNNING
	end

	-- ======================
	-- Début fuite
	-- ======================
	local direction = (self.Root.Position - hunterPosition)

	if direction.Magnitude == 0 then
		return Status.FAILURE
	end

	direction = direction.Unit

	local fleeTarget = self.Root.Position + direction * self.fleeDistance

	self.fleeState = {
		endTime = os.clock() + self.fleeDuration
	}

	self.Humanoid.WalkSpeed = self.fleeSpeed
	self.Humanoid:MoveTo(fleeTarget)
	self:ChangeState("Flee")

	-- premier saut panique
	self:Jump()

	return Status.RUNNING
end


function RabbitBot:ChangeState(state)
    if self.state ~= state then
        print("[Rabbit] State:", self.state, "->", state)
        self.state = state
    end
end


function RabbitBot:IsGrounded()
	return self.Humanoid.FloorMaterial ~= Enum.Material.Air
end

function RabbitBot:Jump()
	if not self:IsGrounded() then return end
	if self.jumpCooldown > os.clock() then return end

	local hrp = self.Root
	local dir = hrp.CFrame.LookVector

	hrp:ApplyImpulse(Vector3.new(
		dir.X * self.jumpForce * hrp.AssemblyMass,
		self.upForce * hrp.AssemblyMass,
		dir.Z * self.jumpForce * hrp.AssemblyMass
	))

	self.jumpCooldown = os.clock() + 1
end

function RabbitBot:CanSeeHunter(hunterRoot)
	if not hunterRoot or not self.Root then
		print("❌ [RabbitVision] Missing hunterRoot or self.Root")
		return false
	end

	local direction = (hunterRoot.Position - self.Root.Position)
	local distance = direction.Magnitude

	-- =========================
	-- DISTANCE CHECK
	-- =========================
	if distance > self.panicRadius then
		print("📏 [RabbitVision] Too far:", math.floor(distance))
		return false
	end

	direction = direction.Unit

	-- =========================
	-- FOV CHECK
	-- =========================
	local forward = self.Root.CFrame.LookVector
	local dot = forward:Dot(direction)

	if dot < 0.5 then
		print("👁️ [RabbitVision] Outside FOV | dot:", string.format("%.2f", dot))
		return false
	end

	-- =========================
	-- RAYCAST CHECK
	-- =========================
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { self.Model }

	local result = workspace:Raycast(
		self.Root.Position,
		direction * distance,
		params
	)

	if result then
		local hitModel = result.Instance:FindFirstAncestorOfClass("Model")

		if hitModel ~= hunterRoot.Parent then
			print("🧱 [RabbitVision] Blocked by:", result.Instance.Name)
			return false
		else
			print("🎯 [RabbitVision] Raycast HIT hunter ✔")
		end
	else
		print("⚠️ [RabbitVision] No raycast hit (edge case)")
	end

	-- =========================
	-- SUCCESS
	-- =========================
	print("✅ [RabbitVision] Hunter visible")
	return true
end

return RabbitBot