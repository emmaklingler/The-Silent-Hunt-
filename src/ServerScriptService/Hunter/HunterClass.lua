local PathfindingService = game:GetService("PathfindingService")

local Hunter = {}
Hunter.__index = Hunter

-- Configuration des vitesses
local SPEEDS = {
    PATROL = 12,
    CHASE = 18,
    STUNNED = 0
}

function Hunter.new(model: Model)
    local self = setmetatable({}, Hunter)

    self.Model = model
    self.Humanoid = model:FindFirstChildOfClass("Humanoid")
    self.Target = nil
    
    -- On force le PrimaryPart dès le départ
    if not self.Model.PrimaryPart then
        self.Model.PrimaryPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("RootPart")
    end

    -- Configuration du Pathfinding
    self.Path = PathfindingService:CreatePath({
        AgentRadius = 3,
        AgentHeight = 6,
        AgentCanJump = true,
        Costs = { Water = 20 }
    })

    -- Sécurité Physique : Force le calcul sur le serveur pour éviter que l'IA ne freeze
    if self.Model.PrimaryPart then
        local success, err = pcall(function()
            self.Model.PrimaryPart:SetNetworkOwner(nil)
        end)
        if not success then warn("⚠️ NetworkOwner Error:", err) end
    end

    print("🤖 HunterClass: Instance créée pour", model.Name)
    return self
end

function Hunter:SetStateSpeed(stateName: string)
    if self.Humanoid and SPEEDS[stateName] then
        self.Humanoid.WalkSpeed = SPEEDS[stateName]
    end
end

function Hunter:MoveTo(position: Vector3)
    if not self.Humanoid or not self.Model.PrimaryPart then return end
    
    local dist = (position - self.Model.PrimaryPart.Position).Magnitude
    
    -- Pour l'instant on reste sur du MoveTo simple pour débugger le mouvement de base
    self.Humanoid:MoveTo(position)
end

function Hunter:StopMoving()
    if self.Humanoid then
        self.Humanoid:Move(Vector3.zero)
    end
end

function Hunter:GetPosition(): Vector3
    return self.Model.PrimaryPart and self.Model.PrimaryPart.Position or Vector3.zero
end

return Hunter