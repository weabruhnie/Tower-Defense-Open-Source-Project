local HttpService = game:GetService("HttpService")

local UnitsDatabase = {}

UnitsDatabase.Units = {
	["Noob"] = {
		Description = "Basic close range single target damage dealer.",

		isOnMarket = false,

		MarketPrice = 0,
		Cost = 200, -- default

		Type = "Ground",

		Mode = "Semi",

		Upgrades = {
			[1] = {
				Cost = 0,

				Stats = {
					ATK = 2, -- attack
					RNG = 5, -- range
					SPD = 3, -- attack speed (SECOND PER ATTACK)
				}
			},

			[2] = {
				Cost = 100,

				Stats = {
					ATK = 3, -- attack
					RNG = 7, -- range
					SPD = 3, -- attack speed (SECOND PER ATTACK)
				}
			},

			[3] = {
				Cost = 400,

				Stats = {
					ATK = 6, -- attack
					RNG = 9, -- range
					SPD = 2, -- attack speed (SECOND PER ATTACK)
				}
			},

		}
	},

	["Gunner"] = {
		Description = "Basic ranged single target damage dealer.",

		isOnMarket = true,

		MarketPrice = 300,
		Cost = 300, -- default

		Type = "Ground",

		Mode = "Semi",

		Upgrades = {
			[1] = {
				Cost = 0,

				Stats = {
					ATK = 1, -- attack
					RNG = 7, -- range
					SPD = 1.5, -- attack speed (SECOND PER ATTACK)
				}
			},

			[2] = {
				Cost = 50,

				Stats = {
					ATK = 1, -- attack
					RNG = 9, -- range
					SPD = 1.5, -- attack speed (SECOND PER ATTACK)
				}
			},

			[3] = {
				Cost = 100,

				Stats = {
					ATK = 2, -- attack
					RNG = 12, -- range
					SPD = 1.5, -- attack speed (SECOND PER ATTACK)
				},

				CamoDetection = true
			},

			[4] = {
				Cost = 500,

				Stats = {
					ATK = 5, -- attack
					RNG = 12, -- range
					SPD = 0.75, -- attack speed (SECOND PER ATTACK)
				}
			},

			[5] = {
				Cost = 600,

				Stats = {
					ATK = 7, -- attack
					RNG = 15, -- range
					SPD = 0.75, -- DPS: 9
				}
			},

		},	
	},

	["Swordman"] = {
		Description = "Basic damage dealer capable of AOE and Bleed.",

		isOnMarket = true,

		MarketPrice = 500,
		Cost = 400, -- default

		Type = "Ground",

		Mode = "Semi",

		Upgrades = {
			[1] = {
				Cost = 0,

				Stats = {
					ATK = 4, -- attack
					RNG = 6.5, -- range
					SPD = 4, -- attack speed (SECOND PER ATTACK)
				}
			},

			[2] = {
				Cost = 250,

				Stats = {
					ATK = 6, -- attack
					RNG = 6.5, -- range
					SPD = 3.75, -- attack speed (SECOND PER ATTACK)
				}
			},

			[3] = {
				Cost = 500,

				Stats = {
					ATK = 10, -- attack
					RNG = 7.2, -- range
					SPD = 3.5, -- attack speed (SECOND PER ATTACK)
				}
			},

			[4] = {
				Cost = 1000,

				Stats = {
					ATK = 16, -- attack
					RNG = 8, -- range
					SPD = 3, -- DPS: 5.3
				}
			},

		},	
	},

	["Soldier"] = {
		Description = "Burst-type ranged damage dealer.",

		isOnMarket = true,

		MarketPrice = 500,
		Cost = 450, -- default

		Type = "Ground",

		Mode = "Burst",

		Upgrades = {
			[1] = {
				Cost = 0,

				Stats = {
					ATK = 1, -- attack
					RNG = 11, -- range
					SPD = 1.2, -- attack speed (SECOND PER ATTACK)
					BurstRate = 0.3,
					BurstAmount = 3
				}
			},

			[2] = {
				Cost = 250,

				Stats = {
					ATK = 1, -- attack
					RNG = 13, -- range
					SPD = 1.2, -- attack speed (SECOND PER ATTACK)
					BurstRate = 0.3,
					BurstAmount = 3
				}
			},

			[3] = {
				Cost = 500,

				Stats = {
					ATK = 1, -- attack
					RNG = 16, -- range
					SPD = 1.1, -- attack speed (SECOND PER ATTACK)
					BurstRate = 0.3,
					BurstAmount = 3
				},

				CamoDetection = true
			},

			[4] = {
				Cost = 1250,

				Stats = {
					ATK = 2, -- attack
					RNG = 18, -- range
					SPD = 0.85, -- attack speed (SECOND PER ATTACK)
					BurstRate = 0.2,
					BurstAmount = 4
				}
			},

			[5] = {
				Cost = 2500,

				Stats = {
					ATK = 4, -- attack
					RNG = 22, -- range
					SPD = 0.85, -- attack speed (SECOND PER ATTACK)
					BurstRate = 0.15,
					BurstAmount = 5
				}
			},

		}
	},

	["Snoobper"] = {
		Description = "Specialized long ranged damage dealer. Every upgrade further increases its range and offensive abilities.",

		isOnMarket = true,

		MarketPrice = 750,
		Cost = 400, -- default

		PlaceLimit = 10,

		Type = "Air",

		Mode = "Semi",

		Upgrades = {
			[1] = {
				Cost = 0,

				Stats = {
					ATK = 10, -- attack
					RNG = 25, -- range
					SPD = 6, -- attack speed (SECOND PER ATTACK)
				}
			},

			[2] = {
				Cost = 500,

				Stats = {
					ATK = 15, -- attack
					RNG = 28, -- range
					SPD = 5.5, -- attack speed (SECOND PER ATTACK)
				},

				CamoDetection = true
			},

			[3] = {
				Cost = 1050,

				Stats = {
					ATK = 20, -- attack
					RNG = 35, -- range
					SPD = 5, -- attack speed (SECOND PER ATTACK)
				}
			},

			[4] = {
				Cost = 1750,

				Stats = {
					ATK = 30, -- attack
					RNG = 45, -- range
					SPD = 4.5, -- attack speed (SECOND PER ATTACK)
				}
			},

		}
	},	

	["Heavy Noob"] = {
		Description = "A M60-wielded unit that has an insane fire rate.",

		isOnMarket = true,

		MarketPrice = 3500,
		Cost = 2000, -- default

		PlaceLimit = 10,

		Type = "Ground",

		Mode = "Semi",

		Upgrades = {
			[1] = {
				Cost = 0,

				Stats = {
					ATK = 1, -- attack
					RNG = 15, -- range
					SPD = 0.15, -- attack speed (SECOND PER ATTACK)
				}
			},

			[2] = {
				Cost = 600,

				Stats = {
					ATK = 1, -- attack
					RNG = 17, -- range
					SPD = 0.1, -- attack speed (SECOND PER ATTACK)
				}
			},

			[3] = {
				Cost = 950,

				Stats = {
					ATK = 1, -- attack
					RNG = 19, -- range
					SPD = 0.1, -- attack speed (SECOND PER ATTACK)
				},

				CamoDetection = true
			},

			[4] = {
				Cost = 4000,

				Stats = {
					ATK = 2, -- attack
					RNG = 19, -- range
					SPD = 0.05, -- attack speed (SECOND PER ATTACK)
				}
			},

			[5] = {
				Cost = 10000,

				Stats = {
					ATK = 4, -- attack
					RNG = 21, -- range
					SPD = 0.05, -- attack speed (SECOND PER ATTACK)
				}
			},

		}
	},


	["Einar"] = {
		Description = "E7-Inspired swordman.",

		isOnMarket = true,

		MarketPrice = 5000,
		Cost = 1250, -- default

		PlaceLimit = 8,

		Type = "Ground",

		Mode = "Semi",

		Upgrades = {
			[1] = {
				Cost = 0,

				Stats = {
					ATK = 10, -- attack
					RNG = 6, -- range
					SPD = 2, -- attack speed (SECOND PER ATTACK)
				}
			},

			[2] = {
				Cost = 1250,

				Stats = {
					ATK = 20, -- attack
					RNG = 6, -- range
					SPD = 2, -- attack speed (SECOND PER ATTACK)
				}
			},

			[3] = {
				Cost = 2500,

				Stats = {
					ATK = 50, -- attack
					RNG = 8, -- range
					SPD = 2, -- attack speed (SECOND PER ATTACK)
				},

				CamoDetection = true
			},

			[4] = {
				Cost = 5000,

				Stats = {
					ATK = 125, -- attack
					RNG = 14, -- range
					SPD = 4, -- attack speed (SECOND PER ATTACK)
				}
			},

		}
	},

	["Farm"] = {
		Description = "Make money!",

		isOnMarket = true,

		MarketPrice = 1250,
		Cost = 250, -- default

		PlaceLimit = 8,

		Type = "Ground",

		Mode = "Farm",

		Upgrades = {
			[1] = {
				Cost = 0,

				Stats = {
					ATK = 75, -- (money per round)
					RNG = 7,
					SPD = 0, 
				}
			},

			[2] = {
				Cost = 200,

				Stats = {
					ATK = 150, -- (money per round)
					RNG = 7,
					SPD = 0, 
				}
			},

			[3] = {
				Cost = 500,

				Stats = {
					ATK = 250, -- (money per round)
					RNG = 7,
					SPD = 0, 
				}
			},

			[4] = {
				Cost = 1000,

				Stats = {
					ATK = 500, -- (money per round)
					RNG = 7,
					SPD = 0, 
				}
			},
			
			[5] = {
				Cost = 2500,

				Stats = {
					ATK = 1250, -- (money per round)
					RNG = 7,
					SPD = 0, 
				}
			},


		}
	},
}

function UnitsDatabase.find(unit)
	for k,v in pairs(UnitsDatabase.Units) do
		if k == unit then
			return v
		end
	end

	return false
end

return UnitsDatabase