local RunService = game:GetService("RunService")
local Status = require(game.ServerScriptService.BehaviourTree.Node.Utiles.Status)

if not RunService:IsStudio() then return end

print("========== TEST BEHAVIOUR TREE ==========")

local NodeFolder = game.ServerScriptService.BehaviourTree.Node

local CloseAttack = require(NodeFolder.ActionNode.CloseAttack)
local FollowTarget = require(NodeFolder.ActionNode.FollowTarget)
local GetMunitions = require(NodeFolder.ActionNode.GetMunitions)
local MakeTrap = require(NodeFolder.ActionNode.MakeTrap)
local ReloadWeapon = require(NodeFolder.ActionNode.ReloadWeapon)
local RangedAttack = require(NodeFolder.ActionNode.RangedAttack)

--------------------------------------------------------
-- OUTIL ASSERT LISIBLE
--------------------------------------------------------
local function expect(condition, message)
	if not condition then
		error("❌ " .. message)
	else
		print("✅ " .. message)
	end
end

--------------------------------------------------------
-- FAKE HUNTER (modifiable selon test)
--------------------------------------------------------
local function createFakeHunter()
	return {
		Root = { Position = Vector3.new(0,0,0) },
		trapsStock = 2,
		ammoInMag = 1,
		ammoReserve = 1,
		state = "Idle",

		TryAttackClose = function()
			return Status.SUCCESS
		end,

		TryRangedAttack = function()
			return Status.SUCCESS
		end,

		TryReloadWeapon = function()
			return Status.SUCCESS
		end,

		Follow = function()
			return Status.SUCCESS
		end,

		NeedsMunitions = function()
			return false
		end,

		TryPlaceTrapAt = function()
			return true
		end,
	}
end

--------------------------------------------------------
-- FAKE BLACKBOARD
--------------------------------------------------------
local function createFakeBlackboard()
	return {
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
end

--------------------------------------------------------
-- TEST CLOSE ATTACK
--------------------------------------------------------
do
	local hunter = createFakeHunter()
	local bb = createFakeBlackboard()

	local node = CloseAttack.new()
	local result = node:Run(hunter, bb)

	expect(result == Status.SUCCESS,
		"CloseAttack retourne SUCCESS si cible valide")
end

--------------------------------------------------------
-- TEST FOLLOW TARGET
--------------------------------------------------------
do
	local hunter = createFakeHunter()
	local bb = createFakeBlackboard()

	local node = FollowTarget.new()
	local result = node:Run(hunter, bb)

	expect(result == Status.SUCCESS,
		"FollowTarget suit la cible correctement")
end

--------------------------------------------------------
-- TEST RELOAD WEAPON
--------------------------------------------------------
do
	local hunter = createFakeHunter()
	hunter.ammoInMag = 0
	hunter.ammoReserve = 2

	local node = ReloadWeapon.new()
	local result = node:Run(hunter)

	expect(result == Status.SUCCESS,
		"ReloadWeapon fonctionne si réserve > 0")
end

--------------------------------------------------------
-- TEST GET MUNITIONS (pas besoin)
--------------------------------------------------------
do
	local hunter = createFakeHunter()
	local bb = createFakeBlackboard()

	hunter.NeedsMunitions = function()
		return false
	end

	local node = GetMunitions.new()
	local result = node:Run(hunter, bb)

	expect(result == Status.FAILURE,
		"GetMunitions échoue si pas besoin")
end

--------------------------------------------------------
-- TEST GET MUNITIONS (besoin réel)
--------------------------------------------------------
do
	local hunter = createFakeHunter()
	local bb = createFakeBlackboard()

	hunter.NeedsMunitions = function()
		return true
	end

	hunter.GetHutPart = function()
		return { Position = Vector3.new(0,0,0) }
	end

	hunter.RefillMunitions = function()
		return true
	end

	local node = GetMunitions.new()
	local result = node:Run(hunter, bb)

	expect(
		result == Status.SUCCESS or result == Status.RUNNING,
		"GetMunitions fonctionne si besoin réel"
	)
end

--------------------------------------------------------
-- TEST MAKE TRAP (conditions OK)
--------------------------------------------------------
do
	local hunter = createFakeHunter()
	local bb = createFakeBlackboard()

	hunter.Root.Position = Vector3.new(5,0,5)

	local node = MakeTrap.new()
	local result = node:Run(hunter, bb)

	expect(
		result == Status.SUCCESS or result == Status.RUNNING,
		"MakeTrap pose un piège si conditions remplies"
	)
end

--------------------------------------------------------
-- TEST MAKE TRAP (pas de stock)
--------------------------------------------------------
do
	local hunter = createFakeHunter()
	local bb = createFakeBlackboard()

	hunter.trapsStock = 0

	local node = MakeTrap.new()
	local result = node:Run(hunter, bb)

	expect(result == Status.FAILURE,
		"MakeTrap échoue si stock = 0")
end

--------------------------------------------------------
-- TEST RANGED ATTACK
--------------------------------------------------------
do
	local hunter = createFakeHunter()
	local bb = createFakeBlackboard()

	local node = RangedAttack.new()
	local result = node:Run(hunter, bb)

	expect(result == Status.SUCCESS,
		"RangedAttack fonctionne si cible valide")
end

print("========== TOUS LES TESTS NODE PASSÉS ==========")
