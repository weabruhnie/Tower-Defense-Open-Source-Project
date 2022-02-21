local Farm = {
	Animations = {	
	},

	Sounds = {
		Cashout = "rbxassetid://7470273637"
	}
}

local UpgradeFolder = game.ServerStorage.UnitSkins.Farm

function Farm.updateCharacter(upgrade_level, unit_skin)
	return UpgradeFolder[unit_skin][upgrade_level]
end

function Farm.getTargetType(upgrade_level)
	--if upgrade_level == 3 then
	--	return "AOE"
	--end

	return "Single"
end

function Farm.isCamo(upgrade_level)
	return false
end

function Farm.PlaySound(upgrade_level)
	return Farm.Sounds.Cashout
end


return Farm
