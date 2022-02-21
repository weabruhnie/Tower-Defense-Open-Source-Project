local Noob = {
	Animations = {
		Idle1 = "rbxassetid://7461532219",	
		
		Attack1 = "rbxassetid://7469890570",
		Attack2 = "rbxassetid://7476201567"		
	},
	
	Sounds = {
		Attack1 = "rbxassetid://281156569",
		Attack2 = "rbxassetid://332918363"
	}
}

local UpgradeFolder = game.ServerStorage.UnitSkins.Noob

function Noob.getTargetType(upgrade_level)
	return "Single"
end

function Noob.isCamo(upgrade_level)
	return false
end

function Noob.updateCharacter(upgrade_level, unit_skin)
	return UpgradeFolder[unit_skin]["1"]
end

function Noob.Idle(upgrade_level)
	if upgrade_level == 1 or upgrade_level == 2 then
		return Noob.Animations.Idle1
	elseif upgrade_level == 3 then
		return Noob.Animations.Idle1	
	end
end

function Noob.Attack(upgrade_level)
	if upgrade_level == 1 or upgrade_level == 2 then
		return Noob.Animations.Attack1
	elseif upgrade_level == 3 then
		return Noob.Animations.Attack2
	end
end

function Noob.PlaySound(upgrade_level)
	if upgrade_level < 3 then
		return Noob.Sounds.Attack1, nil, nil, nil, 0.1
	else
		return Noob.Sounds.Attack2, nil, nil, nil, 0.1
	end
end


return Noob
