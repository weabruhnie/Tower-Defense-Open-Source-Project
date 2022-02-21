local Swordman = {
	Animations = {
		Idle1 = "rbxassetid://7476305061",
		
		Attack1 = "rbxassetid://7476408313",
		Attack2 = "rbxassetid://7476541594",
		Attack3 = "rbxassetid://7476475530",
		
	},
	
	Sounds = {
		Attack1 = "rbxassetid://935843979",
	}
}

local UpgradeFolder = game.ServerStorage.UnitSkins.Swordman

function Swordman.getTargetType(upgrade_level)
	--if upgrade_level == 3 then
	--	return "AOE"
	--end
	
	return "AOE"
end

function Swordman.isCamo(upgrade_level)
	return false
end

function Swordman.updateCharacter(upgrade_level, unit_skin)
	if upgrade_level == 4 then
		return UpgradeFolder[unit_skin]["2"]
	end
	
	return UpgradeFolder[unit_skin]["1"]
end

function Swordman.Idle(upgrade_level)
	if upgrade_level == 1 or upgrade_level == 2 then
		return Swordman.Animations.Idle1
	elseif upgrade_level == 3 or upgrade_level == 4 then
		return Swordman.Animations.Idle1	
	end
end

function Swordman.Attack(upgrade_level)
	if upgrade_level == 1 then
		return Swordman.Animations.Attack1
	elseif upgrade_level == 2 then
		return Swordman.Animations.Attack1
	elseif upgrade_level == 3 then
		return Swordman.Animations.Attack2
	elseif upgrade_level == 4 then
		return Swordman.Animations.Attack3
	end
end

function Swordman.PlaySound(upgrade_level)
	return Swordman.Sounds.Attack1, nil, nil, nil, 0.25
end

return Swordman
