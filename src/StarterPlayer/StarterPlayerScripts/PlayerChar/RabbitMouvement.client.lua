local RunService = game:GetService("RunService") 
local Players = game:GetService("Players") 

local player = Players.LocalPlayer 
local character = player.Character or player.CharacterAdded:Wait() 

--///////////////////////////////////////////////////////////////////////////////////
-- Init l'humanoid et l'animator

-- Enleve le jump et le freefall
local humanoid = character:WaitForChild("Humanoid") 
local animator = humanoid:WaitForChild("Animator")
humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false) 

-- Animations 138414084300181
local idleAnim = Instance.new("Animation") 
idleAnim.AnimationId = "rbxassetid://133994539287987" 
local jumpAnim = Instance.new("Animation") 
jumpAnim.AnimationId = "rbxassetid://72267736775767" 
local runAnim = Instance.new("Animation") 
runAnim.AnimationId = "rbxassetid://138414084300181" 
local idleTrack = animator:LoadAnimation(idleAnim) 
local jumpTrack = animator:LoadAnimation(jumpAnim) 
local runTrack = animator:LoadAnimation(runAnim)
idleTrack.Looped = false
jumpTrack.Looped = false
runTrack.Looped = true


-- Remets le bon humanoid si le joueur spawn à nouveau 
player.CharacterAdded:Connect(function(char) 
    character = char humanoid = character:WaitForChild("Humanoid") 
    animator = humanoid:WaitForChild("Animator") 

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false) 

    idleTrack = animator:LoadAnimation(idleAnim) 
    jumpTrack = animator:LoadAnimation(jumpAnim) 
    runTrack = animator:LoadAnimation(runAnim)
    idleTrack.Looped = false
    jumpTrack.Looped = false
    runTrack.Looped = true
end)


--///////////////////////////////////////////////////////////////////////////////////
local JUMP_FORCE = 80                   -- Force horizontale du saut
local UP_FORCE = 40                     -- Force verticale du saut    
local jumpCooldown = 0
local state = "Idle"                    -- Etat actuel du lapin : "Idle" ou "Jumping"
local idleAnimeBuffer = 0               -- Timer pour l'animation idle  
local wasGrounded = true                -- Si le lapin était au sol à la frame précédente


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

    hrp:ApplyImpulse(Vector3.new(
        dir.X * JUMP_FORCE * hrp.AssemblyMass,
        UP_FORCE * hrp.AssemblyMass,
        dir.Z * JUMP_FORCE * hrp.AssemblyMass
    ))
   

    if idleTrack.IsPlaying then
        idleTrack:Stop()
    end
    jumpTrack:Play()
    --Pour être sûr
    task.delay(5, function()
        state = "Idle"
    end)
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
    jumpCooldown -= dt
     -- Gestion des états
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


    if IsGrounded() and wasGrounded and jumpRequested and jumpCooldown <= 0 then    
        Jump() 
    end
    if IsGrounded() and state ~= "Jumping" then
        if humanoid.MoveDirection.Magnitude > 0 and state ~= "Running" then
            
            state = "Running"
            idleTrack:Stop()
            runTrack:Play()
        elseif humanoid.MoveDirection.Magnitude == 0 then
          
            state = "Idle"
            runTrack:Stop()
        end
    end
    if not wasGrounded and IsGrounded() and state == "Jumping" then
       
        state = humanoid.MoveDirection.Magnitude > 0 and "Running" or "Idle"

        local hrp = character.HumanoidRootPart
        local v = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
        jumpCooldown = 0.2
    end
    
    wasGrounded = IsGrounded()
    jumpRequested = false
end)


