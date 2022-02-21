local Einar = {
	Animations = {
		Idle1 = "rbxassetid://7494018825",
		
		Attack1 = "rbxassetid://7494213893",
		Attack2 = "rbxassetid://7494256677",
		Attack3 = "rbxassetid://7494479860"
		
	},
	
	Sounds = {
		Attack1 = "rbxassetid://935843979",
	}
}

local UpgradeFolder = game.ServerStorage.UnitSkins.Einar

function Einar.getTargetType(upgrade_level)
	if upgrade_level >= 2 then
		return "AOE"
	end
	
	return "Single"
end

function Einar.isCamo(upgrade_level)
	if upgrade_level >= 3 then
		return true
	end
	
	return false
end

function Einar.updateCharacter(upgrade_level, unit_skin)	
	return UpgradeFolder[unit_skin]["1"]
end

function Einar.Idle(upgrade_level)
	return Einar.Animations.Idle1
end

function Einar.Attack(upgrade_level)
	if upgrade_level == 2 or upgrade_level == 3 then
		return Einar.Animations.Attack2
	elseif upgrade_level == 4 then
		return Einar.Animations.Attack3
	end
	
	return Einar.Animations.Attack1
end

function Einar.PlaySound(upgrade_level)
	return Einar.Sounds.Attack1, nil, nil, nil, 0.25
end

return Einar