local Players = game:GetService("Players")
local ReplicateStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local EntrerTerrierEvent = ReplicateStorage.Remote:WaitForChild("EntrerTerrierEvent")

--------------------------------------------------
-- Attendre la structure
--------------------------------------------------

local Terrier = workspace:WaitForChild("Terrier")
local EntreeFolder = Terrier:WaitForChild("Entre")
local SortieFolder = Terrier:WaitForChild("Sortie")

--------------------------------------------------
-- Fonction d'initialisation d'une porte
--------------------------------------------------

local function InitPorte(porteSource, porteDestination)

	local prompt = porteSource:WaitForChild("ProximityPrompt")

	prompt.Triggered:Connect(function(playerHit)
		if playerHit == player then
			EntrerTerrierEvent:FireServer(porteDestination)
		end
	end)
end


--------------------------------------------------
-- Associer les portes
--------------------------------------------------
for _, porteEntree in EntreeFolder:GetChildren() do
	local porteSortie = SortieFolder:WaitForChild(porteEntree.Name)
	InitPorte(porteEntree, porteSortie)
	InitPorte(porteSortie, porteEntree)
end

EntreeFolder.ChildAdded:Connect(function(porteEntree)
	local porteSortie = SortieFolder:WaitForChild(porteEntree.Name)
	InitPorte(porteEntree, porteSortie)
	InitPorte(porteSortie, porteEntree)
end)
