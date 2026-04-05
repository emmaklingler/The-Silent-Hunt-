local DetectCarrot = {}
DetectCarrot.__index = DetectCarrot

local Status = require(script.Parent.Parent.Utiles.Status)

--[[
    Noeud DetectCarrot : cherche la carotte la plus proche dans workspace.Carrot
    et la stocke dans le blackboard si elle est à portée.

    @param maxDistance: number - rayon de détection (défaut: 200)
]]
function DetectCarrot.new(maxDistance)
    local self = setmetatable({}, DetectCarrot)
    self.maxDistance = maxDistance or 200
    return self
end

function DetectCarrot:Run(rabbit, blackboard)
    local carrot = rabbit:GetClosestCarrot(self.maxDistance)

    if carrot then
        blackboard:SetClosestCarrot(carrot)
        return Status.SUCCESS
    end

    -- Aucune carotte à portée : on nettoie le blackboard
    blackboard:SetClosestCarrot(nil)
    return Status.FAILURE
end

return DetectCarrot