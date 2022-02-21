local MapHandler = require(game.ServerStorage.Modules.MapHandler)

local TankNoob = {
	Animations = {
		Run = "rbxassetid://7588935771",
	},

	Sounds = {
	}
}

function TankNoob.getRunAnim()
	return TankNoob.Animations.Run
end


return TankNoob
