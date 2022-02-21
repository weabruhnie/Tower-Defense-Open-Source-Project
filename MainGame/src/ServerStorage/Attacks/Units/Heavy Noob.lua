local HeavyNoob = {
	Animations = {
		Idle1 = "rbxassetid://7589780945",
		Attack1 = "rbxassetid://7589895748",
	},
	
	Sounds = {
		Attack1 = "rbxassetid://165946448",
	}
}

local UpgradeFolder = game.ServerStorage.UnitSkins["Heavy Noob"]

function HeavyNoob.getTargetType(upgrade_level)	
	return "Single"
end

function HeavyNoob.isCamo(upgrade_level)
	if upgrade_level >= 3 then
		return true
	end

	return false
end

function HeavyNoob.updateCharacter(upgrade_level, unit_skin)
	return UpgradeFolder[unit_skin][upgrade_level]	
end


function HeavyNoob.Idle(upgrade_level)
	return HeavyNoob.Animations.Idle1
end

function HeavyNoob.Attack(upgrade_level)
	return HeavyNoob.Animations.Attack1
end

function HeavyNoob.PlaySound(upgrade_level)	
	return HeavyNoob.Sounds.Attack1, nil, nil, nil, 0.1
end

function HeavyNoob.Visuals(upgrade_level, unit)
	local unitInt = unit.Unit
	
	if unit:IsDeleted() then return end

	unitInt.M60.Muzzle.MuzzleEffect:Emit(1)
end


return HeavyNoob
