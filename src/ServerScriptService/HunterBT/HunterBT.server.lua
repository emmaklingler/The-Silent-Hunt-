local RunService = game:GetService("RunService")

local HunterBT = script.Parent
local BehaviourTree = HunterBT:WaitForChild("BehaviourTree")
local Node = BehaviourTree:WaitForChild("Node")

local Selector = require(Node.Utiles.Selector.Selector)
local Sequence = require(Node.Utiles.Sequence.Sequence)
local CanSeeTarget = require(Node.ConditionNode.CanSeeTarget)
local FollowTarget = require(Node.ActionNode.FollowTarget)
local Patrol = require(Node.ActionNode.Patrol)

local HunterClass = require(HunterBT.Parent.Hunter.HunterClass)

local hunterModel = workspace:WaitForChild("Humans_Master_off")
local hunter = HunterClass.new(hunterModel)

local bb = {
    lastTick = 0,
    tickRate = 0.2 
}

local root = Selector.new({
    Sequence.new({
        CanSeeTarget.new(60),
        FollowTarget.new(6),
    }),
    Patrol.new(),
})

RunService.Heartbeat:Connect(function(dt)
    bb.dt = dt
    bb.lastTick += dt
    
    if bb.lastTick >= bb.tickRate then
        bb.lastTick = 0
        
       
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("IsRabbit") then
                hunter.Target = p.Character
                break
            end
        end

        if hunter.Target then
            local status = root:Run(hunter, bb)
        else
            Patrol.new():Run(hunter, bb)
        end
    end
end)