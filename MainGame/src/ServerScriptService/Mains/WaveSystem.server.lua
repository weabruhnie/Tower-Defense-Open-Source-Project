local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local ServerStorage = game.ServerStorage
local ServerEvents = ServerStorage.Events

local ReplicatedStorage = game.ReplicatedStorage

local GameEvents = ServerEvents.Game

--local MaxWave = 25
local MaxWave = 20

local ForceEndRound = false

local MapHandler = require(ServerStorage.Modules.MapHandler)

local WavesDatabase = require(ServerStorage.Database.Waves.WavesDatabase)
local DialogWaves = require(ServerStorage.Database.Waves.DialogWaves)

GameEvents.GameStart.Event:Connect(function()
	local Map = MapHandler.Map
	
	local MapGameplayMusic = Map.Music.Gameplay
	
	MapGameplayMusic:Play()
	
	local Difficulty = MapHandler:getDiff()
	
	if Difficulty == "Easy" then
		MaxWave = 20
	elseif Difficulty == "Normal" then
		MaxWave = 30
	elseif Difficulty == "Hard" then
		MaxWave = 40
	elseif Difficulty == "Nightmare" then
		MaxWave = 50
	end
	
	if not RunService:IsStudio() then
		if MaxWave > 30 then
			MaxWave = 30
		end
	end

	local MapValues = MapHandler.LocalValues

	local MapTimer = MapHandler.MapTimer
	local VoteSkipRound = MapValues:WaitForChild("VoteSkipRound")
	
	for wave=1,MaxWave do
		if MapHandler.GameEnd then return end
		
		MapHandler.CurrentWave.Value = wave
		
		ServerEvents.Economy.ActivateFarms:Fire()
		
		if wave > 1 then
			ServerEvents.Economy.GiveCashAll:Fire((220 * (1.1 ^ wave)) / #Players:GetPlayers(), true)
		elseif wave > 4 then
			ServerEvents.Economy.GiveCashAll:Fire((230 * (1.125 ^ wave)) / #Players:GetPlayers(), true)
		elseif wave > 9 then
			ServerEvents.Economy.GiveCashAll:Fire((240 * (1.15 ^ wave)) / #Players:GetPlayers(), true)	
		elseif wave > 14 then
			ServerEvents.Economy.GiveCashAll:Fire((250 * (1.175 ^ wave)) / #Players:GetPlayers(), true)	
		elseif wave > 19 then
			ServerEvents.Economy.GiveCashAll:Fire((260 * (1.2 ^ wave)) / #Players:GetPlayers(), true)	
		end
		
		if wave > 0 then
			MapHandler.Timer = 60
		elseif wave >= 20 then
			MapHandler.Timer = 80
		elseif wave >= 30 then
			MapHandler.Timer = 90		
		end
		
		if wave == 30 then
			MapHandler.Timer = 9000
		end
		
		local timerConnection
		
		coroutine.wrap(function()
			if DialogWaves[wave] then
				for dialogNum, dialog in pairs(DialogWaves[wave]) do
					MapHandler:DialogPlayers(dialog[1], dialog[2], dialog[3])
				end
			end
		end)()		
		
		local VotingConnection
		
		timerConnection = RunService.Heartbeat:Connect(function(step)
			if MapHandler.GameEnd then timerConnection:Disconnect() end
			
			MapHandler.Timer -= step
			MapTimer.Value = math.floor(MapHandler.Timer)
			
			if MapHandler.Timer <= 20 and MapHandler.CurrentWave.Value < MaxWave then
				local votedAmt = 0
				local votedNeeded = #Players:GetPlayers() > 1 and #Players:GetPlayers() - 1 or 1
				
				local PlayerVoted = {}
				
				VoteSkipRound.Value = true
				
				VotingConnection = ReplicatedStorage.Events.Players.VoteActivate.OnServerEvent:Connect(function(player)
					if MapHandler.GameEnd then return end
					
					if PlayerVoted[player] then return end
					
					PlayerVoted[player] = true
					votedAmt += 1

					ReplicatedStorage.Events.Players.VoteActivate:FireAllClients(#PlayerVoted)

					if votedAmt >= votedNeeded then
						ForceEndRound = true
						timerConnection:Disconnect()
						VotingConnection:Disconnect()
					end
				end)
			end
			
			if MapHandler.Timer <= 0 then				
				ForceEndRound = true
				timerConnection:Disconnect()
			end			
		end)
		
		WavesDatabase:Exceute(wave)
		
		repeat wait() until MapHandler.EnemyCount == 0 or ForceEndRound
		
		VoteSkipRound.Value = false
		
		ForceEndRound = false
		
		if timerConnection then timerConnection:Disconnect() end
		
		if MapHandler.GameEnd then return end
	end
	
	if ServerStorage.Events.Game.GetCurrentHP:Invoke() > 0 then
		print("WON")
	end
end)