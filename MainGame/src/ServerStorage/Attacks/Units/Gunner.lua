local Gunner = {
	Animations = {
		Idle1 = "rbxassetid://7484157751",
		Idle2 = "rbxassetid://7484160781",
		
		Attack1 = "rbxassetid://7484174493",
		Attack2 = "rbxassetid://7484176054",		
	},
	
	Sounds = {
		Attack1 = "rbxassetid://2757012511"
	}
}

local UpgradeFolder = game.ServerStorage.UnitSkins.Gunner

function Gunner.getTargetType(upgrade_level)
	--if upgrade_level == 3 then
	--	return "AOE"
	--end
	
	return "Single"
end

function Gunner.isCamo(upgrade_level)
	if upgrade_level >= 3 then
		return true
	end
	
	return false
end

function Gunner.updateCharacter(upgrade_level, unit_skin)
	return UpgradeFolder[unit_skin][upgrade_level]
	
	
end


function Gunner.Idle(upgrade_level)
	if upgrade_level < 4 then
		return Gunner.Animations.Idle1
	elseif upgrade_level >= 4 then
		return Gunner.Animations.Idle2
	end
end

function Gunner.Attack(upgrade_level)
	if upgrade_level < 4 then
		return Gunner.Animations.Attack1
	elseif upgrade_level >= 4 then
		return Gunner.Animations.Attack2
	end
end

function Gunner.PlaySound(upgrade_level)
	if upgrade_level < 4 then
		return Gunner.Sounds.Attack1, nil, nil, nil, 0.1
	elseif upgrade_level >= 4 then
		return Gunner.Sounds.Attack1, 2, 0.25, nil, 0.1
	end
end

function Gunner.Visuals(upgrade_level, unit)
	local unitInt = unit.Unit
	
	if unit:IsDeleted() then return end
	
	if upgrade_level < 4 then		
		unitInt.Pistol.Muzzle.MuzzleEffect:Emit(1)
		
	elseif upgrade_level >= 4 then

		coroutine.wrap(function()
			unitInt.Pistol.Muzzle.MuzzleEffect:Emit(1)
			wait(0.25)
			unitInt.Pistol2.Muzzle.MuzzleEffect:Emit(1)
		end)()
		
		
	end
end


return Gunner
