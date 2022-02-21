local ReplicatedStorage = game.ReplicatedStorage
local CreateVisual = workspace:WaitForChild("CrateVisual")

local UnitSkins = ReplicatedStorage:WaitForChild("UnitSkins")

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local UserInputService = game:GetService("UserInputService")

local Chest = CreateVisual:WaitForChild("Chest")
local Cameras = CreateVisual:WaitForChild("Camera")
local Display = CreateVisual:WaitForChild("UnitDisplay")

local RootSpawn = Display:WaitForChild("RootSpawn")
local Stand = Display:WaitForChild("Stand")

RootSpawn.Transparency = 1
Stand.Transparency = 1

local Cam = workspace.CurrentCamera

local ContentProvider = game:GetService("ContentProvider")

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local MainUI = PlayerGui:WaitForChild("Main")
local VisualUI = PlayerGui:WaitForChild("VisualUI")

VisualUI.Enabled = false

local CrateFadeFrame = VisualUI.CrateVisual.Fade
local RotationFrame = VisualUI.CrateVisual.Rotation

local SettingsValue = MainUI.Settings.SettingsValue

RotationFrame.Visible = false

local OpenCrateVisual = {}

OpenCrateVisual.Animations = {
	ChestDrop = "rbxassetid://7550445085",
	ChestIdle = "rbxassetid://7551837836",
	
	ChestCrack = "rbxassetid://7550481464",
	
	ChestOpen = "rbxassetid://7550489807",
	ChestOpenIdle = "rbxassetid://7550494156",
}

OpenCrateVisual.Sounds = {
	ChestMusic = "rbxassetid://131326218",
	ChestAchieved = "rbxassetid://131326212",
	
	ChestDrop = "rbxassetid://4621693116",
	
	ChestOpen = "rbxassetid://185499707",
	ChestCrack = "rbxassetid://7536189932",
	
	HammerSwing = "rbxassetid://4059010875",
}

local function TweenCameraPos(Point, Speed)
	TweenService:Create(Cam, TweenInfo.new(Speed, Enum.EasingStyle.Quart), {CFrame = Point}):Play()
end

local function swait(TimeToWait)
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

local function TransparencyModel(model, tran, blacklist)
	local descendants = model:GetDescendants() -- you can use :GetChildren() if there are not BaseParts parented to another BasePart

	for i=1,#descendants do
		local descendant = descendants[i]
		if descendant:IsA("BasePart") then
			if blacklist and not table.find(blacklist, descendant.Name) then
				descendant.Transparency = tran
			elseif not blacklist then
				descendant.Transparency = tran
			end			
		end
	end
end

function OpenCrateVisual.getColorFromRarity(rarity)
	local ParticleColor
	if rarity == "Common" then
		ParticleColor = Color3.fromRGB(165, 165, 165)
	elseif rarity == "Uncommon" then
		ParticleColor = Color3.fromRGB(0, 208, 17)
	elseif rarity == "Rare" then
		ParticleColor = Color3.fromRGB(238, 0, 3)
	elseif rarity == "Epic" then	
		ParticleColor = Color3.fromRGB(184, 0, 245)
	else
		ParticleColor = Color3.fromRGB(244, 208, 0)
	end
	
	return ParticleColor
end

local function CameraCutscene(unit, skin, rarity, isDuplicate)
	CrateFadeFrame.Visible = true
	CrateFadeFrame.BackgroundTransparency = 1
	
	--local newCrate = Chest:Clone()
	--newCrate.Parent = workspace	
	local animation = Instance.new("Animation")
	
	local sound = Instance.new("Sound")
	sound.Parent = VisualUI
	
	local music = Instance.new("Sound")
	music.Parent = VisualUI
	
	local function PlaySound(id)
		sound.SoundId = id
		sound.Volume = SettingsValue.EffectVolume.Value
		sound:Play()
	end
	
	animation.AnimationId = OpenCrateVisual.Animations.ChestIdle	
	local ChestIdle = Chest.AnimationController:LoadAnimation(animation)	
	
	animation.AnimationId = OpenCrateVisual.Animations.ChestDrop
	local ChestDropAnim = Chest.AnimationController:LoadAnimation(animation)

	Cam.CameraType = Enum.CameraType.Scriptable
	Cam.CFrame = Cameras.Cam1.CFrame * CFrame.Angles(math.rad(30), 0, 0)
	
	PlaySound(OpenCrateVisual.Sounds.ChestDrop)
	
	swait(0.4)
	
	TransparencyModel(Chest, 0, {"Hammer", "RootPart"})
	
	TweenCameraPos(Cam.CFrame * CFrame.Angles(math.rad(-30), 0, 0), 2)
	
	ChestDropAnim:Play()
	
	swait(ChestDropAnim.Length-0.1)
	
	ChestIdle:Play()
	
	TweenCameraPos(Cameras.Cam2.CFrame, 1.5)
	
	swait(1.1)
	
	spawn(function()
		music.SoundId = OpenCrateVisual.Sounds.ChestMusic
		music.PlaybackSpeed = 0.8
		music.Volume = SettingsValue.EffectVolume.Value

		music:Play()
	end)

	
	Cam.CFrame = Cameras.Cam3.CFrame
	
	animation.AnimationId = OpenCrateVisual.Animations.ChestCrack
	local ChestCrackAnim = Chest.AnimationController:LoadAnimation(animation)
	
	TweenCameraPos(Cameras.Cam3.CFrame * CFrame.new(-0.9,0,0), 3)
	
	Chest.Hammer.Transparency = 0
	ChestCrackAnim:Play(0.1, 1, 0.65)
	
	spawn(function()
		PlaySound(OpenCrateVisual.Sounds.HammerSwing)
		swait(0.8)
		PlaySound(OpenCrateVisual.Sounds.ChestCrack)
	end)
	
	swait(ChestDropAnim.Length+1.7)
	
	TweenService:Create(Chest.Hammer, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Transparency = 1}):Play()
	
	Chest.Lock.Transparency = 1
	
	swait(0.5)
	
	Cam.CFrame = Cameras.Cam4.CFrame
	swait(0.1)
	
	local CamCloseChestTween
	
	spawn(function()
		CamCloseChestTween = TweenCameraPos(Cam.CFrame * CFrame.new(0,0,-5), 5)
	end)	
	
	animation.AnimationId = OpenCrateVisual.Animations.ChestOpen
	local CheckOpenAnim = Chest.AnimationController:LoadAnimation(animation)
	
	animation.AnimationId = OpenCrateVisual.Animations.ChestOpenIdle
	local CheckOpenIdleAnim = Chest.AnimationController:LoadAnimation(animation)
	
	CheckOpenAnim:Play(0.1,1,1)
	
	sound.SoundId = OpenCrateVisual.Sounds.ChestOpen
	sound:Play()
	
	local ParticleColor = OpenCrateVisual.getColorFromRarity(rarity)
	
	Chest.Base.SmallerStar.Color = ColorSequence.new(ParticleColor,ParticleColor)
	
	Chest.Base.SmallerStar.Enabled = true
	
	swait(CheckOpenAnim.Length-0.1)	
	CheckOpenIdleAnim:Play()
	
	Chest.Base.SmallerStar.Enabled = false
	
	TweenService:Create(
		CrateFadeFrame, -- UI object you're tweening, in this case it's Frame
		TweenInfo.new(1), -- Amount of seconds
		{BackgroundTransparency = 0} -- Goal
	):Play()
	
	swait(1)
	
	Cam.CFrame = Cameras.UnitCam.CFrame
	
	TransparencyModel(Chest, 1)
	
	local Unit = UnitSkins:FindFirstChild(unit)
	local UnitSkin = Unit:FindFirstChild(skin)
	
	local CopiedUnit
	
	if UnitSkin then
		CopiedUnit = UnitSkin["1"]:Clone()
		CopiedUnit.Parent = Display
		CopiedUnit.PrimaryPart.Anchored = true
		CopiedUnit.PrimaryPart.CFrame = Display.RootSpawn.CFrame
		
		if CopiedUnit:FindFirstChild("Hitbox") then
			CopiedUnit.Hitbox.Transparency = 1
		end
		
		local IdleAnim = CopiedUnit.Animations.Idle
		local animationTrack = CopiedUnit.Humanoid:LoadAnimation(IdleAnim)			
		animationTrack:Play()
	end
	
	Display.Stand.Transparency = 0

	swait(1)
	
	TweenService:Create(
		CrateFadeFrame, -- UI object you're tweening, in this case it's Frame
		TweenInfo.new(1), -- Amount of seconds
		{BackgroundTransparency = 1} -- Goal
	):Play()
	
	music.SoundId = OpenCrateVisual.Sounds.ChestAchieved
	music.Volume = SettingsValue.EffectVolume.Value
	music.PlaybackSpeed = 1

	music:Play()
	
	swait(1)
	
	RotationFrame.Visible = true
	
	if isDuplicate then
		RotationFrame.SkinLabel.Duplicate.Visible = true
	else
		RotationFrame.SkinLabel.Duplicate.Visible = false
	end
	
	RotationFrame.SkinLabel.Text = skin .. " (" .. unit .. ")"
	
	
	RotationFrame.SkinLabel.TextColor3 = OpenCrateVisual.getColorFromRarity(rarity)
	
	local RightRotateConnect, LeftRotateConnect
	
	--RotationFrame.Left.MouseButton1Down:Connect(function()
	--	LeftRotateConnect = RunService.Stepped:Connect(function()
	--		CopiedUnit.HumanoidRootPart.CFrame = CopiedUnit.HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(-3),0)
	--	end)
	--end)
	
	--RotationFrame.Right.MouseButton1Down:Connect(function()
	--	RightRotateConnect = RunService.Stepped:Connect(function()
	--		CopiedUnit:SetPrimaryPartCFrame(CopiedUnit.PrimaryPart.CFrame * CFrame.Angles(0,math.rad(3),0))
	--	end)
	--end)
	local UnitRotating, UnitInputStart, UnitInputEnded
	
	local Mouse = Player:GetMouse()
	
	local ButtonsHeld = {} -- Tracks buttons being held. Used to know when dragging
	local LastMousePos = nil  -- Used to calculate how far mouse has moved
	
	UnitRotating = UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then -- runs every time mouse is moved
			if ButtonsHeld["MouseButton1"] then -- makes sure player is holding down right click
				local CurrentMousePos = Vector2.new(Mouse.X,Mouse.Y)
				local change = (CurrentMousePos - LastMousePos)/4 -- calculates distance mouse traveled (/5 to lower sensitivity)
				-- The angles part is weird here because of how the cube happens to be oriented. The angles may differ for other sections
				CopiedUnit:SetPrimaryPartCFrame(CopiedUnit:GetPrimaryPartCFrame() * CFrame.Angles(0,math.rad(change.X),0))

				LastMousePos = CurrentMousePos
			end
		end
	end)
	
	UnitInputStart = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then -- player starts dragging
			LastMousePos = Vector2.new(Mouse.X,Mouse.Y)
			ButtonsHeld["MouseButton1"] = true
		end
	end)
	
	UnitInputEnded = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then -- player stops dragging
			ButtonsHeld["MouseButton1"] = nil
			LastMousePos = nil
		end
	end)
	
	local UserInputTouchStart, UserInputTouchEnd
	
	UserInputTouchStart = UserInputService.TouchStarted:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		if input.UserInputType == Enum.UserInputType.Touch then -- player starts dragging
			LastMousePos = Vector2.new(input.Position.X,input.Position.Y)
			ButtonsHeld["MouseButton1"] = true
		end
	end)
	
	UserInputTouchEnd = UserInputService.TouchStarted:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		if input.UserInputType == Enum.UserInputType.Touch then -- player starts dragging
			LastMousePos = Vector2.new(input.Position.X,input.Position.Y)
			ButtonsHeld["MouseButton1"] = nil
			LastMousePos = nil
		end
	end)
	
	--UserInputService.InputEnded:Connect(function(input)
	--	if input.UserInputType == Enum.UserInputType.MouseButton1 then
	--		if LeftRotateConnect then LeftRotateConnect:Disconnect() end
	--		if RightRotateConnect then RightRotateConnect:Disconnect() end
	--	end
	--end)
	
	RotationFrame.ExitButton.MouseButton1Down:Connect(function()
		sound.PlayOnRemove = true
		sound.SoundId = "rbxassetid://452267918"
		
		for _,v in pairs(Chest.AnimationController:GetPlayingAnimationTracks()) do
			v:Stop()
		end
		
		if UnitRotating then UnitRotating:Disconnect() end
		if UnitInputStart then UnitInputStart:Disconnect() end
		if UnitInputEnded then UnitInputEnded:Disconnect() end
		
		if UserInputTouchStart then UserInputTouchStart:Disconnect() end
		if UserInputTouchEnd then UserInputTouchEnd:Disconnect() end
		
		Display.Stand.Transparency = 1
		CopiedUnit:Destroy()
		sound:Destroy()
		RotationFrame.Visible = false
		VisualUI.Enabled = false
		Cam.CameraType = Enum.CameraType.Custom
		MainUI.Enabled = true
	end)
end

function OpenCrateVisual.init(unit, skin, crate, rarity, isDuplicate)	
	if unit and skin and rarity then
		VisualUI.Enabled = true
		Chest.Base.SmallerStar.Enabled = false
		TransparencyModel(Chest, 1)
		
		Chest["Meshes/ah_Cube.002 (19)"].Color = OpenCrateVisual.getColorFromRarity(crate)
		Chest.Base.Color = OpenCrateVisual.getColorFromRarity(crate)
		
		CameraCutscene(unit, skin, rarity, isDuplicate)	
	end
end

return OpenCrateVisual
