local Snoobper = {
	Animations = {
		Idle1 = "rbxassetid://7481679262",
		
		Attack1 = "rbxassetid://7482657266",		
	},
	
	Sounds = {
		Attack1 = "rbxassetid://383602395",
		Attack2 = "rbxassetid://2756050321"
	}
}

local UpgradeFolder = game.ServerStorage.UnitSkins.Snoobper

function Snoobper.updateCharacter(upgrade_level, unit_skin)
	if upgrade_level == 2 then		
		return UpgradeFolder[unit_skin]["2"]
	elseif upgrade_level == 3 then
		return UpgradeFolder[unit_skin]["3"]
	elseif upgrade_level == 4 then
		return UpgradeFolder[unit_skin]["4"]
	end
	
	return UpgradeFolder[unit_skin]["1"]
end

function Snoobper.getTargetType(upgrade_level)
	--if upgrade_level == 3 then
	--	return "AOE"
	--end
	
	return "Single"
end

function Snoobper.isCamo(upgrade_level)
	if upgrade_level >= 2 then
		return true
	end

	return false
end

function Snoobper.Idle(upgrade_level)
	return Snoobper.Animations.Idle1
end

function Snoobper.Attack(upgrade_level)
	return Snoobper.Animations.Attack1
	
end

function Snoobper.PlaySound(upgrade_level)
	if upgrade_level == 3 or upgrade_level == 4 then
		return Snoobper.Sounds.Attack2, nil, nil, nil, 0.15
	end
	
	return Snoobper.Sounds.Attack1, nil, nil, nil, 0.1
end

function Snoobper.Visuals(upgrade_level, unit)
	local unitInt = unit.Unit
	
	if unit:IsDeleted() then return end
	
	if upgrade_level <= 2 then		
		unitInt["Sniper Rifle"].Muzzle.MuzzleEffect:Emit(1)

	elseif upgrade_level == 3 then
		unitInt["Heavy Rifle"].Muzzle.MuzzleEffect:Emit(1)
		
	elseif upgrade_level == 4 then
		unitInt.KSRSniper.Muzzle.MuzzleEffect:Emit(1)

	end
end


return Snoobper
