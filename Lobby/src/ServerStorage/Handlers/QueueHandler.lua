local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local RunService = game:GetService("RunService")

local Events = game.ReplicatedStorage.Events

local ServerEvents = game.ServerStorage.Events

local Zone = require(game.ServerStorage.Modules.Zone)

local MapsDatabase = require(game.ServerStorage.Database.MapsDatabase)

local QueueHandler = {}

local MainGameID = 7455490966

function QueueHandler.assign(area)
	local self = {}
	
	self.CurrentMap = nil
	
	area.Countdown.CanCollide = false
	
	self.data = {
		CurrentPlayers = {},
		Countdown = false,
		Timeleft = 15
	}	
	
	local mapSwitchConnect
	
	local mapSwitchTimer = 0
	
	mapSwitchConnect = RunService.Heartbeat:Connect(function(dt_scale)
		mapSwitchTimer -= dt_scale
		
		if mapSwitchTimer <= 0 then
			mapSwitchTimer = 40
			
			if #self.data.CurrentPlayers <= 0 then
				local maps = {}

				for k in pairs(MapsDatabase.Maps) do -- `k` will be "Hat1", then "Hat2", then "Hat3"
					table.insert(maps, k) -- put them all into the `keys` array
				end

				if #maps == 0 then return end

				local mapName = maps[math.random(1,#maps)] 	
				
				local mapData = MapsDatabase.Maps[mapName]
				
				self.CurrentMap = mapName
				
				area.Board.SurfaceGui.TextLabel.Text = mapName
				area.EnterArea.SurfaceGui.ImageLabel.Image = mapData.Thumbnail
			end
		end
	end)
	
	local function Restart()
		area.Countdown.SurfaceGui.TextLabel.Text = self.data.Timeleft
		self.data.CurrentPlayers = {}
	end

	local function GameStart()
		if #self.data.CurrentPlayers <= 0 then return end

		print("teleporing...")
		
		local playerNameList = {}
		
		for i,plr in pairs(self.data.CurrentPlayers) do
			table.insert(playerNameList, plr.Name)
			ServerEvents.Queues.Teleporting:Fire(plr)
		end
		
		local teleportData = {
			Map = self.CurrentMap,
			Players = playerNameList
		}
		
		pcall(function()
			local reservedCode = TeleportService:ReserveServer(MainGameID)
			TeleportService:TeleportToPrivateServer(MainGameID,reservedCode,self.data.CurrentPlayers, nil, teleportData) -- Actually teleport the players
		end)		
		
		Restart()
	end
	
	local function StartCountdown()
		if self.data.Countdown then return end

		print("countdown started")

		self.data.Countdown = true

		coroutine.wrap(function()
			for i=self.data.Timeleft,0,-1 do
				area.Countdown.SurfaceGui.TextLabel.Text = i
				
				if not self.data.Countdown then
					break
				end

				if i == 0 then					
					self.data.Countdown = false					
					if #self.data.CurrentPlayers <= 0 then break end
					
					area.Countdown.SurfaceGui.TextLabel.Text = "Starting..."
					
					GameStart()
				end

				wait(1)
			end
			
			Restart()
		end)()
	end
	
	function self.PlayerLeave(player)
		local IsPlayerTpt = ServerEvents.Queues.IsPlayerTpt:Invoke(player)
		
		if IsPlayerTpt then return end
		
		local foundPlr = table.find(self.data.CurrentPlayers, player)
		
		if foundPlr then
			table.remove(self.data.CurrentPlayers, foundPlr)
			
			player.Character.HumanoidRootPart.CFrame = area.Floor.CFrame + Vector3.new(0,2,15)
		end
		
		if #self.data.CurrentPlayers <= 0 then
			self.data.Countdown = false
		end	
	end
	
	local zone = Zone.new(area)

	self.touchedConnect = zone.playerEntered:Connect(function(player)	
		local isPlayerExistQueue = ServerEvents.Queues.CheckIfPlayerDuplicate:Invoke(player)
		
		local IsPlayerTpt = ServerEvents.Queues.IsPlayerTpt:Invoke(player)
		
		if isPlayerExistQueue or IsPlayerTpt then return end

		--if self.data.Countdown then
		--	if #self.data.CurrentPlayers <= 0 then
		--		self.data.Countdown = false
		--	end			
		--	return
		--end

		if #self.data.CurrentPlayers <= 4 then
			if table.find(self.data.CurrentPlayers, player) then return end

			table.insert(self.data.CurrentPlayers, player)				
			player.Character.HumanoidRootPart.CFrame = area.Floor.CFrame + Vector3.new(0,2,0)

			Events.Queues.PlayerEntered:FireClient(player, area)

			if #self.data.CurrentPlayers > 0 then
				StartCountdown()
			end
		else
			return false
		end

	end)
	
	return self
end

return QueueHandler
