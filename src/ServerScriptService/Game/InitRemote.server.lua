local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("Remote")
local RemoteDef = ReplicatedStorage:WaitForChild("RemoteDef")

for _, module in RemoteDef:GetChildren() do
    if module:IsA("ModuleScript") then
        local remoteInfo = require(module)
        if remoteInfo.Type == "RemoteEvent" then
            local remoteEvent = Instance.new("RemoteEvent")
            remoteEvent.Name = remoteInfo.Name
            remoteEvent.Parent = Remote
        elseif remoteInfo.Type == "RemoteFunction" then
            local remoteFunction = Instance.new("RemoteFunction")
            remoteFunction.Name = remoteInfo.Name
            remoteFunction.Parent = Remote
        end
        module:Destroy() -- Clean le module pour ne pas l'appeler a la place de la remote
    end
end