local Events = game.ReplicatedStorage.Events

local ServerEvents = game.ServerStorage.Events

local Players = game:GetService("Players")

local CollectionService = game:GetService("CollectionService")

local ServerStorage = game:GetService("ServerStorage")

ServerStorage.Database:Clone().Parent = game.ReplicatedStorage
ServerStorage.UnitSkins:Clone().Parent = game.ReplicatedStorage

local TeleportingPlayers = {}

function SetupQueue(area)
	return require(ServerStorage.Handlers.QueueHandler).assign(area)
end

function UnsetQueue(data)
	data.touchedConnect:Disconnect()
end

-- adding tags

for _,area in pairs(workspace.Lobby.Queues:GetChildren()) do
	if area.Name == "QueueArea" then
		CollectionService:AddTag(area, "QueueArea")
	end
end

local QueueAreas = {}

local function AddedQueue(area)
	QueueAreas[area] = SetupQueue(area)
end

local function RemovedQueue(area)
	if QueueAreas[area] then
		UnsetQueue(QueueAreas[area])
		QueueAreas[area] = nil
	end		
end

for _,brick in pairs(CollectionService:GetTagged("QueueArea")) do
	AddedQueue(brick)
end

CollectionService:GetInstanceAddedSignal("QueueArea"):Connect(AddedQueue)
CollectionService:GetInstanceRemovedSignal("QueueArea"):Connect(RemovedQueue)

Events.Queues.PlayerLeaving.OnServerEvent:Connect(function(player, area)
	for k,data in pairs(QueueAreas) do
		if k == area then
			data.PlayerLeave(player)
		end
	end
end)

ServerEvents.Queues.CheckIfPlayerDuplicate.OnInvoke = function(player)
	for k,v in pairs(QueueAreas) do
		if table.find(v.data.CurrentPlayers, player) then
			return true
		end
	end
	
	return false
end

ServerEvents.Queues.Teleporting.Event:Connect(function(plr)
	if not table.find(TeleportingPlayers, plr) then
		table.insert(TeleportingPlayers, plr)
	end
end)

ServerEvents.Queues.IsPlayerTpt.OnInvoke = function(plr)
	if table.find(TeleportingPlayers, plr) then
		return true
	end
	
	return false
end

Players.PlayerRemoving:Connect(function(player)
	local foundPlrTpt = table.find(TeleportingPlayers, player)
	
	if foundPlrTpt then
		table.remove(TeleportingPlayers, foundPlrTpt)
	end
end)