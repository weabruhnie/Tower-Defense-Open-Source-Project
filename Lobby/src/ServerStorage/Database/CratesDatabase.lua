local CratesDatabase = {}

CratesDatabase.Crates = {
	
	["Basic"] = {
		Order = 1,
		
		CoinCost = 300,
		
		Percentage = {
			Common = {
				Weight = 90
			},
			Uncommon = {
				Weight = 15
			},			
		}
	},
	
	["Uncommon"] = {
		Order = 2,
		
		CoinCost = 1050,
		
		Percentage = {
			Common = {
				Weight = 35
			},
			Uncommon = {
				Weight = 90
			},
			Rare = {
				Weight = 10
			},
		}
	},
	
	["Rare"] = {
		Order = 3,
		
		CoinCost = 2200,
		
		Percentage = {
			Uncommon = {
				Weight = 20
			},
			Rare = {
				Weight = 90
			},
			Epic = {
				Weight = 5
			},
		}
	},
	
	["Epic"] = {
		Order = 4,
		
		GemCost = 200,
		
		Percentage = {
			Uncommon = {
				Weight = 5
			},
			Rare = {
				Weight = 15
			},
			Epic = {
				Weight = 80
			},
			Legendary = {
				Weight = 0.1
			},
		}
	},
	
	["TEST CRATE"] = {
		Order = 5,

		CoinCost = 0,
		
		Percentage = {
			Legendary = {
				Weight = 100
			},
		}		
	},
	
}

function CratesDatabase.getOrderRarity(rarity)
	if rarity == "Common" then
		return 0
	elseif rarity == "Uncommon" then
		return 1
	elseif rarity == "Rare" then
		return 2
	elseif rarity == "Epic" then
		return 3
	elseif rarity == "Legendary" then
		return 4
	end
end

return CratesDatabase
