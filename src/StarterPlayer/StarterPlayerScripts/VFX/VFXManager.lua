local VFXManager = {}

local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

-- Folder de VFX temporaires (Workspace pour éviter Rojo)
local VFXFolder = Workspace:WaitForChild("TEMPVFX")

--------------------------------------------------
-- Utils
--------------------------------------------------

-- Retourne un Attachment + un bool indiquant s'il est temporaire
local function getAttachment(positionOrAttachment)
    -- Si c'est déjà un Attachment, on le réutilise
    if typeof(positionOrAttachment) == "Instance"
        and positionOrAttachment:IsA("Attachment") then
        return positionOrAttachment, false
    end

    -- Sinon on considère que c'est un Vector3
    local attachment = Instance.new("Attachment")
    attachment.WorldPosition = positionOrAttachment
    attachment.Parent = Workspace.Terrain

    return attachment, true
end

--------------------------------------------------
-- Beam (tir)
--------------------------------------------------
function VFXManager:PlayBeam(origin, hitPosition, duration, name)
    duration = duration or 0.1

    local attachment0, temp0 = getAttachment(origin)
    local attachment1, temp1 = getAttachment(hitPosition)

    local beam = VFXFolder:WaitForChild(name):Clone()
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Parent = attachment0
    beam.Enabled = true

    task.delay(duration, function()
        beam.Enabled = false
        beam:Destroy()

        if temp0 then attachment0:Destroy() end
        if temp1 then attachment1:Destroy() end
    end)
end

--------------------------------------------------
-- Particules / Impact
--------------------------------------------------
function VFXManager:PlayParticle(positionOrAttachment, name, lifetime)
    lifetime = lifetime or 3

    local attachment, isTemporary = getAttachment(positionOrAttachment)

    local particles = VFXFolder:WaitForChild(name):Clone()
    particles.Parent = attachment
    particles.Enabled = true

    task.delay(lifetime, function()
        particles.Enabled = false
    end)
    -- Nettoyage
    Debris:AddItem(particles, lifetime+particles.Lifetime.Max)

    if isTemporary then
        Debris:AddItem(attachment, lifetime)
    end
end

return VFXManager
