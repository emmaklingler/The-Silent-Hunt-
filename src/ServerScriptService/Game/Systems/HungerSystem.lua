local HungerSysteme = {}
local listPlayer = {} -- dictionnaire des joueurs et de leurs classes RabbitClass

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteHunger = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("HungerChangeEvent")

function HungerSysteme:Init(players)
    listPlayer = players   
    for player, RabbitClass in listPlayer do
        RemoteHunger:FireClient(player, RabbitClass.Satiety)
    end
end


function HungerSysteme:Start()
    while true do
        task.wait(1)
        for player, RabbitClass in listPlayer do
            RabbitClass:RemoveSatiety(1)
        end
    end
end


return HungerSysteme