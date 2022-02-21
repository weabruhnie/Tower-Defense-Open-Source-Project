local MapHandler = require(game.ServerStorage.Modules.MapHandler)

local CorrodedNoob = {
	Animations = {
		Run = "rbxassetid://7598390484",
	},
	
	Sounds = {
	},
}

function CorrodedNoob.getRunAnim()
	return CorrodedNoob.Animations.Run
end

return CorrodedNoob
