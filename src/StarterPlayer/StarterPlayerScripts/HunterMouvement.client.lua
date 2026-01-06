
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeStateHunterEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateHunterEvent")

local model = nil

local idleAnim = Instance.new("Animation") 
idleAnim.AnimationId = "rbxassetid://140499235621994" 
local walkAnim = Instance.new("Animation") 
walkAnim.AnimationId = "rbxassetid://86588507256891" 
local attackAnim = Instance.new("Animation") 
attackAnim.AnimationId = "rbxassetid://94329896886564" 
local shootAnim = Instance.new("Animation") 
shootAnim.AnimationId = "rbxassetid://94329896886564" 


local idleTrack = nil
local walkTrack = nil
local attackTrack = nil
local shootTrack = nil


ChangeStateHunterEvent.OnClientEvent:Connect(function(hunterModel: Model, state: string)

    if hunterModel ~= model then
        model = hunterModel
        local humanoid = model:WaitForChild("Humanoid")
        local animator = humanoid:WaitForChild("Animator")  
        idleTrack = animator:LoadAnimation(idleAnim)
        walkTrack = animator:LoadAnimation(walkAnim)
        attackTrack = animator:LoadAnimation(attackAnim)
        shootTrack = animator:LoadAnimation(shootAnim)
        idleTrack.Looped = true
    end

    if state == "Idle" then
        idleTrack:Play()
    else
        idleTrack:Stop()
    end

    if state == "Walk" then
        walkTrack:Play()
    else
        walkTrack:Stop()
    end

    if state == "AttackPied" then
        attackTrack:Play()
    else
        attackTrack:Stop()
    end

    if state == "AttackArme" then
        shootTrack:Play()
    else
        shootTrack:Stop()
    end
end)