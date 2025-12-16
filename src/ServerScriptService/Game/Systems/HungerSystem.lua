local HungerSysteme = {}
local listPlayer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteHunger = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("HungerChangeEvent")

function HungerSysteme:Init(players)
    listPlayer = players   
    for player, RabbitClass in listPlayer do
        RemoteHunger:FireClient(player, RabbitClass.Hunger)
    end
end


function HungerSysteme:Start()
    while true do
        task.wait(1)
        for player, RabbitClass in listPlayer do
            RabbitClass:TakeHunger(1)
        end
    end
end


return HungerSysteme