local HunterClose = {}
HunterClose.__index = HunterClose

local Status = require(script.Parent.Parent.Utiles.Status)

function HunterClose.new(radius)
    local self = setmetatable({}, HunterClose)
    self.radius = radius or 150
    return self
end

function HunterClose:Run(rabbit, blackboard)
    local hunter = workspace:FindFirstChild("Chasseur_Test")
    if not hunter or not hunter:FindFirstChild("HumanoidRootPart") then
        blackboard.hunterRoot = nil
        return Status.FAILURE
    end

    local hunterRoot = hunter.HumanoidRootPart

    if rabbit:CanSeeHunter(hunterRoot) then
        blackboard.hunterRoot = hunterRoot
        blackboard.lastSeenHunterTime = os.clock()
        return Status.SUCCESS
    end

    -- Mémoire : garde le chasseur en tête pendant 3s après l'avoir perdu de vue
    if blackboard.lastSeenHunterTime and (os.clock() - blackboard.lastSeenHunterTime) < 3 then
        blackboard.hunterRoot = hunterRoot
        return Status.SUCCESS
    end

    blackboard.hunterRoot = nil
    return Status.FAILURE
end

return HunterClose