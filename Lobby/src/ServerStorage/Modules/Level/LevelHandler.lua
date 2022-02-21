local LevelHandler = {}

function LevelHandler.getNextLvlExp(level)
	return 0.04 * (level ^ 3) + 0.8 * (level ^ 2) + 2 * level
end

function LevelHandler.AddExp(plr_profile, requestedEXP)	
	if plr_profile and plr_profile.Level and plr_profile.CurrentEXP and requestedEXP then
		
		plr_profile.CurrentEXP += requestedEXP
		
		while plr_profile.CurrentEXP >= LevelHandler.getNextLvlExp(plr_profile.Level) do
			local LeftOverExp = plr_profile.CurrentEXP - LevelHandler.getNextLvlExp(plr_profile.Level)

			plr_profile.Level += 1			
			plr_profile.CurrentEXP = 0

			print("You leveled up to level " .. plr_profile.Level)

			plr_profile.CurrentEXP += LeftOverExp
		end	
	end
end

return LevelHandler
