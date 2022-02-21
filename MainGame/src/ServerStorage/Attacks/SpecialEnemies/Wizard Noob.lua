local MapHandler = require(game.ServerStorage.Modules.MapHandler)

local WizardNoob = {
	Animations = {
		Run = "rbxassetid://7582279905",
		Summon = "rbxassetid://7583362124"
	},

	Sounds = {
		Summon = "rbxassetid://4821655065"
	}
}

function WizardNoob.getRunAnim()
	return WizardNoob.Animations.Run
end

function WizardNoob.getCooldownSpecial()
	return 45
end

function WizardNoob.Special(controller)
	controller:ManualAnim(WizardNoob.Animations.Summon)
	controller:ManualSound(WizardNoob.Sounds.Summon)
	
	MapHandler:SpawnEnemies("Red Noob", math.random(3,5), 3.5, 0, controller)
	MapHandler:SpawnEnemies("Blue Noob", math.random(3,5), 3.5, 5, controller)
	MapHandler:SpawnEnemies("Green Noob", math.random(2,3), 4, 7, controller)
end



return WizardNoob
