local Players = game:GetService("Players") -- get the service Players to handle players joining and leaving
local RunService = game:GetService("RunService") -- Will be used to check if the game is running in studio 

local ServerStorage = game.ServerStorage -- Making variables out of container for easier access
local ReplicatedStorage = game.ReplicatedStorage

ServerStorage.Database:Clone().Parent = ReplicatedStorage -- Cloning the database from ServerStorage into ReplicatedStorage (for safety measures)
ServerStorage.UnitSkins:Clone().Parent = ReplicatedStorage -- Same as above

local EcoHandler = require(ServerStorage.Modules.Players.EcoHandler) -- Requiring prebuilt modules in-game to handle cash
local MapHandler = require(ServerStorage.Modules.MapHandler) -- Requiring prebuilt modules in-game to handle and create map for the game

local isReserved = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0 -- Check if this game is a Private server or not

local SetupComplete = false -- Boolean to check if the game is already setup

local approvedPlaceIds = {
	7455490966,
	7455388318
} -- insert approved PlaceIds here

local PlayersEco = {} -- Store each player economy in here

local function isPlaceIdApproved(placeId) -- function
	for _, id in pairs(approvedPlaceIds) do -- loop through each id from table approvedPlaceIds 
		if id == placeId then -- to check if the place is approved in the table approvedPlaceIds
			return true -- it is approved, return true to the caller
		end
	end
	return false -- nope, return false to the caller
end

function playerAdded(player) -- function starts when player joined the game
	if not isReserved then -- if the game is not private
		if not RunService:IsStudio() then -- if this is running on the studio, the code inside should be ignored
			player:Kick("Game not authorized") -- kick the player if the player is not private and not in studio
		end	
	end
	
	if not PlayersEco[player] then -- check if player economy already exists in the dictionary		
		PlayersEco[player] = EcoHandler.int(player)  -- if not, calling the required module script to make a new one (it should return a table with functions stored in the dict)
	end	
	
	GameSetup(player) -- setup the game with the first player
end

function playerRemoved(player) -- function plays when player leave the game
	if PlayersEco[player] then -- if player economy exists in the dictionary...
		print("player left") -- console log that text
		PlayersEco[player] = nil -- remove or make the player eco non-existent (since they are no longer here)
	end	
end

local HealthSystem -- variable declared nil, will be used later

function AddMaxHP(plr)
	if not HealthSystem then return end -- if the health system didn't exist yet
	
	local plr_Data = ServerStorage.Events.Saves.RequestPlayerData:Invoke(plr) -- Requesting the datastore of the player through BindableFunction (should return player data dictionary)

	if plr_Data then -- if the data receive was a success
		HealthSystem:IncreaseMaxHP(plr, plr_Data.Level) -- increment the hp of the map by the player level in data
	end
end

function GameSetup(player)	-- refer to the call before, function starting the game
	if SetupComplete then -- if the boolean is already true or the game is already setup
		AddMaxHP(player) -- just add the max hp from player data
	return end -- then skip this whole process below
	
	SetupComplete = true -- sets this bool to true, only one player will be able to go through this process
	
	local joinData = player:GetJoinData() -- since I used teleportservice with teleportData from previous place, I'm getting the join data from the player first
	
	if RunService:IsStudio() then -- Except, if this is from studio, we are going to pick the map manually.
		local pickedMap = "Grasslands"
		print("Current map is " .. pickedMap)	
		
		MapHandler.init(pickedMap) -- Pick the Grasslands Map and create it in workspace (through module script ofc)
		HealthSystem = require(ServerStorage.Modules.Mains.HealthSystem).Int(MapHandler:getMap()) -- Implementing the health bar into the map (through module script)
		
		AddMaxHP(player) -- add the max hp from player data
	return end	-- No more since the below handles the real Roblox server
	
	if isPlaceIdApproved(joinData.SourcePlaceId) then -- check if the previous place from the player started teleporting belong to ours
		local teleportData = joinData.TeleportData -- we get the teleport data
		
		if teleportData then -- if it does exist
			local pickedMap = teleportData.Map -- we will pick the map from the teleportData
			print("Current map is " .. pickedMap) -- alert the map
			
			print("Expected amount of players: " .. #teleportData.Players) -- the teleportData includes a table of Players name that are expect to be here, this prints the number of players in that table
			
			MapHandler.init(pickedMap, teleportData.Players) -- Start the map selected in teleportData with the expected players table
			HealthSystem = require(ServerStorage.Modules.Mains.HealthSystem).Int(MapHandler:getMap()) -- Implementing the health bar into the map like above
			
			AddMaxHP(player) -- add the max hp from player data
			
			return -- we don't want to kick the player from below since the function works
		end
	end		

	if not RunService:IsStudio() then -- this is where everything above didn't work as intended. Check if the game was not in studio first
		player:Kick("Game not authorized") -- Bye bye player
	end	
end

ServerStorage.Events.Economy.GiveCash.Event:Connect(function(player, amt) -- This is the event that could be called from a different script to give the cash to player remotely
	local eco = PlayersEco[player] -- getting player eco from argument
	
	if eco and Players:FindFirstChild(player.Name) then	 -- if the player eco exists and player still exists in the game
	-- using module script to give cash
		eco:Income(math.floor(amt + 0.5)) -- round the amount, make sure it's not in decimal
		eco:Update(false, math.floor(amt + 0.5)) -- i remember this should update the player local perspective, i forgot what the 1st argument means
		return true -- success
	end

	return false -- failed to work
end)

ServerStorage.Events.Economy.GiveCashAll.Event:Connect(function(amt, isWaveBonus) -- Same as the event that give cash, but all to everyone now
	for plr,eco in pairs(PlayersEco) do
		eco:Income(math.floor(amt + 0.5)) -- round up the cash receive, avoid decimals
		eco:Update(isWaveBonus, math.floor(amt + 0.5)) -- prob update the player local perspective
	end
end)

ServerStorage.Events.Economy.GetPlayerCash.OnInvoke = function(player) -- Get player cash from bindablefunction remotely for other scripts
	if PlayersEco[player] then
		return PlayersEco[player] -- if the player eco availables, return the cash
	end

	return nil -- if not, nill
end

ServerStorage.Events.Enemies.EnemyReachedEnd.Event:Connect(function(amt) -- if the enemy reached the end of the tower defense map, this event should be called from a different script
	HealthSystem:SubtractHP(amt) -- minus the hp of the base
end)

ServerStorage.Events.Game.GetCurrentHP.OnInvoke = function() -- gets the current health of the base
	return HealthSystem.CurrentHP
end

ServerStorage.Events.Game.GameLost.Event:Connect(function(amt) -- called when the game is lost and hp is 0 (called from a different script)
	MapHandler.GameLost() -- this is when i dont realize require module script between scripts can still share the same content.
end)

ReplicatedStorage.Events.Setup.VoteDiff.OnServerEvent:Connect(function(player, diff) -- voting difficulty at the start event
	MapHandler:addVoteDiff(player, diff) -- when a player vote, it adds to that difficulty (from a different module script)
end)

ServerStorage.Events.PlayerAdded.Event:Connect(playerAdded) -- Player joined game connect to function playerAdded
Players.PlayerRemoving:Connect(playerRemoved) -- Player leaving game connect to function playerRemoved
