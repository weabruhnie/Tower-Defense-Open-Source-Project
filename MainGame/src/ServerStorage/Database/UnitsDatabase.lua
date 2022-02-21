local HttpService = game:GetService("HttpService")

local UnitsDatabase = {}

UnitsDatabase.Units = {
	["Handgunner"] = {
		Description = "Basic ranged single target damage dealer.",

		isOnMarket = true,

		MarketPrice = 0,
		Cost = 200, -- default

		Type = "Ground",

		Mode = "Semi",

		Upgrades = {
			[1] = {
				Cost = 0,

				Stats = {
					ATK = 1, -- attack
					RNG = 10, -- range
					SPD = 1.5, -- attack speed (SECOND PER ATTACK)
				}
			},

			[2] = {
				Cost = 100,

				Stats = {
					ATK = 1, -- attack
					RNG = 13, -- range
					SPD = 1.5, -- attack speed (SECOND PER ATTACK)
				}
			},

			[3] = {
				Cost = 250,

				Stats = {
					ATK = 2, -- attack
					RNG = 13, -- range
					SPD = 1.5, -- attack speed (SECOND PER ATTACK)
				},

				CamoDetection = true
			},

			[4] = {
				Cost = 700,

				Stats = {
					ATK = 4, -- attack
					RNG = 13, -- range
					SPD = 1.5, -- attack speed (SECOND PER ATTACK)
				}
			},

			[5] = {
				Cost = 1200,

				Stats = {
					ATK = 5, -- attack
					RNG = 15, -- range
					SPD = 0.75, -- attack speed (SECOND PER ATTACK)
				}
			},
		},	
	},

	["Farm"] = {
		Description = "Make money!",

		isOnMarket = true,

		MarketPrice = 1250,
		Cost = 300, -- default

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

	["Soldier"] = {
		Description = "Burst-type ranged damage dealer.",

		isOnMarket = true,

		MarketPrice = 500,
		Cost = 400, -- default

		Type = "Ground",

		Mode = "Burst",

		Upgrades = {
			[1] = {
				Cost = 0,

				Stats = {
					ATK = 2, -- attack
					RNG = 14, -- range
					SPD = 1.2, -- attack speed (SECOND PER ATTACK)
					BurstRate = 0.2,
					BurstAmount = 3
				}
			},

			[2] = {
				Cost = 200,

				Stats = {
					ATK = 3, -- attack
					RNG = 14, -- range
					SPD = 1.2, -- attack speed (SECOND PER ATTACK)
					BurstRate = 0.2,
					BurstAmount = 3
				}
			},

			[3] = {
				Cost = 400,

				Stats = {
					ATK = 4, -- attack
					RNG = 16, -- range
					SPD = 1.2, -- attack speed (SECOND PER ATTACK)
					BurstRate = 0.2,
					BurstAmount = 3
				},

				CamoDetection = true
			},

			[4] = {
				Cost = 1000,

				Stats = {
					ATK = 10, -- attack
					RNG = 18, -- range
					SPD = 1.5, -- attack speed (SECOND PER ATTACK)
					BurstRate = 0.2,
					BurstAmount = 5
				}
			},

			[5] = {
				Cost = 2500,

				Stats = {
					ATK = 24, -- attack
					RNG = 20, -- range
					SPD = 1.5, -- attack speed (SECOND PER ATTACK)
					BurstRate = 0.15,
					BurstAmount = 5
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