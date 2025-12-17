local RunService = game:GetService("RunService") 
local Players = game:GetService("Players") 

local player = Players.LocalPlayer 
local character = player.Character or player.CharacterAdded:Wait() 

-- Enleve le jump et le freefall
local humanoid = character:WaitForChild("Humanoid") 
local animator = humanoid:WaitForChild("Animator")
humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false) 
humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)

-- Animations 
local idleAnim = Instance.new("Animation") 
idleAnim.AnimationId = "rbxassetid://133994539287987" 
local jumpAnim = Instance.new("Animation") 
jumpAnim.AnimationId = "rbxassetid://72267736775767" 
local idleTrack = animator:LoadAnimation(idleAnim) 
local jumpTrack = animator:LoadAnimation(jumpAnim) 
idleTrack.Looped = false
jumpTrack.Looped = false

-- Remets le bon humanoid si le joueur spawn à nouveau 
player.CharacterAdded:Connect(function(char) 
    character = char humanoid = character:WaitForChild("Humanoid") 
    animator = humanoid:WaitForChild("Animator") 

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false) 
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false) 

    idleTrack = animator:LoadAnimation(idleAnim) 
    jumpTrack = animator:LoadAnimation(jumpAnim) 
    idleTrack.Looped = false
    jumpTrack.Looped = false
end)


--///////////////////////////////////////////////////////////////////////////////////
local JUMP_FORCE = 80                   -- Force horizontale du saut
local UP_FORCE = 40                     -- Force verticale du saut    
local state = "Idle"                    -- Etat actuel du lapin : "Idle" ou "Jumping"
local idleAnimeBuffer = 0               -- Timer pour l'animation idle  

-- Fonction qui check si le joueur est au sol
local function IsGrounded() 
    return humanoid.FloorMaterial ~= Enum.Material.Air 
end

-- Fonction qui fait sauter le lapin
local function Jump()
    if not IsGrounded() then return end
    if state == "Jumping" then return end
    state = "Jumping"

    local hrp = character.HumanoidRootPart
    local dir = hrp.CFrame.LookVector

    hrp.AssemblyLinearVelocity = Vector3.new(
        dir.X * JUMP_FORCE,
        UP_FORCE,
        dir.Z * JUMP_FORCE
    )

    if idleTrack.IsPlaying then
        idleTrack:Stop()
    end
    jumpTrack:Play()
end

-- Pour le jump : 
local UserInputService = game:GetService("UserInputService") 
local jumpRequested = false 
-- Si on appuie sur espace le jeu demande un saut
UserInputService.InputBegan:Connect(function(input, gp) 
    if gp then return end 
    if input.KeyCode == Enum.KeyCode.Space then 
        jumpRequested = true 
    end 
end) 

-- Boucle principale
RunService.RenderStepped:Connect(function(dt)
    if state == "Idle" then
        idleAnimeBuffer += dt
        -- Lance l'animation idle après 2 secondes d'inactivité avec 50 % de chance
        if idleAnimeBuffer >= 3 then
            idleAnimeBuffer = 0
            if not idleTrack.IsPlaying and math.random() < 0.5 then
                idleTrack:Play()
            end
        end
    end

    if IsGrounded() then
        if jumpRequested then
           Jump()
        end
        if not wasGrounded then -- On vient de toucher le sol 
            state = "Idle"
            local hrp = character.HumanoidRootPart 
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) 
            -- Applique une force nulle pour stopper le mouvement
        end 
    end
    wasGrounded = IsGrounded()
    jumpRequested = false
end)


