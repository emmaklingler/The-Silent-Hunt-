local player = game.Players.LocalPlayer

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remote")
local StartGameEvent = Remotes:WaitForChild("StartGameEvent")

local function clampToCircle(x, y, radius)
    local cx = x - 0.5
    local cy = y - 0.5

    local dist = math.sqrt(cx*cx + cy*cy)

    if dist > radius then
        local scale = radius / dist
        cx = cx * scale
        cy = cy * scale
    end

    -- remettre en 0 → 1
    return cx + 0.5, cy + 0.5
end


local function worldToMap(pos)
    local worldMin = Vector2.new(-260, -280)
    local worldMax = Vector2.new(240, 180)

    local xRatio = (pos.X - worldMin.X) / (worldMax.X - worldMin.X)
    local yRatio = (pos.Z - worldMin.Y) / (worldMax.Y - worldMin.Y)

    return 1-yRatio, xRatio+0.02
end


local RunService = game:GetService("RunService")

local connection

StartGameEvent.OnClientEvent:Connect(function()
    local map = player.PlayerGui:WaitForChild("HUD").MiniMap.Frame
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    if connection then
        connection:Disconnect()
    end

   connection = RunService.RenderStepped:Connect(function()
        local xRatio, yRatio = worldToMap(humanoidRootPart.Position)

        -- clamp carré (sécurité)
        xRatio = math.clamp(xRatio, 0, 1)
        yRatio = math.clamp(yRatio, 0, 1)

        -- appliquer cercle (0.5 = centre, 0.4 = rayon)
        xRatio, yRatio = clampToCircle(xRatio, yRatio, 0.4)

        map.Player.Position = UDim2.new(xRatio, 0, yRatio, 0)
    end)
end)