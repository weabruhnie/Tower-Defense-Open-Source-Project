local ServerStorage = game.ServerStorage
local Events = ServerStorage.Events

local Commands = {
	
	["/levelup"] = function(plr)
		Events.Level.AddPlrExp:Fire(plr, 1000)
	end,
	
	
}

return Commands
