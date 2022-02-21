local RS = game.ReplicatedStorage

local IntCash = RS.Events.Players.IntCash
local BonusCash = RS.Events.Players.Eco.BonusCash

local EcoHandler = {}

function EcoHandler.int(Player)
	local self = {}
	
	local Cash = 500
	
	local LocalCashVal = Instance.new("IntValue", Player.plr_vals)
	LocalCashVal.Name = "plr_cash"
	
	LocalCashVal.Value = Cash
	
	if Player:IsInGroup(3206627) then                    
		Cash += 250    
	end
	
	IntCash:FireClient(Player, LocalCashVal)
	
	function self:Update(isWaveBonus, amtWaveBonus)
		if isWaveBonus and amtWaveBonus then
			BonusCash:FireClient(Player, amtWaveBonus)
			LocalCashVal.Value = Cash
		else
			LocalCashVal.Value = Cash
		end
		
	end
	
	function self:Income(amt)
		if amt > 0 then
			Cash += amt
		end
	end
	
	function self:Purchase(amt)
		if amt <= Cash then
			Cash -= amt
			return true
		end
		
		return false
	end	
	
	self:Update()
	
	return self
end

return EcoHandler
