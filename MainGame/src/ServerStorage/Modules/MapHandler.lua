local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

local ServerStorage = game.ServerStorage
local ReplicatedStorage = game.ReplicatedStorage

local MapHandler = {}

local WaitingStartTime = 20

local VotedPlayers = {}

local VotingTime = 30
local Voting = false

local GUIsFolder
local ValuesFolder

local Difficulties = {
	"Easy",
	"Normal",
	"Hard",
	"Nightmare",
}

local DifficultyChosen

local function SomeSetup()
	local EnemiesFolder = Instance.new("Folder",workspace)
	EnemiesFolder.Name = "Enemies"
	
	local LocalFolder = Instance.new("Folder",workspace)
	LocalFolder.Name = "LocalPlace"
	
	local UnitsFolder = Instance.new("Folder",workspace)
	UnitsFolder.Name = "Units"
end

SomeSetup()

local function Length(Table)
	local counter = 0 
	for _, v in pairs(Table) do
		counter =counter + 1
	end
	return counter
end

local DifficultyVoteCount = {}

MapHandler.Timer = 0

MapHandler.EnemyCount = 0
MapHandler.GameEnd = false

MapHandler.PathID = nil

MapHandler.Map = nil

MapHandler.LocalValues = nil

function MapHandler.init(map, playersList)	
	MapHandler.Map = ServerStorage.Maps[map]:Clone()
	MapHandler.Map.Name = "Map"
	MapHandler.Map.Parent = workspace
	
	GUIsFolder = Instance.new("Folder")
	GUIsFolder.Parent = MapHandler.Map
	GUIsFolder.Name = "GUIs"
	
	MapHandler.LocalValues = Instance.new("Folder")
	MapHandler.LocalValues.Parent = MapHandler.Map
	MapHandler.LocalValues.Name = "Values"
	
	MapHandler.CurrentWave = Instance.new("IntValue")
	MapHandler.CurrentWave.Parent = MapHandler.LocalValues
	MapHandler.CurrentWave.Name = "CurrentWave"
	MapHandler.CurrentWave.Value = 0
	
	MapHandler.MapTimer = Instance.new("IntValue")
	MapHandler.MapTimer.Parent = MapHandler.LocalValues
	MapHandler.MapTimer.Name = "MapTimer"
	MapHandler.MapTimer.Value = 0
	
	local GameLost = Instance.new("BoolValue")
	GameLost.Parent = MapHandler.LocalValues
	GameLost.Name = "GameLost"
	GameLost.Value = false

	for _,mapParts in pairs(MapHandler.Map:GetDescendants()) do
		if mapParts:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(mapParts, "Map")
		end
	end

	VotingStart(playersList)
end

function MapHandler:DialogPlayers(subject, text, readTime)
	ReplicatedStorage.Events.Players.DialogSend:FireAllClients(subject, text, readTime)
	wait(readTime)
end

function VotingStart(playersList)
	if Voting then return end
	if not MapHandler.LocalValues then return end

	local WaitingTimer = Instance.new("IntValue")
	WaitingTimer.Parent = MapHandler.LocalValues
	WaitingTimer.Name = "WaitingTimer"
	WaitingTimer.Value = 0

	local VotingTimer = Instance.new("IntValue")
	VotingTimer.Parent = MapHandler.LocalValues
	VotingTimer.Name = "VoteTimer"
	VotingTimer.Value = VotingTime

	Voting = true

	local VoteSkipRound = Instance.new("BoolValue")
	VoteSkipRound.Parent = MapHandler.LocalValues
	VoteSkipRound.Name = "VoteSkipRound"
	VoteSkipRound.Value = false

	for i=WaitingStartTime,0, -1 do
		if RunService:IsStudio() then break end

		if #Players:GetPlayers() == #playersList then
			print("enough players to skip!")
			break
		end

		WaitingTimer.Value = i

		wait(1)
	end

	WaitingTimer.Value = -1

	if RunService:IsStudio() then VotingTime = 3 end

	for i = VotingTime,0,-1 do
		if not RunService:IsStudio() then
			if Length(VotedPlayers) == #playersList then break end
		end		

		VotingTimer.Value = i	
		wait(1)
	end

	VotingTimer.Value = -1

	if Length(VotedPlayers) == 0 then
		DifficultyChosen = "Normal"
	else	
		local chosenDifficulty

		for k,v in pairs(DifficultyVoteCount) do
			if not chosenDifficulty then
				chosenDifficulty = k
			else
				if #v > DifficultyVoteCount[chosenDifficulty] then
					chosenDifficulty = k
				end
			end
		end

		DifficultyChosen = chosenDifficulty
	end

	if DifficultyChosen then
		MapHandler:DialogPlayers("Weabonie", "You have picked difficulty: ".. DifficultyChosen, 4)

		if DifficultyChosen == "Nightmare" then
			MapHandler:DialogPlayers("Weabonie", "Err... you sure you are ready for this mode?", 4)
			MapHandler:DialogPlayers("Weabonie", "Whatever, let's get started!", 3)
		end

		--if not RunService:IsStudio() then

		--end		

		ServerStorage.Events.Game.GameStart:Fire(MapHandler:getMap())
	end
end

function MapHandler:getMap()
	return self.Map
end

function MapHandler:getDiff()
	return DifficultyChosen
end

function MapHandler:addVoteDiff(player, diff)
	if table.find(Difficulties, diff) then
		if VotedPlayers[player] then
			if VotedPlayers[player] ~= diff then
				VotedPlayers[player] = diff
			end
		else
			VotedPlayers[player] = diff
		end
	end
	
	DifficultyVoteCount = {}
	
	for plr, diff in pairs(VotedPlayers) do
		if not DifficultyVoteCount[diff] then
			DifficultyVoteCount[diff] = {}

			table.insert(DifficultyVoteCount[diff], plr)
		else
			if not table.find(DifficultyVoteCount[diff], plr) then
				table.insert(DifficultyVoteCount[diff], plr)
			end
		end
	end
	
	ReplicatedStorage.Events.Setup.VoteDiff:FireAllClients(DifficultyVoteCount)
end

function MapHandler:SpawnEnemies(enemy_name, amount, rate, waveTime, customUnitSpawned)
	if not customUnitSpawned then
		MapHandler.EnemyCount += amount
	end
	
	coroutine.wrap(function()
		wait(waveTime)
		
		for i=1,amount do
			if MapHandler.GameEnd then return end

			local newEnemy = game.ServerStorage.Enemies[enemy_name]:Clone()
			
			local PathInGame = MapHandler.Map.Decorations:FindFirstChild("Path")
			
			local EnemySpawn = MapHandler.Map.EnemySpawns["1"]
			
			local NewCFrameSpawn
			
			if customUnitSpawned ~= nil then
				if customUnitSpawned:IsDestroyed() then return end
				local TargetRootPos = customUnitSpawned.Instance.HumanoidRootPart.CFrame.p
				
				NewCFrameSpawn = CFrame.new(Vector3.new(TargetRootPos.X, newEnemy["Left Leg"].Size.Y + newEnemy.PrimaryPart.Size.Y/2 + PathInGame.Size.Y, TargetRootPos.Z))
				newEnemy:SetAttribute("SpawnedCurrentPath", customUnitSpawned:getCurrentPath().Name)
			else
				NewCFrameSpawn = CFrame.new(Vector3.new(EnemySpawn.CFrame.p.X, newEnemy["Left Leg"].Size.Y + newEnemy.PrimaryPart.Size.Y/2 + PathInGame.Size.Y,EnemySpawn.CFrame.p.Z))
			end		
			
			newEnemy.PrimaryPart.CFrame = NewCFrameSpawn

			newEnemy.Parent = workspace.Enemies
			
 			wait(rate)		
		end
	end)()
end

function MapHandler.GameLost()
	local GameLostVal = MapHandler.LocalValues:WaitForChild("GameLost")
	
	if GameLostVal.Value then return end
	
	GameLostVal.Value = true
	
	ReplicatedStorage.Events.Game.GameLostActivate:FireAllClients()
end

return MapHandler
