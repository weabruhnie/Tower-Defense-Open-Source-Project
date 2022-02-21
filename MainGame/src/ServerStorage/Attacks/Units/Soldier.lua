local Soldier = {
	Animations = {
		Idle1 = "rbxassetid://7487131295",
		
		Attack1 = "rbxassetid://7487230242",
		
		Reload1 = "rbxassetid://7488073024"
	},
	
	Sounds = {
		Attack1 = "rbxassetid://4684959406",
		Reload1 = "rbxassetid://4604186785",
	}
}

local UpgradeFolder = game.ServerStorage.UnitSkins.Soldier

function Soldier.getTargetType(upgrade_level)
	--if upgrade_level == 3 then
	--	return "AOE"
	--end
	
	return "Single"
end

function Soldier.isCamo(upgrade_level)
	if upgrade_level >= 3 then
		return true
	end

	return false
end

function Soldier.updateCharacter(upgrade_level, unit_skin)
	return UpgradeFolder[unit_skin][upgrade_level]	
end


function Soldier.Idle(upgrade_level)
	return Soldier.Animations.Idle1
end

function Soldier.Attack(upgrade_level)
	return Soldier.Animations.Attack1
end

function Soldier.Reload(upgrade_level)
	return Soldier.Animations.Reload1
end

function Soldier.PlayReloadSound()
	return Soldier.Sounds.Reload1, nil, nil, nil, 0.1
end

function Soldier.PlaySound(upgrade_level)	
	return Soldier.Sounds.Attack1, nil, nil, nil, 0.1
end

function Soldier.Visuals(upgrade_level, unit)
	local unitInt = unit.Unit
	
	if unit:IsDeleted() then return end
	
	unitInt.G36.Muzzle.MuzzleEffect:Emit(1)
end


return Soldier
