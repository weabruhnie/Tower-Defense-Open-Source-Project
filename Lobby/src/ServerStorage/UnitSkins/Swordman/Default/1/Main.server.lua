local DebrisService = game:GetService("Debris")
local RunService = game:GetService("RunService")

local Character = script.Parent
local Animations = Character:FindFirstChild("Animations")
local Stats = Character:FindFirstChild("Stats")
local Cooldowns = Character:FindFirstChild("Cooldowns")
local Humanoid = Character:WaitForChild("Humanoid")
local Torso = Character:WaitForChild("Torso")
local Head = Character:WaitForChild("Head")
local AttackBool = Character:WaitForChild("Attack")
local TargetValue = Character:WaitForChild("Target")

local DamageEvent = game.ServerScriptService.DamageHandler.DamageEvent
local EffectEvent = game.ServerScriptService.DamageHandler.EffectEvent
local CalculateDamageBind = game.ServerScriptService.DamageHandler.CalculateDamage

local function wait(TimeToWait)
	if TimeToWait ~= nil then
		local TotalTime = 0
		TotalTime = TotalTime + game:GetService("RunService").Heartbeat:wait()
		while TotalTime < TimeToWait do
			TotalTime = TotalTime + game:GetService("RunService").Heartbeat:wait()
		end
	else
		game:GetService("RunService").Heartbeat:wait()
	end
end

local function raycast(spos,vec,currentdist)
	local hit2,pos2=game.Workspace:FindPartOnRay(Ray.new(spos+(vec*.01),vec*currentdist),script.Parent)
	if hit2~=nil and pos2 then
		if hit2.Parent==script.Parent and hit2.Transparency>=.8 or hit2.Name=="Handle" or string.sub(hit2.Name,1,6)=="Effect" or hit2.Parent:IsA("Hat") or hit2.Parent:IsA("Tool") or (hit2.Parent:FindFirstChild("Humanoid") and hit2.Parent:FindFirstChild("TEAM") and hit2.Parent:FindFirstChild("TEAM").Value == script.Parent.TEAM.Value) or (not hit2.Parent:FindFirstChild("Humanoid") and hit2.CanCollide==false) then
			local currentdist=currentdist-(pos2-spos).magnitude
			return raycast(pos2,vec,currentdist)
		end
	end
	return hit2,pos2
end

local function FindFirstInstance(parent,class)
	for _,v in pairs(parent:GetChildren()) do
		if v:IsA(class) then
			return v
		end
	end
	return nil
end

local function tagHumanoid(humanoid)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = Character.Owner.Value
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
	game:GetService("Debris"):AddItem(creator_tag, 0.5)
end

function FindNearestEnemy(pos)
	local StoredValues = {} --1 = Distance, 2 = NodeStage, 3 = MiniProg, 4 = TheEnemy
	local TargetMode = Stats.Priority.Value
	for i,ScannedEnemy in pairs(game.Workspace.Enemies:GetChildren()) do
		if ScannedEnemy:FindFirstChild("Stats") and ScannedEnemy:FindFirstChild("Humanoid") and ScannedEnemy ~= Character and not ScannedEnemy:FindFirstChild("Dead") then
			local EnemyTorso = ScannedEnemy:FindFirstChild("Torso")
			local EnemyStats = ScannedEnemy:FindFirstChild("Stats")
			local EnemyProg = EnemyStats:FindFirstChild("MiniProg")
			local EnemyNode = EnemyStats:FindFirstChild("NodeStage")
			if (EnemyTorso.Position - pos).magnitude < Stats.Range.Value then
				table.insert(StoredValues, {(EnemyTorso.Position - pos).magnitude, EnemyNode.Value, EnemyProg.Value, ScannedEnemy})
			end
		end
	end 
	local SDistance, SNodeStage, SMiniProg, TheEnemy
	if #StoredValues < 1 then return nil end
	for i, ScannedValues in pairs(StoredValues) do
		if SDistance == nil and SNodeStage == nil and SMiniProg == nil then
			SDistance = ScannedValues[1]
			SNodeStage = ScannedValues[2]
			SMiniProg = ScannedValues[3]
			TheEnemy = ScannedValues[4]
		else
			if TargetMode == "First" then
				if ScannedValues[2] >= SNodeStage then
					if ScannedValues[3] < SMiniProg then
						TheEnemy = ScannedValues[4]
						SNodeStage = ScannedValues[2]
						SMiniProg = ScannedValues[3]
					end
				end
			elseif TargetMode == "Last" then
				if ScannedValues[2] <= SNodeStage then
					if ScannedValues[3] > SMiniProg then
						TheEnemy = ScannedValues[4]
						SNodeStage = ScannedValues[2]
						SMiniProg = ScannedValues[3]
					end
				end
			elseif TargetMode == "Close" then
				if ScannedValues[1] < SDistance then
					TheEnemy = ScannedValues[4]
					SDistance = ScannedValues[1]
				end
			elseif TargetMode == "Far" then
				if ScannedValues[1] > SDistance then
					TheEnemy = ScannedValues[4]
					SDistance = ScannedValues[1]
				end
			elseif TargetMode == "Strong" then
				local hum = TheEnemy.Humanoid.Health
				local comparinghum = ScannedValues[4].Humanoid.Health
				if comparinghum > hum then
					TheEnemy = ScannedValues[4]
				end
			elseif TargetMode == "Weak" then
				local hum = TheEnemy.Humanoid.Health
				local comparinghum = ScannedValues[4].Humanoid.Health
				if comparinghum < hum then
					TheEnemy = ScannedValues[4]
				end
			end
		end
	end
	if TheEnemy ~= nil then
		TargetValue.Value = TheEnemy.Torso
		return TheEnemy.Torso
	end
end

function Sit()
	if script.Parent.Humanoid.Sit == true then 
		script.Parent.Humanoid.Jump = true 
		print("Anti Seat Putter!!!")
	end 
end 

script.Parent.Humanoid.Changed:connect(Sit)

local Action = false
local SlashReady = true
local SweepReady = true
local StabReady = true
local SlashCooldown = Cooldowns.S1
local SweepCooldown = Cooldowns.S2
local StabCooldown = Cooldowns.S3

function DoSlash(Enemy)
	if Enemy.Value ~= nil and not Action then
		Action = true
		--Character:SetPrimaryPartCFrame(CFrame.new(Character.PrimaryPart.Position,Enemy.Value.Parent.HumanoidRootPart.Position))
		local SlashAnimation = Humanoid:LoadAnimation(Animations.S1Animation)
		SlashAnimation:Play(nil, nil, Cooldowns.S1Sp.Value) -- Load and play the throwing animation
		SlashAnimation.KeyframeReached:connect(function(Keyframe)
			if Keyframe == "DAMAGE" then
				Action = false
				local HitSound = script.SwordHit:Clone()
				HitSound.Parent = Enemy.Value.Parent.Torso
				HitSound:Play()
				game:GetService("Debris"):AddItem(HitSound, 2.5) 
				local fx = game.ServerStorage.Effects.CombatHit:Clone()
				fx.CFrame = CFrame.new(Enemy.Value.Position)
				fx.Parent = workspace.FX
				DebrisService:AddItem(fx,5)
				local Damage,Critical,Missed = CalculateDamageBind:Invoke(Character,Enemy.Parent,1,1,nil,nil)
				DamageEvent:Fire(Character,Enemy.Value.Parent.Humanoid,Damage,Critical,Missed)
				if Missed == false and Stats.Level.Value >= 5 then
					EffectEvent:Fire(Character,Enemy.Value.Parent,"Bleed",1,25)
				end
			elseif Keyframe == "SlashNow" then
				Torso.SlashSound:Play()
				--[[local fx = game.ServerStorage.Effects.SlashFX:Clone()
				fx.CFrame = CFrame.new(Torso.Position + Character.HumanoidRootPart.CFrame.lookVector*3)
				fx.Parent = workspace.FX
				DebrisService:AddItem(fx,5)--]]
			end
		end)
	end
end

function DoSweep()
	if not Action then
		Action = true
		local function DoDamage()
			for i,v in pairs(workspace.Enemies:GetChildren()) do
				if v:FindFirstChild("Humanoid") and v:FindFirstChild("Torso") then
					local EnemyTorso = v:FindFirstChild("Torso")
					if (EnemyTorso.Position - Torso.Position).magnitude < Stats.Range.Value then
						local Damage,Critical,Missed = CalculateDamageBind:Invoke(Character,v,1,1,nil,nil)
						DamageEvent:Fire(Character,v.Humanoid,Damage,Critical,Missed)
						if Missed == false then
							local fx = game.ServerStorage.Effects.CombatHit:Clone()
							fx.CFrame = CFrame.new(EnemyTorso.Position)
							fx.Parent = workspace.FX
							DebrisService:AddItem(fx,5)
							local HitSound = script.SwordHit:Clone()
							HitSound.Parent = EnemyTorso
							HitSound:Play()
							game:GetService("Debris"):AddItem(HitSound, 2.5) 
							EffectEvent:Fire(Character,v,"Stun",1,50)
							if Stats.Level.Value >= 5 then
								EffectEvent:Fire(Character,v,"Bleed",1,25)
							end
						end
					end
				end
			end
		end
		
		local SweepAnimation = Humanoid:LoadAnimation(Animations.S2Animation)
		SweepAnimation:Play(nil,nil,Cooldowns.S2Sp.Value)
		SweepAnimation.KeyframeReached:connect(function(Keyframe)
			if Keyframe == "Damage" then
				Action = false
				Torso.SweepSound:Play()
				DoDamage()
			end
		end)
	end
end

function DoStab(Enemy)
	if Enemy.Value ~= nil and not Action then
		Action = true
		--Character:SetPrimaryPartCFrame(CFrame.new(Character.PrimaryPart.Position,Enemy.Value.Parent.HumanoidRootPart.Position))
		local StabAnimation = Humanoid:LoadAnimation(Animations.S3Animation)
		StabAnimation:Play(nil, nil, Cooldowns.S3Sp.Value) -- Load and play the throwing animation
		StabAnimation.KeyframeReached:connect(function(Keyframe)
			if Keyframe == "Damage" then
				Action = false
				local HitSound = script.SwordHit:Clone()
				HitSound.Parent = Enemy.Value.Parent.Torso
				HitSound:Play()
				game:GetService("Debris"):AddItem(HitSound, 2.5) 
				local fx = game.ServerStorage.Effects.CombatHit:Clone()
				fx.CFrame = CFrame.new(Enemy.Value.Position)
				fx.Parent = workspace.FX
				DebrisService:AddItem(fx,5)
				local Damage,Critical,Missed = CalculateDamageBind:Invoke(Character,Enemy.Parent,1.5,0.9,nil,nil)
				DamageEvent:Fire(Character,Enemy.Value.Parent.Humanoid,Damage,Critical,Missed)
				if Missed == false then
					EffectEvent:Fire(Character,Enemy.Value.Parent,"Bleed",1,25)
					EffectEvent:Fire(Character,Enemy.Value.Parent,"Target",3,100)
				end
			end
		end)
	end
end

while true do
	wait(0.1)
	local target = FindNearestEnemy(script.Parent.Torso.Position)
	if target ~= nil then
		--script.Parent.Attack.Value = false
		if (target.Position - script.Parent.Torso.Position).magnitude < Stats.Range.Value then 
			script.Parent.Attack.Value = true 
			if SweepReady and Stats.Level.Value >= 3 then
				--do the stuff
				SweepReady = false
				DoSweep()
				delay(SweepCooldown.Value, function()
					SweepReady = true
				end)
			elseif StabReady and Stats.Level.Value >= 5 then
				StabReady = false
				DoStab(TargetValue)
				delay(StabCooldown.Value, function()
					StabReady = true
				end)
			elseif SlashReady then
				SlashReady = false
				DoSlash(TargetValue)
				delay(SlashCooldown.Value, function()
					SlashReady = true
				end)
			end
		else 
			script.Parent.Attack.Value = false 
		end 
	else
		script.Parent.Target.Value = nil
		script.Parent.Attack.Value = false 
	end
end
