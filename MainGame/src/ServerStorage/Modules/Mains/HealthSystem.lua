local ServerStorage = game.ServerStorage

local HealthSystem = {}

function HealthSystem.Int(Map)
	local self = {}
	
	local AddedPlayers = {}
	
	local EndedGame = false
	
	self.MaxHP = 100
	
	self.CurrentHP = self.MaxHP	
	
	self.HPGui = nil
	
	local function UpdateHPGui()
		self.HPGui.Frame.Bar.HP.Text = self.CurrentHP .. "/" .. self.MaxHP 
		
		local health = math.clamp(self.CurrentHP / self.MaxHP, 0, 1) --Maths
		
		self.HPGui.Frame.Bar.Fill.Size = UDim2.fromScale(health, 1)
	end
	
	function self:IncreaseMaxHP(plr, level)
		if not AddedPlayers[plr.Name] then
			AddedPlayers[plr.Name] = true
			self.MaxHP += level
			self.CurrentHP = self.MaxHP

			UpdateHPGui()
		end		
	end
	
	function self:cons()		
		local MapPaths = Map.Paths:GetChildren()
		
		local LastPath = MapPaths[#MapPaths]
		
		self.HPGui = ServerStorage.UIs.HPGui:Clone()
		
		self.HPGui.Parent = Map.GUIs
		
		self.HPGui.Adornee = LastPath
		
		UpdateHPGui()
	end             
	
	function self:SubtractHP(amt)
		if EndedGame then return end		
		
		self.CurrentHP -= amt
		
		UpdateHPGui()
		
		if self.CurrentHP <= 0 then
			ServerStorage.Events.Game.GameLost:Fire()
			EndedGame = true
		end
	end
	
	self:cons()
	
	return self
end

return HealthSystem
