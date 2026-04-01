local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local rabbitAnimsData = {
    Idle = "rbxassetid://133994539287987",
    Running = "rbxassetid://138414084300181",
    Jumping = "rbxassetid://72267736775767",
    Dead = "rbxassetid://108026447487101",
}

local animObjects = {}
for name, id in pairs(rabbitAnimsData) do
    local a = Instance.new("Animation")
    a.AnimationId = id
    animObjects[name] = a
end

local Remote = ReplicatedStorage:WaitForChild("Remote")
local ChangeStateRabbitEvent = Remote:WaitForChild("ChangeStateRabbitEvent")
local botTracks = {}

ChangeStateRabbitEvent.OnClientEvent:Connect(function(botModel, state)
    print(botModel, state)
    if not botModel or not botModel.Parent or botModel == Players.LocalPlayer.Character then return end
    
    local humanoid = botModel:FindFirstChild("Humanoid")
    if not humanoid then return end

    if not botTracks[botModel] then
        local animator = humanoid:WaitForChild("Animator")
        botTracks[botModel] = { tracks = {}, currentState = "" }
        for name, animObj in pairs(animObjects) do
            local track = animator:LoadAnimation(animObj)
            if name == "Running" or name == "Idle" then track.Looped = true end
            botTracks[botModel].tracks[name] = track
        end
    end

    local data = botTracks[botModel]
    if state == "Run" or state == "walk" then state = "Running" end
    if data.currentState == state then return end

    -- Stop les anciennes pistes
    for _, track in pairs(data.tracks) do 
        if track.IsPlaying then track:Stop(0.2) end 
    end
    
    -- Joue la nouvelle
    local nextTrack = data.tracks[state]
    if nextTrack then
        nextTrack:Play(0.2)
        data.currentState = state
    end
end)

