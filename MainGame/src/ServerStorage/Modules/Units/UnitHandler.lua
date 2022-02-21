local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

local TweenService = game:GetService("TweenService")

local ServerStorage = game:GetService("ServerStorage")

local UnitsDatabase = require(ServerStorage.Database.UnitsDatabase)

local SPDict = require(game.ReplicatedStorage.Modules.Util.SPDict)

local MapHandler = require(ServerStorage.Modules.MapHandler)

local UnitHandler = {}

UnitHandler.TargetModes = {
	First = 0,
	Last = 1,
	Closest = 2,
	Strongest = 3,
}

function UnitHandler.Int(player, unit, unitInfo, unitCFrame, unitID, customUnitSkin)
	local self = {
		Unit = unit,
		UpgradeLevel = 1,
		
		UnitType = unitInfo.Type,		
		UnitMode = unitInfo.Mode,
		
		UnitCFrame = unitCFrame,
		
		TargetMode = UnitHandler.TargetModes.First,
		
		Owner = player,
		
		ReadyToAttack = false,
	}
	
	self.UnitSkin = "Default"
	
	if customUnitSkin ~= nil then
		self.UnitSkin = customUnitSkin
	end
	
	self.UnitID = unitID
	
	local UnitAttacks = require(ServerStorage.Attacks.Units[unit.Name])
	
	self.Stats = unitInfo.Upgrades[self.UpgradeLevel].Stats	
	self.MaxLevel = #unitInfo.Upgrades
	
	self.TotalCost = unitInfo.Cost
	
	local idle_animation = Instance.new("Animation")
	local atk_animation = Instance.new("Animation")
	
	local Deleting = false
	
	function self:IsDeleted()
		return Deleting
	end
	
	local function playIdleAnim(id)		
		if self:IsDeleted() then return end
		
		idle_animation.AnimationId = id

		local animTrack = self.Unit.Humanoid:LoadAnimation(idle_animation)		
		
		animTrack.Priority = Enum.AnimationPriority.Idle
		
		animTrack:Play()
	end

	local function playActionAnim(id, SpeedTime)
		if self:IsDeleted() then return end
		
		atk_animation.AnimationId = id

		local animTrack = self.Unit.Humanoid:LoadAnimation(atk_animation)	
		
		animTrack.Priority = Enum.AnimationPriority.Action	
		
		animTrack:Play()
		
		if SpeedTime then
			local speed = animTrack.Length / SpeedTime  
			animTrack:AdjustSpeed(speed)
		end
	end
	
	local CreateSoundLocation
	
	local function playSound(id, timePos, volume, speed)
		if self:IsDeleted() then return end
		if not CreateSoundLocation then return end
		
		local CreateSound = Instance.new("Sound", CreateSoundLocation)
		CreateSound.PlayOnRemove = true
		
		CreateSound.SoundId = id
		
		CreateSound.TimePosition = 0
		
		if timePos then
			CreateSound.TimePosition = timePos
		end
		
		CreateSound.Volume = 0.5
		
		if volume then
			CreateSound.Volume = volume
		end
		
		CreateSound.PlaybackSpeed = 1
		
		if speed then
			CreateSound.PlaybackSpeed = CreateSound.TimeLength / speed 
		end
		
		CreateSound:Destroy()		
	end
	
	local function reWeldRange()
		self.Unit.Hitbox.Transparency = 1
		
		local attach1 = Instance.new("Attachment")		
		attach1.Parent = self.Unit.PrimaryPart
		attach1.Position = Vector3.new(0, -1.35, 0)

		local rangeClone = game.ReplicatedStorage.Templates.UnitTemplate.Range:Clone()	
		rangeClone.Name = "Range"
		rangeClone.Parent = self.Unit

		rangeClone.Anchored = false
		rangeClone.CanCollide = false

		rangeClone.Size = Vector3.new(50, unitInfo.Upgrades[1].Stats.RNG, unitInfo.Upgrades[1].Stats.RNG)

		rangeClone.Material = Enum.Material.Plastic
		rangeClone.Transparency = 1

		local rangeWeld = Instance.new("Weld")
		rangeWeld.Name = "rangeWeld"
		rangeWeld.Part0 = rangeClone
		rangeWeld.Part1 = self.Unit.PrimaryPart
		rangeWeld.C0 = rangeWeld.Part0.RangeAttach.CFrame
		rangeWeld.C1 = attach1.CFrame

		rangeWeld.Parent = rangeWeld.Part0
		
		PhysicsService:SetPartCollisionGroup(rangeClone, "RangeCollision")
		
		self.Unit.PrimaryPart.Anchored = true
		self.Unit.PrimaryPart.CFrame = self.UnitCFrame
	end
	
	reWeldRange()
	
	local function setStatsGlobal()
		self.Unit:SetAttribute("Owner", self.Owner.Name)
		
		self.Unit:SetAttribute("LVL", self.UpgradeLevel)
		self.Unit:SetAttribute("MaxLVL", self.MaxLevel)

		self.Unit:SetAttribute("ATK", self.Stats.ATK)
		self.Unit:SetAttribute("RNG", self.Stats.RNG)
		self.Unit:SetAttribute("SPD", self.Stats.SPD)
		
		self.Unit:SetAttribute("TargetMode", self.TargetMode)
		
		self.Unit:SetAttribute("UnitID", self.UnitID)
		
		self.Unit:SetAttribute("TotalCost", self.TotalCost)
		
		self.Unit:SetAttribute("hasCamo", UnitAttacks.isCamo(self.UpgradeLevel))
		
		self.Unit.Range.Size = Vector3.new(self.Unit.Range.Size.X, self.Stats.RNG,self.Stats.RNG)
	end
	
	setStatsGlobal()
	
	local timePassed = math.huge
	
	local function UpdateCharacter()
		self.TotalCost += unitInfo.Upgrades[self.UpgradeLevel].Cost
		
		local Character = UnitAttacks.updateCharacter(self.UpgradeLevel, self.UnitSkin)
		
		if Character then
			local newChar = Character:Clone()
			
			newChar.Parent = workspace.Units
			
			newChar.Name = self.Unit.Name			
			
			for _,unitPart in pairs(newChar:GetDescendants()) do
				if unitPart:IsA("BasePart") and unitPart.Name ~= "Range" then
					PhysicsService:SetPartCollisionGroup(unitPart, "UnitCollision")
				end
			end
			
			newChar:SetPrimaryPartCFrame(self.Unit.PrimaryPart.CFrame)
			
			self.Unit:Destroy()
			
			self.Unit = newChar
			
			CreateSoundLocation = self.Unit.Head
			
			reWeldRange()
			setStatsGlobal()
			
			timePassed = math.huge
		end
	end
	
	UpdateCharacter()
	
	function self:getNextUpdateInfo()
		if self.UpgradeLevel >= self.MaxLevel then
			return false
		end
		
		return unitInfo.Upgrades[self.UpgradeLevel+1]
	end
	
	function self:Upgrade()
		if self.UpgradeLevel >= self.MaxLevel then
			self.UpgradeLevel = self.MaxLevel
			return
		end
		
		self.UpgradeLevel += 1
		
		self.Stats = unitInfo.Upgrades[self.UpgradeLevel].Stats
		
		setStatsGlobal()
		UpdateCharacter()
		
		if UnitAttacks.Idle and type(UnitAttacks.Idle) == 'function' then
			playIdleAnim(UnitAttacks.Idle(self.UpgradeLevel))
		end	
	end
	
	function self:NextTargetMode()
		if self.TargetMode == UnitHandler.TargetModes.First then
			self.TargetMode = UnitHandler.TargetModes.Last

		elseif self.TargetMode == UnitHandler.TargetModes.Last then
			self.TargetMode = UnitHandler.TargetModes.Closest

		elseif self.TargetMode == UnitHandler.TargetModes.Closest then	
			self.TargetMode = UnitHandler.TargetModes.Strongest

		else
			self.TargetMode = UnitHandler.TargetModes.First

		end

		setStatsGlobal()
	end
	
	local function PointInCylinder(point,cylinder)
		local radius = math.min(cylinder.Size.Z,cylinder.Size.Y) * 0.5;
		local height = cylinder.Size.X;
		local relative = (point - cylinder.Position)

		local sProj = cylinder.CFrame.RightVector:Dot(relative)
		local vProj = cylinder.CFrame.RightVector * sProj
		local len = (relative - vProj).Magnitude

		return len <= radius and math.abs(sProj) <= (height * 0.5)
	end
	
	if UnitAttacks.Idle and type(UnitAttacks.Idle) == 'function' then
		playIdleAnim(UnitAttacks.Idle(self.UpgradeLevel))
	end	
	
	self.EnemiesInRange = SPDict:new()
	
	local overlapParams = OverlapParams.new()
	
	overlapParams.CollisionGroup = "RangeCollision"
	
	local function SearchEnemiesInRadius()	
		local EnemyFolder = workspace:WaitForChild("Enemies");
		
		local UnitRoot = self.Unit:FindFirstChild("HumanoidRootPart")
		if not UnitRoot then print("unit root missing") return end
		
		for _,Enemy in pairs(EnemyFolder:GetChildren()) do
			local inRadius = false
			
			for _,enemPart in pairs(Enemy:GetChildren())do
				if enemPart:IsA("BasePart") then
					if PointInCylinder(enemPart.Position, self.Unit.Range) then
						inRadius = true
					end
				end		
			end
			
			if inRadius then
				if not self.EnemiesInRange:contains(Enemy.Name) then
					local EnemyInfo = ServerStorage.Events.Enemies.GetEnemy:Invoke(Enemy)
					self.EnemiesInRange:add(Enemy.Name, EnemyInfo)
				end				
			else				
				if self.EnemiesInRange:contains(Enemy.Name) then
					self.EnemiesInRange:remove(Enemy.Name)
				end
			end
		end
		
		for k,v in self.EnemiesInRange:key_itr() do
			if not workspace.Enemies:FindFirstChild(k) then
				self.EnemiesInRange:remove(k)
			end
		end
	end
	
	--local enemyList

	--local function EnemyListSort()
	--	SearchEnemiesInRadius()

	--	enemyList = self.EnemiesInRange:key_list()

	--	enemyList:sort(function(a,b)
	--		return self.EnemiesInRange:get(a).ProgressMade < self.EnemiesInRange:get(b).ProgressMade
	--	end)
	--end
	
	local function IsEnemyAttackable()	
		local UnitRoot = self.Unit:FindFirstChild("HumanoidRootPart")

		local enemyToHit
		local TargetEnemPath
		
		local ScannedEnemy = {}

		for k,currentEnem in self.EnemiesInRange:key_itr() do
			
			if not ScannedEnemy[currentEnem] then				
				ScannedEnemy[currentEnem] = true
				
				local currentEnemPath = currentEnem:getCurrentPath()
				
				if self.TargetMode == UnitHandler.TargetModes.First then

					if not enemyToHit then					
						enemyToHit = currentEnem
						TargetEnemPath = enemyToHit:getCurrentPath()
					else
						
						if currentEnemPath ~= TargetEnemPath then
							
							if currentEnemPath.Name > TargetEnemPath.Name then
								enemyToHit = currentEnem
								TargetEnemPath = enemyToHit:getCurrentPath()
							end	
							
						elseif currentEnemPath == TargetEnemPath then	
							
							if not currentEnem:IsDestroyed() then
								local CurrentEnemRoot = currentEnem.Instance.HumanoidRootPart
								local TargetEnemyRoot = enemyToHit.Instance.HumanoidRootPart
								
								if (CurrentEnemRoot.Attachment.WorldPosition - currentEnemPath.Position).Magnitude <= (TargetEnemyRoot.Attachment.WorldPosition - TargetEnemPath.Position).Magnitude then
									enemyToHit = currentEnem
									TargetEnemPath = enemyToHit:getCurrentPath()
								end								
							end
							
						end
					end

				elseif self.TargetMode == UnitHandler.TargetModes.Last then

					if not enemyToHit then					
						enemyToHit = currentEnem
						TargetEnemPath = enemyToHit:getCurrentPath()
					else

						if currentEnemPath ~= TargetEnemPath then
							if currentEnemPath.Name < TargetEnemPath.Name then
								enemyToHit = currentEnem
								TargetEnemPath = enemyToHit:getCurrentPath()
							end						
						elseif currentEnemPath == TargetEnemPath then
							
							if not currentEnem:IsDestroyed() then
								local CurrentEnemRoot = currentEnem.Instance.HumanoidRootPart
								local TargetEnemyRoot = enemyToHit.Instance.HumanoidRootPart

								if (CurrentEnemRoot.Attachment.WorldPosition - currentEnemPath.Position).Magnitude >= (TargetEnemyRoot.Attachment.WorldPosition - TargetEnemPath.Position).Magnitude then
									enemyToHit = currentEnem
									TargetEnemPath = enemyToHit:getCurrentPath()
								end								
							end
							
						end
					end

				elseif self.TargetMode == UnitHandler.TargetModes.Strongest then

					if not enemyToHit then
						enemyToHit = currentEnem
					else
						if currentEnem:getCurrentHP() > enemyToHit:getCurrentHP() then
							enemyToHit = currentEnem
						end
					end

				else

					if not enemyToHit then
						enemyToHit = currentEnem
					else
						local foundEnemRoot = currentEnem.Instance:FindFirstChild("HumanoidRootPart")
						
						if not currentEnem:IsDestroyed() and foundEnemRoot and (self.Unit.HumanoidRootPart.Position - foundEnemRoot.Position).Magnitude < (foundEnemRoot.Position - self.Unit.HumanoidRootPart.Position).Magnitude  then
							enemyToHit = currentEnem
						end
					end

				end

				if currentEnem.EnemyType == "Air" and self.UnitType == "Ground" then
					enemyToHit = nil
				end
				
				if currentEnem.isCamo and not UnitAttacks.isCamo(self.UpgradeLevel) then
					enemyToHit = nil
				end
				
				if currentEnem:IsDestroyed() or not currentEnem.Instance:FindFirstChild("HumanoidRootPart") then
					enemyToHit = nil
				end
			end

		end
		
		return enemyToHit
	end
	
	local function AttackCurrentEnemy(enemyToHit)	
		local UnitRoot = self.Unit:FindFirstChild("HumanoidRootPart")
		local EnemyRoot = enemyToHit.Instance:FindFirstChild("HumanoidRootPart")
		
		if UnitRoot and EnemyRoot then
			local X,Y,Z = CFrame.new(UnitRoot.Position, EnemyRoot.Position):ToOrientation()

			UnitRoot.CFrame = CFrame.new(UnitRoot.Position,Vector3.new(EnemyRoot.Position.X, UnitRoot.Position.Y, EnemyRoot.Position.Z))

			--UnitRoot.CFrame = CFrame.new(UnitRoot.Position, LookAt

			self.TargetType = UnitAttacks.getTargetType(self.UpgradeLevel)

			if self.TargetType == "Single" then
				if self.UnitMode == "Semi" then		
					
					if UnitAttacks.PlaySound and type(UnitAttacks.PlaySound) == 'function' then
						local sound, loop, delayTime, timePos, volume, timeSpeed = UnitAttacks.PlaySound(self.UpgradeLevel)

						if loop and delayTime then
							coroutine.wrap(function()
								for i=1,loop do
									playSound(sound, timePos, volume)								
									wait(delayTime)
								end	
							end)()									
						else						
							playSound(sound, timePos, volume)			
						end
					end
					
					if UnitAttacks.Visuals and type(UnitAttacks.Visuals) == 'function' then
						UnitAttacks.Visuals(self.UpgradeLevel, self)
					end
					
					if UnitAttacks.Attack and type(UnitAttacks.Attack) == 'function' then
						playActionAnim(UnitAttacks.Attack(self.UpgradeLevel))
					end					
					
					enemyToHit:Damaged(self.Stats.ATK)
					
				elseif self.UnitMode == "Burst" then
					local BurstRate = unitInfo.Upgrades[self.UpgradeLevel].Stats.BurstRate
					local BurstAmount = unitInfo.Upgrades[self.UpgradeLevel].Stats.BurstAmount
					
					if BurstRate and BurstAmount then
						for i=1,BurstAmount do

							local newEnemy = IsEnemyAttackable()

							if newEnemy then
								
								if UnitAttacks.PlaySound and type(UnitAttacks.PlaySound) == 'function' then
									local sound, loop, delayTime, timePos, volume = UnitAttacks.PlaySound(self.UpgradeLevel)
									playSound(sound, timePos, volume)
								end

								if UnitAttacks.Visuals and type(UnitAttacks.Visuals) == 'function' then
									UnitAttacks.Visuals(self.UpgradeLevel, self)
								end							

								UnitRoot.CFrame = CFrame.new(UnitRoot.Position,Vector3.new(newEnemy.Instance.HumanoidRootPart.Position.X, UnitRoot.Position.Y, newEnemy.Instance.HumanoidRootPart.Position.Z))						

								self.EnemiesInRange:get(newEnemy.Instance.Name):Damaged(self.Stats.ATK)

								if UnitAttacks.Attack and type(UnitAttacks.Attack) == 'function' then
									playActionAnim(UnitAttacks.Attack(self.UpgradeLevel))
								end							

								wait(BurstRate)	
							end
						end
						
						playSound(UnitAttacks.PlayReloadSound(), nil, nil, self.Stats.SPD)				
						
						if UnitAttacks.Reload and type(UnitAttacks.Reload) == 'function' then
							playActionAnim(UnitAttacks.Reload(self.UpgradeLevel), self.Stats.SPD)
						end
			
					end			
					
				end
				
			elseif self.TargetType == "AOE" then
				if UnitAttacks.PlaySound and type(UnitAttacks.PlaySound) == 'function' then
					local sound, loop, delayTime, timePos, volume, timeSpeed = UnitAttacks.PlaySound(self.UpgradeLevel)

					if loop and delayTime then
						coroutine.wrap(function()
							for i=1,loop do
								playSound(sound, timePos, volume)								
								wait(delayTime)
							end	
						end)()									
					else						
						playSound(sound, timePos, volume)			
					end
				end	
				
				if UnitAttacks.Attack and type(UnitAttacks.Attack) == 'function' then
					playActionAnim(UnitAttacks.Attack(self.UpgradeLevel))
				end
				
				for k,enemyToAoe in self.EnemiesInRange:key_itr() do
					enemyToAoe:Damaged(self.Stats.ATK)				
				end
			end	
		end
		
		
	end
	
	local connection
	
	if self.UnitMode ~= "Farm" then
		coroutine.wrap(function()
			connection = RunService.Heartbeat:Connect(function(dt)	
				if Deleting then return end

				coroutine.wrap(function()
					SearchEnemiesInRadius()
				end)()

				timePassed += dt

				if timePassed >= self.Stats.SPD then
					if self.ReadyToAttack then return end	

					self.ReadyToAttack = true

					if self.UnitType == "Ground" or self.UnitType == "Air" then
						local Attackable

						repeat
							if Deleting then return end	
							Attackable = IsEnemyAttackable()
							wait()
						until self.EnemiesInRange:count() > 0 and Attackable ~= nil

						AttackCurrentEnemy(Attackable)
					end

					timePassed = 0

					self.ReadyToAttack = false			
				end
			end)
		end)()
	end
	
	if self.UnitMode == "Farm" then
		function self.ReceiveCashRound()
			local CashToGive = self.Stats.ATK
			
			if game.Players:FindFirstChild(self.Owner.Name) then		
				playSound(UnitAttacks.PlaySound())
				
				ServerStorage.Events.Economy.GiveCash:Fire(self.Owner, CashToGive)
				
				local FarmCashCloneTemp = ServerStorage.UIs.FarmCashTemplate:Clone()
				FarmCashCloneTemp.Parent = self.Unit
				FarmCashCloneTemp.Adornee = self.Unit
				
				FarmCashCloneTemp.CashLabel.Text = "+$"..CashToGive
				
				FarmCashCloneTemp.Enabled = true
				
				FarmCashCloneTemp.StudsOffset = Vector3.new(0, 0.3, 0)
				
				local TextMoveUp = TweenService:Create(FarmCashCloneTemp, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {StudsOffset = Vector3.new(0, 2.7, 0)})
				TextMoveUp:Play()
				
				coroutine.wrap(function()
					TextMoveUp.Completed:Wait()
					FarmCashCloneTemp:Destroy()
				end)()
			end			
		end
	end
	
	function self:Delete()
		Deleting = true
		
		if connection then connection:Disconnect() end
		
		self.Unit:Destroy()
	end	
	
	return self
end


return UnitHandler
