--- CanseeTarget.lua
local conditionNode = script.Parent
assert(conditionNode, "Script must have a parent")

local nodeFolder = conditionNode.Parent
assert(nodeFolder, "ConditionNode must be inside Node folder")

local Utiles = nodeFolder:WaitForChild("Utiles")
local StatusModule = Utiles:WaitForChild("Status"):WaitForChild("Status")
local Status = require(StatusModule :: ModuleScript)
local CanSeeTarget = {}
CanSeeTarget.__index = CanSeeTarget

function CanSeeTarget.new(maxDist, fieldOfView)
    return setmetatable({ 
        maxDist = maxDist or 60,
        fov = fieldOfView or 120 
    }, CanSeeTarget)
end

local function getMainPart(model: Model)
    return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
end

function CanSeeTarget:Run(hunter, bb)
    local target = hunter.Target
    if not target or not target.Parent then return Status.FAILURE end

    local hunterPart = getMainPart(hunter.Model)
    local targetPart = getMainPart(target)

    if not hunterPart or not targetPart then return Status.FAILURE end

   
    local vectorToTarget = targetPart.Position - hunterPart.Position
    local distance = vectorToTarget.Magnitude
    if distance > self.maxDist then return Status.FAILURE end

   
    local lookVector = hunterPart.CFrame.LookVector
    local unitToTarget = vectorToTarget.Unit
    local dotProduct = lookVector:Dot(unitToTarget)
    local angle = math.deg(math.acos(dotProduct))

    if angle > (self.fov / 2) then
        return Status.FAILURE
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {hunter.Model} 
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local rayResult = workspace:Raycast(hunterPart.Position, vectorToTarget, raycastParams)

    if rayResult and rayResult.Instance:IsDescendantOf(target) then
        bb.lastSeenPos = targetPart.Position
        return Status.SUCCESS
    end

    return Status.FAILURE
end

return CanSeeTarget