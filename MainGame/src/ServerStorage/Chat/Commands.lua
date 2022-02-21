local Players = game:GetService("Players")

local ServerStorage = game.ServerStorage
local Events = ServerStorage.Events

local MapHandler = require(ServerStorage.Modules.MapHandler)

local WavesDatabase = require(ServerStorage.Database.Waves.WavesDatabase)

local function get_player_from_arg(s)
	s = s:lower() -- Remove this if you want case sensitivity
	for _, player in ipairs(Players:GetPlayers()) do
		if s == player.Name:lower():sub(1, #s) then
			return player
		end
	end
	return nil
end

local function concatArgs(args, seperator)
	local concat = ""
	
	if seperator == nil then seperator = "" end
	
	for i=2, #args do
		if i > 2 then
			concat = concat .. seperator .. args[i]	
		else
			concat = args[i]
		end
		
	end
	
	return concat
end

local Commands = {
	
	["/spawn"] = function(plr, args)		
		local concatEnem = concatArgs(args, " ")
			
		for _,enem in pairs(ServerStorage.Enemies:GetChildren()) do
			if enem.Name:lower() == concatEnem:lower() then
				MapHandler:SpawnEnemies(enem.Name, 1, 0, 0)
			end
		end
	end,
	
	["/cash"] = function(plr, args)
		if not args[3] then
			if tonumber(args[2]) then
				Events.Economy.GiveCash:Fire(plr, args[2])
			end	
			
			return
		end
		
		local Cash		
		if tonumber(args[3]) then
			Cash = args[3]
		end		
		
		local playerMentioned = get_player_from_arg(args[2])
		
		if playerMentioned then
			Events.Economy.GiveCash:Fire(plr, Cash)
		end
		
		return
	end,	
	
	["/wave"] = function(plr, args)
		if tonumber(args[2]) then
			WavesDatabase:Exceute(tonumber(args[2]))
		end		
	end,	
	
}

return Commands
