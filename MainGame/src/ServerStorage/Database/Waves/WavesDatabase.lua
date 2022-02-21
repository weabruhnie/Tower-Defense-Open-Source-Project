local MapHandler = require(game.ServerStorage.Modules.MapHandler)

local Waves = {
	[1] = function()
		MapHandler:SpawnEnemies("Red Noob", 4, 2, 0)
	end,

	[2] = function()
		MapHandler:SpawnEnemies("Red Noob", 9, 2, 0)
	end,

	[3] = function()
		MapHandler:SpawnEnemies("Blue Noob", 4, 2.5, 0)
	end,
	
	[4] = function()
		MapHandler:SpawnEnemies("Red Noob", 5, 2, 0)
		MapHandler:SpawnEnemies("Blue Noob", 5, 2, 9)
	end,
	
	[5] = function()
		MapHandler:SpawnEnemies("Green Noob", 4, 2.5, 0)
	end,
	
	[6] = function()
		MapHandler:SpawnEnemies("Red Noob", 7, 2, 0)
		MapHandler:SpawnEnemies("Blue Noob", 7, 2, 10)
		MapHandler:SpawnEnemies("Green Noob", 8, 2, 20)
	end,
	
	[7] = function()
		MapHandler:SpawnEnemies("Green Noob", 9, 2, 0)
		MapHandler:SpawnEnemies("Blue Noob", 8, 2, 10)
		MapHandler:SpawnEnemies("Red Noob", 7, 2, 19)
	end,
	
	[8] = function()
		MapHandler:SpawnEnemies("Green Noob", 9, 3, 0)
		MapHandler:SpawnEnemies("Red Noob", 6, 2, 5)
		MapHandler:SpawnEnemies("Blue Noob", 12, 2, 10)			
	end,
	
	[9] = function()
		MapHandler:SpawnEnemies("Blue Pro", 1, 0, 0)	
		MapHandler:SpawnEnemies("Red Noob", 9, 2, 8)		
	end,
	
	[10] = function()
		MapHandler:SpawnEnemies("Blue Pro", 1, 0, 0)	
		MapHandler:SpawnEnemies("Green Noob", 5, 2.5, 3)
		MapHandler:SpawnEnemies("Red Noob", 6, 2, 8)
	end,
	
	[11] = function()
		MapHandler:SpawnEnemies("Camo Noob", 8, 2.5, 0)
	end,
	
	[12] = function()
		MapHandler:SpawnEnemies("Blue Pro", 1, 0, 0)
		MapHandler:SpawnEnemies("Green Noob", 8, 2, 12)
	end,
	
	[13] = function()
		MapHandler:SpawnEnemies("Camo Noob", 4, 2.5, 0)
		MapHandler:SpawnEnemies("Green Noob", 6, 2, 12)
	end,
	
	[14] = function()
		MapHandler:SpawnEnemies("Green Noob", 5, 2, 0)
		MapHandler:SpawnEnemies("Blue Pro", 2, 5, 3)
	end,
	
	[15] = function()
		MapHandler:SpawnEnemies("Yellow Noob", 9, 2, 0)
	end,
	
	[16] = function()
		MapHandler:SpawnEnemies("Blue Pro", 2, 10, 0)
		MapHandler:SpawnEnemies("Green Noob", 5, 2, 3)
		MapHandler:SpawnEnemies("Camo Noob", 5, 2, 10)
		MapHandler:SpawnEnemies("Yellow Noob", 5, 2, 15)
	end,
	
	[17] = function()
		MapHandler:SpawnEnemies("Wizard Noob", 1, 0, 0)

		MapHandler:SpawnEnemies("Green Noob", 6, 2, 3)
		MapHandler:SpawnEnemies("Camo Noob", 5, 2, 5)

		MapHandler:SpawnEnemies("Yellow Noob", 6, 2, 7)

		MapHandler:SpawnEnemies("Blue Pro", 1, 0, 20)
	end,
	
	[18] = function()
		MapHandler:SpawnEnemies("Blue Pro", 2, 7, 0)
		MapHandler:SpawnEnemies("Green Noob", 5, 3, 2)
		
		MapHandler:SpawnEnemies("Camo Noob", 6, 2, 10)
		
		MapHandler:SpawnEnemies("Yellow Noob", 7, 2, 13)
	end,
	
	[19] = function()
		MapHandler:SpawnEnemies("Yellow Noob", 20, 2, 13)
	end,
	
	[20] = function()
		MapHandler:SpawnEnemies("Tank Noob", 1, 0, 0)
		
		MapHandler:SpawnEnemies("Red Noob", 6, 2, 5)
		MapHandler:SpawnEnemies("Blue Pro", 20, 7, 15)
	end,
	
	[21] = function()
		MapHandler:SpawnEnemies("Yellow Noob", 12, 3, 0)
		MapHandler:SpawnEnemies("Green Noob", 3, 2, 5)
		
		MapHandler:SpawnEnemies("Wizard Noob", 2, 7, 15)
	end,
	
	[22] = function()
		MapHandler:SpawnEnemies("Yellow Noob", 6, 3, 0)		
		MapHandler:SpawnEnemies("Camo Noob", 17, 2, 7)
	end,
	
	[23] = function()
		MapHandler:SpawnEnemies("Yellow Noob", 6, 3, 0)
		
		MapHandler:SpawnEnemies("Wizard Noob", 1, 0, 10)
		
		MapHandler:SpawnEnemies("Tank Noob", 1, 0, 20)
	end,
	
	[24] = function()
		MapHandler:SpawnEnemies("Pink Noob", 8, 3, 0)
	end,
	
	[25] = function()
		MapHandler:SpawnEnemies("Pink Noob", 8, 3, 0)
		MapHandler:SpawnEnemies("Yellow Noob", 8, 3, 5)
		
		MapHandler:SpawnEnemies("Blue Pro", 4, 5, 12)
	end,
	
	[26] = function()
		MapHandler:SpawnEnemies("Yellow Noob", 5, 3, 0)	
		MapHandler:SpawnEnemies("Camo Pro", 1, 0, 6)	
	end,
	
	[27] = function()
		MapHandler:SpawnEnemies("Tank Noob", 1, 0, 2)
		
		MapHandler:SpawnEnemies("Green Noob", 5, 3, 6)
		
		MapHandler:SpawnEnemies("Pink Noob", 12, 3, 9)
		MapHandler:SpawnEnemies("Yellow Noob", 12, 3, 12)
	end,
	
	[28] = function()
		MapHandler:SpawnEnemies("Yellow Noob", 10, 3, 0)
		MapHandler:SpawnEnemies("Blue Pro", 4, 4, 6)
		
		MapHandler:SpawnEnemies("Camo Noob", 4, 3, 10)		
		MapHandler:SpawnEnemies("Green Noob", 5, 3, 12)
		MapHandler:SpawnEnemies("Pink Noob", 9, 3, 13)
		
		MapHandler:SpawnEnemies("Camo Pro", 1, 0, 6)
	end,
	
	[29] = function()
		MapHandler:SpawnEnemies("Pink Noob", 8, 3, 0)
		
		MapHandler:SpawnEnemies("Tank Noob", 6, 8, 2)
		MapHandler:SpawnEnemies("Camo Pro", 2, 6, 6)	
		
		MapHandler:SpawnEnemies("Wizard Noob", 1, 0, 12)
	end,
	
	[30] = function()
		MapHandler:SpawnEnemies("Camo Pro", 3, 5, 0)	
		MapHandler:SpawnEnemies("Pink Noob", 15, 3, 2)
		
		MapHandler:SpawnEnemies("Yellow Noob", 25, 3, 2)
		
		MapHandler:SpawnEnemies("Corroded Noob", 1, 0, 5)
	end,
	
	[31] = function()
		MapHandler:SpawnEnemies("Tank Noob", 6, 4, 3)
		
		MapHandler:SpawnEnemies("Pink Noob", 20, 2, 6)
		MapHandler:SpawnEnemies("Camo Pro", 5, 5, 6)	
	end,
	
	[32] = function()
		MapHandler:SpawnEnemies("Camo Pro", 3, 5, 0)
		
		MapHandler:SpawnEnemies("Corroded Noob", 1, 0, 5)	
	end,

}

function Waves:Exceute(wave)
	local f = Waves[wave]
	if f then return f() end	
end

return Waves
