local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local ChangeStateHunterEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateHunterEvent")

local model = nil
local tracks = {}
local currentState = nil

-- Table propre des animations
local animationsData = {
	Idle = "rbxassetid://105394594977781",
	Walk = "rbxassetid://96270962614028",
	Run = "rbxassetid://97087449242424",
	AttackPied = "rbxassetid://118974947207883",
	Shoot = "rbxassetid://130777871148436",
	Reload = "rbxassetid://78142182855689",
	Aim = "rbxassetid://89488560177926",
	LookAround = "rbxassetid://128912682844966",
	PlaceTrap = "rbxassetid://135010872973319",
}

local animations = {}

-- Création des objets Animation
for state, id in animationsData do
	local anim = Instance.new("Animation")
	anim.AnimationId = id
	animations[state] = anim
end

-- Preload des animations
ContentProvider:PreloadAsync(
	(function()
		local list = {}
		for _, anim in animations do
			table.insert(list, anim)
		end
		return list
	end)()
)

local function stopAllAnimations()
	for _, track in tracks do
		if track.IsPlaying then
			track:Stop()
		end
	end
end

ChangeStateHunterEvent.OnClientEvent:Connect(function(hunterModel: Model, state: string)

	-- Si on change de modèle, on recharge les tracks
	if hunterModel ~= model then
		model = hunterModel
		tracks = {}

		local humanoid = model:WaitForChild("Humanoid")
		local animator = humanoid:WaitForChild("Animator")

		-- Charger toutes les animations d'un coup
		for animState, anim in pairs(animations) do
			tracks[animState] = animator:LoadAnimation(anim)
		end
	end

	-- Si l'état est identique, on ne fait rien
	if currentState == state then
		return
	end

	currentState = state

	stopAllAnimations()

	local track = tracks[state]
	if track then
		track:Play()
	else
		warn("Animation state inconnu :", state)
	end
end)