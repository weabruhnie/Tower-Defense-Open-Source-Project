local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Players = game:GetService("Players")

local MapHandler = require(game.ServerStorage.Modules.MapHandler)

local ServerStorage = game.ServerStorage
local ServerEvents = ServerStorage.Events

local increment = 0

local EnemyHandler = {}

function EnemyHandler.setup(Enemy)
	local self = {
		Instance = Enemy,
		HP = tonumber(Enemy:GetAttribute("HP")),
		SPD = tonumber(Enemy:GetAttribute("SPD")),
		
		EnemyType = Enemy:GetAttribute("isAir") == true and "Air" or "Ground",
		
		isCamo = Enemy:GetAttribute("isCamo"),
		
		isSpecial = Enemy:GetAttribute("isSpecial"),
		
		Name = Enemy.Name,
	}
	
	Enemy:SetAttribute("EnemyName", self.Name)
	
	local CurrentDiff = MapHandler:getDiff()
	
	local HPScale = self.HP
	if CurrentDiff == "Easy" then
		HPScale = (HPScale*1) ^ (0.9 + (#Players:GetPlayers() / 125))
	elseif CurrentDiff == "Normal" then
		HPScale = (HPScale*1.25)  ^ (1 + (#Players:GetPlayers() / 100))
	elseif CurrentDiff == "Hard" then
		HPScale = (HPScale*1.5) ^ (1.1 + (#Players:GetPlayers() / 75))
	else
		HPScale = (HPScale*2.2) ^ (1.15 + (#Players:GetPlayers() / 50))
	end
	
	self.HP = math.floor(HPScale + 0.5)	
	
	Enemy:SetAttribute("HP", self.HP)
	
	local CurrentHP = tonumber(self.HP)
	
	function self:getCurrentHP()
		return CurrentHP
	end
		
	self.Order = increment
	
	self.Instance.Name = "Enemy" .. increment
	
	increment += 1
	
	local Map = MapHandler:getMap()
	
	for _,enemyPart in pairs(self.Instance:GetDescendants()) do
		if enemyPart:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(enemyPart, "EnemyCollision")
		end
	end
	
	self.ReachedEnd = false
	
	local Destroying = false
	
	--self.DistanceTravelled = 0
	
	--local runningDistance = RunService.Heartbeat:Connect(function(dt)
	--	self.DistanceTravelled += self.Instance.HumanoidRootPart.Velocity.magnitude * dt
	--end)
	
	function self:IsDestroyed()	
		return Destroying
	end
	
	function self:Delete()	
		Destroying = true
		
		--if runningDistance then runningDistance:Disconnect() end
		
		MapHandler.EnemyCount -= 1
		
		CollectionService:RemoveTag(self.Instance, "Enemies")
		
		self.Instance:Destroy()
		
		if self.ReachedEnd then
			ServerEvents.Enemies.EnemyReachedEnd:Fire(CurrentHP)
		end
	end
	
	local function UpdateGlobalHP()
		Enemy:SetAttribute("CurrentHP", CurrentHP)
	end	
	UpdateGlobalHP()
	
	function self:Damaged(inflicted)	
		ServerEvents.Economy.GiveCashAll:Fire(inflicted)
		
		CurrentHP -= inflicted
		
		UpdateGlobalHP()
		
		if CurrentHP <= 0 then			
			self:Delete()
		end
	end
	
	local animationController = Instance.new("AnimationController", self.Instance)
	
	local function MovementAnim(id)
		local animation = Instance.new("Animation")

		animation.AnimationId = id

		local animationTrack = animationController:LoadAnimation(animation)

		animationTrack:Play(0.1, 1, self.SPD/16)
	end	
	
	function self:ManualAnim(id)
		local animation = Instance.new("Animation")

		animation.AnimationId = id

		local animationTrack = animationController:LoadAnimation(animation)

		animationTrack:Play(0.1, 1, 1)
	end
	
	function self:ManualSound(id)
		local sound = Instance.new("Sound")	
		sound.Parent = self.Instance.HumanoidRootPart
		
		sound.SoundId = id
		sound.PlayOnRemove = true

		sound:Destroy()
	end	
	
	local CurrentPath	
	
	function self:getCurrentPath()
		if CurrentPath then return CurrentPath end
	end
	
	local InitialPath = 1
	
	local getSpawnedPath = self.Instance:GetAttribute("SpawnedCurrentPath")
	
	if getSpawnedPath ~= nil and tonumber(getSpawnedPath) then
		InitialPath = tonumber(getSpawnedPath)
	end
	
	function self:EnemyPathInt()		
		local AlignPosition = Enemy.HumanoidRootPart.AlignPosition
		local AlignOrientation = Enemy.HumanoidRootPart.AlignOrientation

		AlignPosition.Attachment0 = Enemy.HumanoidRootPart.Attachment
		AlignPosition.Attachment1 = nil
		
		AlignPosition.ReactionForceEnabled = false
		AlignPosition.ApplyAtCenterOfMass = false
		
		AlignPosition.MaxForce = self.SPD * 50000
		AlignPosition.MaxVelocity = self.SPD/10
		AlignPosition.Responsiveness = 200

		AlignOrientation.Attachment0 = Enemy.HumanoidRootPart.Attachment
		AlignOrientation.Attachment1 = nil

		for i=InitialPath,#Map.Paths:GetChildren() do	
			local PathIndex = Map.Paths[i]
			
			Enemy.HumanoidRootPart.Attachment.WorldPosition = Vector3.new(Enemy.HumanoidRootPart.Attachment.WorldPosition.X, 1.875, Enemy.HumanoidRootPart.Attachment.WorldPosition.Z)
			
			CurrentPath = PathIndex
			
			AlignPosition.Attachment1 = PathIndex.Attachment
			AlignOrientation.Attachment1 = PathIndex.Attachment

			repeat 
				Enemy.HumanoidRootPart.Attachment.WorldPosition = Vector3.new(Enemy:FindFirstChild("HumanoidRootPart").Attachment.WorldPosition.X, 1.875, Enemy.HumanoidRootPart.Attachment.WorldPosition.Z)
				RunService.Heartbeat:Wait()
				
				if Destroying then return end
			until Enemy:FindFirstChild("HumanoidRootPart") and (PathIndex.Attachment.WorldPosition - Enemy.HumanoidRootPart.Attachment.WorldPosition).Magnitude < 0.5
			
			--TempAttach:Destroy()
		end
		
		self.ReachedEnd = true
		self:Delete()
	end
	
	if self.isSpecial == true then
		self.SpecialMod = require(ServerStorage.Attacks.SpecialEnemies[self.Name])
		
		if self.SpecialMod then
			MovementAnim(self.SpecialMod.getRunAnim())
			
			if self.SpecialMod.Special and type(self.SpecialMod.Special) == 'function' then				
				local CooldownTimer = self.SpecialMod.getCooldownSpecial()

				local currentTime = CooldownTimer/4

				local AttackRenderConnect
				
				AttackRenderConnect = RunService.Heartbeat:Connect(function(dt_scale)
					if Destroying then
						AttackRenderConnect:Disconnect()
						return
					end

					currentTime -= dt_scale

					if currentTime <= 0 then
						self.SpecialMod.Special(self)
						currentTime = CooldownTimer
					end
				end)
			end
		end
		
	else		
		MovementAnim("rbxassetid://7490876753")
	end	
	
	coroutine.wrap(function()
		self:EnemyPathInt()
	end)()
	
	return self
end

return EnemyHandler
