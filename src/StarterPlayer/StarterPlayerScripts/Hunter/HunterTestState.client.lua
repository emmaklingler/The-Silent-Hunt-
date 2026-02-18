local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeAction = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangeActionEvent")
local ChangePerception = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangePerceptionEvent")
local ChangePoids = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ChangePoidsEvent")


local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


ChangeAction.OnClientEvent:Connect(function(stats)
    for _, frame in PlayerGui:WaitForChild("Test").Frame.Frame:GetChildren() do
            if frame:IsA("TextLabel") then
                frame:Destroy()
            end
        end
    for name, val in stats do
	    val = math.floor(val * 1000) / 1000
        local textLabel = PlayerGui:WaitForChild("Test"):WaitForChild("Template"):Clone()
        textLabel.Text = name .. " : " .. val
        textLabel.Visible = true
        textLabel.Parent = PlayerGui:WaitForChild("Test").Frame.Frame
    end
end)


ChangePerception.OnClientEvent:Connect(function(stats)
    for _, frame in PlayerGui:WaitForChild("Test").Frame.Perception:GetChildren() do
            if frame:IsA("TextLabel") then
                frame:Destroy() 
            end
        end
    for name, val in stats do
	    val = math.floor(val * 1000) / 1000
        local textLabel = PlayerGui:WaitForChild("Test"):WaitForChild("Template"):Clone()
        textLabel.Text = name .. " : " .. val
        textLabel.Visible = true
        textLabel.Parent = PlayerGui:WaitForChild("Test").Frame.Perception
    end
end)

ChangePoids.OnClientEvent:Connect(function(stats)
    table.sort(stats, function(a, b) return a[2] > b[2] end) -- Trie les poids par ordre décroissant
    for _, frame in PlayerGui:WaitForChild("Test").Frame.Poids:GetChildren() do
        if frame:IsA("TextLabel") then
            frame:Destroy() 
        end
    end
    local i = 0
    for name, val in stats do
        i+=1
	    val = math.floor(val * 1000) / 1000
        local textLabel = PlayerGui:WaitForChild("Test"):WaitForChild("Template"):Clone()
        textLabel.Name = i
        textLabel.Text = name .. " : " .. val
        textLabel.Visible = true
        textLabel.Parent = PlayerGui:WaitForChild("Test").Frame.Poids
    end
end)



local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.I then
        PlayerGui:WaitForChild("Test").Enabled = not PlayerGui:WaitForChild("Test").Enabled
    end
end)


