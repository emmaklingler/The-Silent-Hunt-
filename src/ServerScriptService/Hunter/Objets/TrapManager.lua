-- TrapManager.lua
local RunService = game:GetService("RunService")

local TrapManager = {}
TrapManager.__index = TrapManager

function TrapManager.new()
	local self = setmetatable({}, TrapManager)

	self.traps = {}         -- [trapId] = trap
	self.count = 0
	self._conn = nil

	-- réglages
	self.tickInterval = 0.10   -- check toutes les 0.10s (10x/sec)
	self._nextTick = 0

	return self
end

function TrapManager:_start()
	if self._conn then return end

	self._nextTick = os.clock()
	self._conn = RunService.Heartbeat:Connect(function()
		-- cadence globale (évite de check à chaque frame)
		local now = os.clock()
		if now < self._nextTick then
			return
		end
		self._nextTick = now + self.tickInterval

		-- plus aucun trap ? on coupe
		if self.count <= 0 then
			self:_stop()
			return
		end

		-- boucle sur les traps
		for id, trap in pairs(self.traps) do
			-- trap peut être nil si supprimé entre temps
			if trap and trap.IsActive then
				local triggered = trap:Check() -- renvoie true si le piège s'est déclenché
				if triggered then
					-- pour l'instant : print + destroy
					self:RemoveTrap(id)
				end
			else
				-- sécurité : nettoie les traps morts
				self:RemoveTrap(id)
			end
		end
	end)
end

function TrapManager:_stop()
	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end
end

function TrapManager:AddTrap(trap)
	-- trap doit avoir un Id unique
	local id = trap.Id
	if not id then
		warn("[TrapManager] Trap has no Id")
		return nil
	end

	if self.traps[id] then
		-- déjà enregistré
		return id
	end

	self.traps[id] = trap
	self.count += 1

	-- démarre la boucle si besoin
	if self.count == 1 then
		self:_start()
	end

	return id
end

function TrapManager:RemoveTrap(id)
	if self.traps[id] ~= nil then
		self.traps[id] = nil
		self.count -= 1

		-- coupe si plus rien
		if self.count <= 0 then
			self.count = 0
			self:_stop()
		end
	end
end

function TrapManager:GetCount()
	return self.count
end

return TrapManager
