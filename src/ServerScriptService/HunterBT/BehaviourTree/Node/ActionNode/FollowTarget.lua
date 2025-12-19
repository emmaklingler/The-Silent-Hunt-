-- FollowTarget.lua
local scriptParent = script.Parent :: Instance
local nodeFolder = scriptParent.Parent :: Instance
local utilesFolder = nodeFolder:WaitForChild("Utiles")

local statusModule = utilesFolder:WaitForChild("Status"):WaitForChild("Status") :: ModuleScript
local Status = require(statusModule)
local FollowTarget = {}
FollowTarget.__index = FollowTarget

function FollowTarget.new(stopDist)
    return setmetatable({ stopDist = stopDist or 6 }, FollowTarget)
end

local function getMainPart(model: Model): BasePart?
    return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") :: BasePart?
end

function FollowTarget:Run(hunter, bb)
    local target = hunter.Target
    if not target then return Status.FAILURE end

    local hunterPart = hunter.Model.PrimaryPart
    local targetPart = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart")

    if not hunterPart or not targetPart then return Status.FAILURE end

    local dist = (targetPart.Position - hunterPart.Position).Magnitude

    if dist <= self.stopDist then
        hunter:StopMoving()
        return Status.SUCCESS
    end

    if hunter.Humanoid then hunter.Humanoid.WalkSpeed = 20 end

    hunter:MoveTo(targetPart.Position)
    return Status.RUNNING
end
return FollowTarget