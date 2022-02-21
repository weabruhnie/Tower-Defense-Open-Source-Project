local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ServerStorage = game.ServerStorage
local ReplicatedStorage = game.ReplicatedStorage

ServerStorage.Database:Clone().Parent = ReplicatedStorage
ServerStorage.UnitSkins:Clone().Parent = ReplicatedStorage

local EcoHandler = require(ServerStorage.Modules.Players.EcoHandler)
local MapHandler = require(ServerStorage.Modules.MapHandler)

local isReserved = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0

local SetupComplete = false

local approvedPlaceIds = {
	7455490966,
	7455388318
} -- insert approved PlaceIds here

local PlayersEco = {}

local function isPlaceIdApproved(placeId)
	for _, id in pairs(approvedPlaceIds) do
		if id == placeId then
			return true
		end
	end
	return false
end

function playerAdded(player)
	if not isReserved then
		if not RunService:IsStudio() then
			player:Kick("Game not authorized")
		end	
	end
	
	if not PlayersEco[player] then
		local plr_vals = Instance.new("Configuration",player)
		plr_vals.Name = "plr_vals"
		
		PlayersEco[player] = EcoHandler.int(player)
	end	
	
	GameSetup(player)
end

function playerRemoved(player)
	if PlayersEco[player] then
		print("player left")
		PlayersEco[player] = nil
	end	
end

local CurrentMap

local HealthSystem

function AddMaxHP(plr)
	if not HealthSystem then return end
	
	local plr_Data = ServerStorage.Events.Saves.RequestPlayerData:Invoke(plr)

	if plr_Data then
		HealthSystem:IncreaseMaxHP(plr, plr_Data.Level)
	end
end

function GameSetup(player)	
	if SetupComplete then
		AddMaxHP(player)
	return end
	
	SetupComplete = true	
	
	local joinData = player:GetJoinData()
	
	if RunService:IsStudio() then
		local pickedMap = "Grasslands"
		print("Current map is " .. pickedMap)	
		
		MapHandler.init(pickedMap)
		HealthSystem = require(ServerStorage.Modules.Mains.HealthSystem).Int(MapHandler:getMap())
		
		AddMaxHP(player)
		
		SetupComplete = true
	return end	
	
	if isPlaceIdApproved(joinData.SourcePlaceId) then
		local teleportData = joinData.TeleportData
		
		if teleportData then
			local pickedMap = teleportData.Map
			print("Current map is " .. pickedMap)		
			
			print("Expected amount of players: " .. #teleportData.Players)
			
			MapHandler.init(pickedMap, teleportData.Players)
			HealthSystem = require(ServerStorage.Modules.Mains.HealthSystem).Int(MapHandler:getMap())
			
			AddMaxHP(player)
			
			return
		end
	end		

	if not RunService:IsStudio() then
		player:Kick("Game not authorized")
	end	
end

ServerStorage.Events.Economy.GiveCash.Event:Connect(function(player, amt)
	local eco = PlayersEco[player]
	
	if eco and Players:FindFirstChild(player.Name) then	
		eco:Income(math.floor(amt + 0.5))
		eco:Update(false, math.floor(amt + 0.5))
	end
end)

ServerStorage.Events.Economy.GiveCashAll.Event:Connect(function(amt, isWaveBonus)
	for plr,eco in pairs(PlayersEco) do
		eco:Income(math.floor(amt + 0.5))
		eco:Update(isWaveBonus, math.floor(amt + 0.5))
	end
end)

ServerStorage.Events.Economy.GetPlayerCash.OnInvoke = function(player)
	if PlayersEco[player] then
		return PlayersEco[player]
	end
end

ServerStorage.Events.Enemies.EnemyReachedEnd.Event:Connect(function(amt)
	HealthSystem:SubtractHP(amt)
end)

ServerStorage.Events.Game.GetCurrentHP.OnInvoke = function()
	return HealthSystem.CurrentHP
end

ServerStorage.Events.Game.GameLost.Event:Connect(function(amt)
	MapHandler.GameLost()
end)

ReplicatedStorage.Events.Setup.VoteDiff.OnServerEvent:Connect(function(player, diff)
	MapHandler:addVoteDiff(player, diff)
end)

ServerStorage.Events.PlayerAdded.Event:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoved)
