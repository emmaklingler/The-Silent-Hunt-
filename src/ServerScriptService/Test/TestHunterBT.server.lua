local RunService = game:GetService("RunService")
local Status = require(game.ServerScriptService.BehaviourTree.Node.Utiles.Status)

if not RunService:IsStudio() then return end

print("=== Début des tests BT ===")

local NodeFolder = game.ServerScriptService.BehaviourTree.Node

-- Correction ici
local CloseAttack = require(NodeFolder.ActionNode.CloseAttack)
local FollowTarget = require(NodeFolder.ActionNode.FollowTarget)
local GetMunitions = require(NodeFolder.ActionNode.GetMunitions)
local MakeTrap = require(NodeFolder.ActionNode.MakeTrap)

-- =========================
-- FAKE HUNTER
-- =========================
local fakeHunter = {
    Root = { Position = Vector3.new(0,0,0) },
    trapsStock = 2,
    state = "Idle",

    TryAttackClose = function()
        return Status.SUCCESS
    end,

    Follow = function()
        return Status.SUCCESS
    end,

    NeedsMunitions = function()
        return false
    end,
}

-- =========================
-- FAKE BLACKBOARD
-- =========================
local fakeBlackboard = {
    lastKnownPosition = Vector3.new(5,0,5),

    GetBestTargetOrPosition = function()
        return { Root = { Position = Vector3.new(3,0,3) } }, "Target"
    end,

    HasValidTarget = function()
        return false
    end,

    HasMemory = function()
        return true
    end,

    ClearMemory = function(self)
        self.lastKnownPosition = nil
    end,
}

-- =========================
-- TEST CloseAttack
-- =========================
local attackNode = CloseAttack.new()
local result = attackNode:Run(fakeHunter, fakeBlackboard)
assert(result == Status.SUCCESS, "❌ CloseAttack FAILED")
print("✅ CloseAttack OK")

-- =========================
-- TEST FollowTarget
-- =========================
local followNode = FollowTarget.new()
result = followNode:Run(fakeHunter, fakeBlackboard)
assert(result == Status.SUCCESS, "❌ FollowTarget FAILED")
print("✅ FollowTarget OK")

-- =========================
-- TEST GetMunitions
-- =========================
local muniNode = GetMunitions.new()
result = muniNode:Run(fakeHunter, fakeBlackboard)
assert(result == Status.FAILURE, "❌ GetMunitions FAILED")
print("✅ GetMunitions OK")



print("/////// Tous les tests unitaires Node OK //////")
