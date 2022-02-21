local MapHandler = require(game.ServerStorage.Modules.MapHandler)

local DialogWaves = { -- dialog after the wave 
	[1] = {
		{"Weabonie", "Welcome to Noob Tower Defense Revive!", 4},
		
		{"Weabonie", "This game is still in early development, so bugs are expected.", 5},
	},
	
	[2] = {
		{"Weabonie", "Well done completing the first wave! But, you still got a long way to go.", 5}
	},
	
	[3] = {
		{"Weabonie", "Introducing the Blue Noob. They are more faster, but easy to kill.", 5}
	},
	
	[5] = {
		{"Weabonie", "Introducing the Green Noob. They are alot much slower, but they are more tankier!", 5}
	},
	
	[7] = {
		{"Weabonie", "Uhh... I have bad news for y'all... A boss will be spawned on round 9!", 5},
	},
	
	[8] = {
		{"Weabonie", "Reminder: First boss spawns on wave 9", 4}
	},
	
	[9] = {
		{"Weabonie", "First boss! Oh my, it's Blue Pro! Destroy it before it reaches the end!", 5}
	},
	
	[11] = {
		{"Weabonie", "Another new enemy. Watch out, this Camo Noob requires your unit to have camo detection! Only a few units have these perks.", 8}
	},
	
	[15] = {
		{"Weabonie", "Watch out! they are bringing more tougher enemies. Yellow Noob is even tankier!", 5}
	},
	
	[17] = {
		{"Weabonie", "Wait... Is that a wizard? It's Wizard Noob! Beware that it can summon other foes, so kill it quickly!", 6}
	},
	
	[19] = {
		{"Weabonie", "Notice: The next round (20) will be the last round for Easy Mode.", 6},
	},
	
	[20] = {
		{"Weabonie", "I have a bad feeling about this round... ", 4.5},
		{"Weabonie", "Yep! The feeling is real! STRONG BOSS INCOMING! IT'S TANK NOOB.", 6},
	},
	
	[21] = {
		{"Weabonie", "Phew! Good job staying alive!", 5},
	},
	
	[24] = {
		{"Weabonie", "Watch out! Very quick Pink Noobs incoming! We should have someone to slow these down!", 6},
	},
	
	[26] = {
		{"Weabonie", "Oh it's the Camos- Wait, this is a HUGE one! You better be prepared with camo detection...", 6},
	},
	
	[29] = {
		{"Weabonie", "Next round, there will be another incoming boss and this will be the last round for Normal Difficulty. Good luck!", 8},
	},
	
	[30] = {
		{"Weabonie", "There it is, the Corroded Noob. This sounds bizzare but, we have to beat it! So good luck to you guys!", 9},
	},
	
	[31] = {
		{"Weabonie", "Omg... You beat the Corroded Noob!", 5},
		{"Weabonie", "But, it's not over yet...", 6},
	},
}

return DialogWaves
