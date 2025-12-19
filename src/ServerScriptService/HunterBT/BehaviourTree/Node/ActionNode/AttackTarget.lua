local actionNode = script.Parent
local Status = require(actionNode.Parent.Utiles.Status.Status)

local AttackTarget = {}
AttackTarget.__index = AttackTarget

-- création du noeud d'attaque avec portée et cooldown
function AttackTarget.new(range, cooldown)
    return setmetatable({
        range = range or 7,
        cooldown = cooldown or 1.5,
        lastAttack = 0
    }, AttackTarget)
end

-- exécution de la logique d'attaque
function AttackTarget:Run(hunter, bb)
    local target = hunter.Target
    if not target or not target:FindFirstChild("Humanoid") then return Status.FAILURE end

    local dist = hunter:GetDistanceTo(target)
    
    -- vérification de la distance pour attaquer
    if dist > self.range then
        return Status.FAILURE
    end

    -- gestion du temps d'attente entre deux attaques
    local now = tick()
    if now - self.lastAttack < self.cooldown then
        hunter:StopMoving()
        return Status.RUNNING 
    end

    -- lancement de l'attaque
    self.lastAttack = now
    print("Attaque Target: le chasseur frappe " .. target.Name)
    
    -- application des dégâts sur la cible
    target.Humanoid:TakeDamage(20)
    
    

    return Status.SUCCESS
end

return AttackTarget