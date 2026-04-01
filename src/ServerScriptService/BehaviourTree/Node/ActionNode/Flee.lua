local Flee = {}
Flee.__index = Flee

local Status = require(script.Parent.Parent.Utiles.Status)

function Flee.new()
    return setmetatable({}, Flee)
end

function Flee:Run(rabbit, blackboard)
    -- Sécurité : si on n'a pas la position du chasseur, on ne peut pas fuir
    if not blackboard.hunterPosition then
        return Status.FAILURE
    end

    -- On déclenche la logique de fuite physique
    local result = rabbit:TryFlee(blackboard.hunterPosition)

    -- SI LE RÉSULTAT EST "RUNNING", ON FORCE L'ANIMATION
    if result == Status.RUNNING then
        rabbit:ChangeState("Running")
    end

    return result
end

return Flee