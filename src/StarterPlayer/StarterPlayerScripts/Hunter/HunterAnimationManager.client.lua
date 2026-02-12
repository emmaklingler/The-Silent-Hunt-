
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeStateHunterEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeStateHunterEvent")

local model = nil

local idleAnim = Instance.new("Animation")                  -- 0.8s
idleAnim.AnimationId = "rbxassetid://105394594977781"   

local attackFootAnim = Instance.new("Animation")            -- 0.5s
attackFootAnim.AnimationId = "rbxassetid://118974947207883"     

local walkAnim = Instance.new("Animation")                  -- 0.8s
walkAnim.AnimationId = "rbxassetid://96270962614028" 

local runAnim = Instance.new("Animation")                   -- 0.8s
runAnim.AnimationId = "rbxassetid://97087449242424" 

local shootAnim = Instance.new("Animation")                 -- 0.5s
shootAnim.AnimationId = "rbxassetid://130777871148436" 

local reloadAnim = Instance.new("Animation")                -- 2s
reloadAnim.AnimationId = "rbxassetid://78142182855689" 

local aimAnim = Instance.new("Animation")                   -- 0s
aimAnim.AnimationId = "rbxassetid://89488560177926" 

local lookAroundAnim = Instance.new("Animation")            -- 3s
lookAroundAnim.AnimationId = "rbxassetid://128912682844966" 



local idleTrack = nil
local walkTrack = nil
local attackFootTrack = nil
local shootTrack = nil
local reloadTrack = nil
local aimTrack = nil
local lookAroundTrack = nil


ChangeStateHunterEvent.OnClientEvent:Connect(function(hunterModel: Model, state: string)

    if hunterModel ~= model then
        model = hunterModel
        local humanoid = model:WaitForChild("Humanoid")
        local animator = humanoid:WaitForChild("Animator")  

        idleTrack = animator:LoadAnimation(idleAnim)
        walkTrack = animator:LoadAnimation(walkAnim)
        attackFootTrack = animator:LoadAnimation(attackFootAnim)
        shootTrack = animator:LoadAnimation(shootAnim)
        reloadTrack = animator:LoadAnimation(reloadAnim)
        aimTrack = animator:LoadAnimation(aimAnim)
        lookAroundTrack = animator:LoadAnimation(lookAroundAnim)

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
        attackFootTrack:Play()
    else
        attackFootTrack:Stop()
    end

    if state == "Shoot" then
        shootTrack:Play()
    else
        shootTrack:Stop()
    end

    if state == "Reload" then
        reloadTrack:Play()
    else
        reloadTrack:Stop()
    end

    if state == "Aim" then
        aimTrack:Play()
    else
        aimTrack:Stop()
    end

    if state == "LookAround" then
        lookAroundTrack:Play()
    else
        lookAroundTrack:Stop()
    end
end)