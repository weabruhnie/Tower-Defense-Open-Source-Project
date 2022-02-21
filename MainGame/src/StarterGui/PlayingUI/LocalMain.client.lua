local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local Camera = workspace.CurrentCamera

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local playingUI = script.Parent

playingUI.Enabled = false

local RS = game.ReplicatedStorage
local Modules = RS.Modules
local Events = RS.Events

local LocalEvents = playingUI.Events

local UnitSkins = RS:WaitForChild("UnitSkins")

local UnitsDatabase = require(RS:WaitForChild("Database"):WaitForChild("UnitsDatabase"))

local PlayerInput = require(game.ReplicatedStorage.Modules.UI.PlayerInput)

local SlotsUIs = {}

local playerCurrentData

TargetModes = {
	First = 0,
	Last = 1,
	Closest = 2,
	Strongest = 3,
}

local EffectVolume

function UpdateEffectVol(vol)
	EffectVolume = vol
	
	for k,v in pairs(SlotsUIs) do
		v:setEffectVol(EffectVolume)
	end
	
	for _,d in pairs(workspace:WaitForChild("Map"):WaitForChild("Decorations"):GetDescendants()) do
		if d:IsA("Sound") then
			d.Volume = EffectVolume * 0.07
		end
	end
end

function UpdateSlot()
	if not playerCurrentData then return end
	
	local currentEquipData = playerCurrentData.CurrentEquipped
	
	for _,v in pairs(playingUI.UnitSelection.Main.Slots:GetChildren()) do
		if v:IsA("TextButton") then
			local viewport = v:FindFirstChildWhichIsA("ViewportFrame")

			if viewport then
				viewport:Destroy()
			end

			v.CashCost.Visible = false

			v:SetAttribute("Selected", nil)
		end
	end

	for i=1,#currentEquipData do
		local currentSlot = playingUI.UnitSelection.Main.Slots[i]
		
		local currentUnit = currentEquipData[i]
		
		currentSlot.CashCost.Visible = true

		local viewPort = Instance.new("ViewportFrame")

		viewPort.BackgroundTransparency = 1
		viewPort.Size = UDim2.fromScale(1,1)

		local WorldModel = Instance.new("WorldModel")

		viewPort.Parent = currentSlot
		WorldModel.Parent = viewPort
		
		local currentSkin = playerCurrentData.Inventory[currentUnit].CurrentSkin
		
		currentSlot:SetAttribute("Selected", currentUnit)
		currentSlot:SetAttribute("CurrentSkin", currentSkin)
		
		local ModelUnit	
		if playerCurrentData.Inventory[currentUnit] then
			ModelUnit = UnitSkins:FindFirstChild(currentUnit)[currentSkin]["1"]
		end	

		if ModelUnit then
			local viewportClone = ModelUnit:Clone()

			viewportClone.Parent = WorldModel
			
			if viewportClone:FindFirstChild("Hitbox") then
				viewportClone.Hitbox.Transparency = 1
			end
			
			local animations = viewportClone:FindFirstChild("Animations")

			if animations then
				local animationTrack = viewportClone.Humanoid:LoadAnimation(animations.Idle)			
				animationTrack:Play()
			end	

			local viewportCamera = Instance.new("Camera")
			viewPort.CurrentCamera = viewportCamera

			local cframe = ModelUnit.PrimaryPart.CFrame * CFrame.Angles(0, 0, 0) * CFrame.new(0, 1.5, -2) 
			viewportCamera.CFrame = CFrame.new(cframe.p, ModelUnit.Head.Position) * CFrame.new(0, -1, .5) 
		end
		
		SlotsUIs[i] = require(Modules.Placement.UnitPlacement).init(currentSlot, playingUI)
	end

end

local function ClearAllUnitPlace()
	for i,v in pairs(SlotsUIs) do
		if v.Placing == true then
			v.Placing = false
		end
	end
end

RS.Events.Units.ClearAllPlacing.Event:Connect(ClearAllUnitPlace)

-- Check if player click on a unit

local function checkIfCurrentlyPlacing()
	for i,v in pairs(SlotsUIs) do
		if v.Placing == true then
			return true
		end
	end
	
	return false
end

local UnitHeadUI = Player.PlayerGui:WaitForChild("UnitHeadGUI")
local EnemyHeadUI = Player.PlayerGui:WaitForChild("EnemyHeadGUI")

EnemyHeadUI.Enabled = false
EnemyHeadUI.Adornee = nil

UnitHeadUI.Enabled = false
UnitHeadUI.Adornee = nil

local Mouse = Player:GetMouse()

local raycastParams = RaycastParams.new()
raycastParams.CollisionGroup = "MouseRay"

function isMouseOnUnit(checkOwner)	
	local inset = GuiService:GetGuiInset() 
	local mouseLocation = UserInputService:GetMouseLocation() - inset -- Subtract by the GUI Inset since GetMouseLocation does not take that into account and gives an inaccurate position.

	local cameraRay = Camera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y)

	-- Make a system here that adds filters to the raycastParam.

	local raycastResult = game.Workspace:Raycast(cameraRay.Origin, cameraRay.Direction * 50, raycastParams)

	if raycastResult then
		if raycastResult.Instance.Parent.Parent == workspace.Units then
			local UnitHovered = raycastResult.Instance.Parent		
			
			if checkOwner then
				if UnitHovered:GetAttribute("Owner") == Player.Name then
					return UnitHovered
				else
					return false
				end
			else
				return UnitHovered
			end
			
		end
	end
	
	return false
end

function isMouseOnEnemy()	
	local inset = GuiService:GetGuiInset() 
	local mouseLocation = UserInputService:GetMouseLocation() - inset -- Subtract by the GUI Inset since GetMouseLocation does not take that into account and gives an inaccurate position.

	local cameraRay = Camera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y)

	-- Make a system here that adds filters to the raycastParam.

	local raycastResult = game.Workspace:Raycast(cameraRay.Origin, cameraRay.Direction * 50, raycastParams)

	if raycastResult then
		if raycastResult.Instance.Parent.Parent == workspace.Enemies then
			local EnemyHovered = raycastResult.Instance.Parent		

			return EnemyHovered
		end
	end

	return false
end

local UnitUpgradeUI = playingUI.UnitUpgradesUI

UnitUpgradeUI.Visible = false

local CurrentSelectingUnit = nil

local LevelBarTemp = RS.Templates.UnitTemplate.Lvl

local function showUnitInfo(unitHovered)
	for _,v in pairs(UnitUpgradeUI.LevelBar:GetChildren()) do
		if v:IsA("TextLabel") then v:Destroy() end
	end
	
	unitHovered.Range.Size = Vector3.new(0.25, unitHovered.Range.Size.Y, unitHovered.Range.Size.Z)
	
	UnitUpgradeUI.UpgradeButton.Visible = true
	
	UnitUpgradeUI.SellButton.TextLabel.Text = "Sell ($"..math.floor(tonumber(unitHovered:GetAttribute("TotalCost")) / 2 + 0.5)..")"
	UnitUpgradeUI.SellButton.Visible = false
	
	UnitUpgradeUI.NextUpgrade.Text = ""
	
	if unitHovered:GetAttribute("hasCamo") == true then
		UnitUpgradeUI.Detects.Camo.Visible = true
	else
		UnitUpgradeUI.Detects.Camo.Visible = false
	end
	
	local TargetMode = unitHovered:GetAttribute("TargetMode")
	
	if TargetMode == TargetModes.First then
		UnitUpgradeUI.TargetButton.TextLabel.Text = "First"
	elseif TargetMode == TargetModes.Last then
		UnitUpgradeUI.TargetButton.TextLabel.Text = "Last"
	elseif TargetMode == TargetModes.Strongest then
		UnitUpgradeUI.TargetButton.TextLabel.Text = "Strongest"
	else
		UnitUpgradeUI.TargetButton.TextLabel.Text = "Closest"
	end
	
	UnitUpgradeUI.SellButton.Visible = true
	
	UnitUpgradeUI.UnitName.Text = unitHovered.Name
	UnitUpgradeUI.CurrentLvl.Text = "Level: " .. unitHovered:GetAttribute("LVL") .. "/" .. unitHovered:GetAttribute("MaxLVL")
	
	for i=1, unitHovered:GetAttribute("LVL") do
		local unitLevelbarClone = LevelBarTemp:Clone()
		unitLevelbarClone.Parent = UnitUpgradeUI.LevelBar
		
		unitLevelbarClone.Size = UDim2.fromScale(1/unitHovered:GetAttribute("MaxLVL"),1)
		
		unitLevelbarClone.Visible = true
	end

	if unitHovered:GetAttribute("LVL") == unitHovered:GetAttribute("MaxLVL") then
		UnitUpgradeUI.UpgradeButton.Visible = false
		UnitUpgradeUI.NextUpgrade.Text = "MAXED"
		return
	end
	
	local getNextUpgrade = Events.Units.UnitGetNextUpgrade:InvokeServer(unitHovered:GetAttribute("UnitID"))
	
	if not getNextUpgrade then
		UnitUpgradeUI.UpgradeButton.Visible = false
		UnitUpgradeUI.NextUpgrade.Text = "MAXED"
		return
	end

	local NextUpStats = getNextUpgrade.Stats
	
	UnitUpgradeUI.NextUpgrade.Text = ""
	
	if UnitsDatabase.Units[unitHovered.Name].Mode ~= "Farm" then	
		local lineStart = false
		
		for stat, val in pairs(NextUpStats) do			
			local CurrentStat = unitHovered:GetAttribute(stat)
			
			if CurrentStat then
				if val > tonumber(CurrentStat) then
					if lineStart then
						UnitUpgradeUI.NextUpgrade.Text = UnitUpgradeUI.NextUpgrade.Text .. "\n"
					else
						lineStart = true
					end				
					
					UnitUpgradeUI.NextUpgrade.Text = UnitUpgradeUI.NextUpgrade.Text .. "+" .. val - unitHovered:GetAttribute(stat) .. " " .. stat
				end

				if val < tonumber(CurrentStat) then
					if lineStart then
						UnitUpgradeUI.NextUpgrade.Text = UnitUpgradeUI.NextUpgrade.Text .. "\n"
					else
						lineStart = true
					end	

					UnitUpgradeUI.NextUpgrade.Text = UnitUpgradeUI.NextUpgrade.Text .. val - unitHovered:GetAttribute(stat) .. " " .. stat
				end
			end		
		end
	else
		UnitUpgradeUI.NextUpgrade.Text = "+ $" .. NextUpStats.ATK - unitHovered:GetAttribute("ATK") .. " income/round"
	end	
	
	if getNextUpgrade.CamoDetection then
		UnitUpgradeUI.NextUpgrade.Text = UnitUpgradeUI.NextUpgrade.Text .. "\n+ CAMO DETECTION"
	end
	
	UnitUpgradeUI.UpgradeButton.TextLabel.Text = "Upgrade ($".. getNextUpgrade.Cost .. ")"
	
	UnitUpgradeUI.UpgradeButton.Visible = true
end

local function InteractUnit()
	if CurrentSelectingUnit then
		CurrentSelectingUnit.Range.Size = Vector3.new(0.25, CurrentSelectingUnit.Range.Size.Y, CurrentSelectingUnit.Range.Size.Z)
		
		CurrentSelectingUnit.Range.CastShadow = false
		CurrentSelectingUnit.Range.Transparency = 0.5

		UnitUpgradeUI.Visible = true	
		UnitUpgradeUI.UpgradeButton.Visible = false
		
		showUnitInfo(CurrentSelectingUnit)	
	end
end

local inputType, inputEnum = PlayerInput.getInputType()

if inputType == "Keyboard/Mouse" then
	local mouseMove = UserInputService.InputChanged:Connect(function(input)
		UnitHeadUI.Enabled = false
		EnemyHeadUI.Enabled = false

		if checkIfCurrentlyPlacing() then return end

		local unitHovered = isMouseOnUnit()

		local enemyHovered = isMouseOnEnemy()

		if unitHovered then
			for _,v in pairs(UnitHeadUI.Frame.LevelBar:GetChildren()) do
				if v:IsA("TextLabel") then v:Destroy() end
			end
			
			UnitHeadUI.Enabled = true
			UnitHeadUI.Adornee = unitHovered.PrimaryPart

			UnitHeadUI.Frame.UnitName.Text = unitHovered.Name

			UnitHeadUI.Frame.Owner.Text = "Owner: " .. unitHovered:GetAttribute("Owner")

			UnitHeadUI.Frame.Level.Text = "Level: " .. unitHovered:GetAttribute("LVL")
			
			for i=1, unitHovered:GetAttribute("LVL") do
				local unitLevelbarClone = LevelBarTemp:Clone()
				unitLevelbarClone.Parent = UnitHeadUI.Frame.LevelBar

				unitLevelbarClone.Size = UDim2.fromScale(1/unitHovered:GetAttribute("MaxLVL"),1)

				unitLevelbarClone.Visible = true
			end

			UnitHeadUI.Frame.ATK.Amt.Text = unitHovered:GetAttribute("ATK")
			UnitHeadUI.Frame.RNG.Amt.Text = unitHovered:GetAttribute("RNG")
			UnitHeadUI.Frame.SPD.Amt.Text = unitHovered:GetAttribute("SPD")
		end

		if enemyHovered then
			EnemyHeadUI.Enabled = true
			EnemyHeadUI.Adornee = enemyHovered.PrimaryPart

			EnemyHeadUI.Frame.EnemName.Text = enemyHovered:GetAttribute("EnemyName")

			local health = math.clamp(enemyHovered:GetAttribute("CurrentHP") / enemyHovered:GetAttribute("HP"), 0, 1) --Maths

			EnemyHeadUI.Frame.HPBar.Fill.Size = UDim2.fromScale(health, 1)
			EnemyHeadUI.Frame.HPBar.HPText.Text = enemyHovered:GetAttribute("CurrentHP") .. "/" .. enemyHovered:GetAttribute("HP")
		end
	end)
	
	local unitMouseClick = Mouse.Button1Down:Connect(function()
		for _,unit in pairs(workspace:WaitForChild("Units"):GetChildren()) do
			local foundRange = unit:FindFirstChild("Range")

			if foundRange then
				foundRange.Transparency = 1
			end

		end

		local GUIs = Player.PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y) 

		local inGui = table.find(GUIs, UnitUpgradeUI)

		if CurrentSelectingUnit then	
			if not inGui then			
				CurrentSelectingUnit = nil
			end

		end

		UnitUpgradeUI.Visible = false

		if checkIfCurrentlyPlacing() then return end

		local unitHovered = isMouseOnUnit(true)	

		if unitHovered then
			CurrentSelectingUnit = unitHovered
			InteractUnit()
		end

		if inGui then
			UnitUpgradeUI.Visible = true
		end
	end)
	
elseif inputType == "Touch" then
	
	local unitMouseTouchTap = UserInputService.TouchTapInWorld:Connect(function(position, processedByUI)	
		for _,unit in pairs(workspace:WaitForChild("Units"):GetChildren()) do
			local foundRange = unit:FindFirstChild("Range")

			if foundRange then
				foundRange.Transparency = 1
			end

		end

		local GUIs = Player.PlayerGui:GetGuiObjectsAtPosition(position.X, position.Y) 

		local inGui = table.find(GUIs, UnitUpgradeUI)

		if CurrentSelectingUnit then	
			if not inGui then			
				CurrentSelectingUnit = nil
			end

		end

		UnitUpgradeUI.Visible = false

		if checkIfCurrentlyPlacing() then return end

		local unitHovered = isMouseOnUnit(true)	

		if unitHovered then
			CurrentSelectingUnit = unitHovered
			InteractUnit()
		end

		if inGui then
			UnitUpgradeUI.Visible = true
		end
	end)
	
end

local UnitsFolder = workspace:WaitForChild("Units")
local EnemiesFolder = workspace:WaitForChild("Enemies")

LocalEvents.JustPlacedInteract.Event:Connect(function(unitID)
	for _,unit in pairs(UnitsFolder:GetChildren()) do
		if unit:IsA("Model") then
			if unit:GetAttribute("UnitID") == unitID then
				CurrentSelectingUnit = unit
				InteractUnit()
			end
		end
	end
end)

local NotificationTemp = playingUI.NotificationsFrame.NotifyTemp
NotificationTemp.Parent = nil

function Notify(text)
	if not text then return end
	
	local NotifiClone = NotificationTemp:Clone()

	NotifiClone.Parent = playingUI.NotificationsFrame

	NotifiClone.Text = text
	NotifiClone.Visible = true

	coroutine.wrap(function()
		wait(5)
		NotifiClone:Destroy()
	end)()
end

local saveCurrentID

local Upgrading, Selling, Targeting = false, false, false

local SoundService = game:GetService("SoundService")
local SFX = Instance.new("Sound")

SFX.Name = "SFX"
SFX.Parent = SoundService

UnitUpgradeUI.UpgradeButton.MouseButton1Click:Connect(function()
	if Upgrading then return end
	
	if CurrentSelectingUnit then
		Upgrading = true	
		
		saveCurrentID = CurrentSelectingUnit:GetAttribute("UnitID")
		local Upgrade, ErrorMsg = Events.Units.UpgradeUnit:InvokeServer(saveCurrentID)
		
		if EffectVolume then
			SFX.Volume = EffectVolume
		end
	
		if Upgrade then
			SFX.Volume = EffectVolume/3
			SFX.SoundId = "rbxassetid://2686079706"	
		else
			SFX.SoundId = "rbxassetid://654933750"
			Notify(ErrorMsg)
		end
		
		SFX:Play()
		
		Upgrading = false
	end
end)

UnitUpgradeUI.SellButton.MouseButton1Click:Connect(function()
	if Selling then return end
	
	if CurrentSelectingUnit then
		
		Selling = true
		
		if EffectVolume then
			SFX.Volume = EffectVolume
		end
		
		SFX.SoundId = "rbxassetid://1825260752"
		SFX:Play()
		
		saveCurrentID = CurrentSelectingUnit:GetAttribute("UnitID")
		local SellingInvoke = Events.Units.SellUnit:InvokeServer(saveCurrentID)
		
		if SellingInvoke then
			UnitUpgradeUI.Visible = false
			Selling = false
		end
		
	end
end)

UnitUpgradeUI.TargetButton.MouseButton1Click:Connect(function()
	if Targeting then return end
	
	if CurrentSelectingUnit then
		Targeting = true
		
		saveCurrentID = CurrentSelectingUnit:GetAttribute("UnitID")
		Events.Units.ChangeTargetUnit:InvokeServer(saveCurrentID)
		
		Targeting = false
	end
end)

playingUI.Others.IncomeNotify.Visible = false

local countdownCashBonus

Events.Players.Eco.BonusCash.OnClientEvent:Connect(function(bonusCash)
	if countdownCashBonus then countdownCashBonus:Disconnect() end

	playingUI.Others.IncomeNotify.Visible = true

	playingUI.Others.IncomeNotify.TextLabel.Text = "Wave Bonus: $" .. bonusCash

	local timeConsumed = 0
	
	countdownCashBonus = RunService.RenderStepped:Connect(function(deltaStep)
		timeConsumed += deltaStep
		if (timeConsumed >= 5) then
			playingUI.Others.IncomeNotify.Visible = false
			countdownCashBonus:Disconnect()
		end
	end)
end)

Events.Players.IntCash.OnClientEvent:Connect(function(localCashVal)
	if not localCashVal then return end
	
	playingUI.UnitSelection.CashAmt.Text = "$" .. localCashVal.Value
	
	localCashVal.Changed:Connect(function(newCashVal)
		playingUI.UnitSelection.CashAmt.Text = "$" .. newCashVal
	end)	
end)

Events.Units.UpdateUnitUI.OnClientEvent:Connect(function(unitChose)
	if saveCurrentID and saveCurrentID == unitChose:GetAttribute("UnitID") then
		CurrentSelectingUnit = unitChose
		
		unitChose.Range.CastShadow = false
		unitChose.Range.Transparency = 0.5
		unitChose.Range.Size = Vector3.new(0.25, unitChose.Range.Size.Y, unitChose.Range.Size.Z)
		
		showUnitInfo(unitChose)
	end
end)

-- Notification
Events.Notify.ReceiveNotif.OnClientEvent:Connect(Notify)
Events.Notify.SendNotif.Event:Connect(Notify)

-- Voting system

local MapFound = workspace:WaitForChild("Map")
local MapValues = MapFound:WaitForChild("Values")

local VoteTimer = MapValues:WaitForChild("VoteTimer")

local VotingFrame = playingUI.VotingFrame
VotingFrame.Visible = false

function reset_voting_frame()
	for _,voteButton in pairs(VotingFrame.VotingList.Votes:GetChildren()) do
		if voteButton:IsA("TextButton") then
			voteButton.TotalVoted.Text = 0
		end
	end
end

reset_voting_frame()

Events.Setup.VoteDiff.OnClientEvent:Connect(function(diffList)
	reset_voting_frame()
	
	for diff, playerList in pairs(diffList) do
		VotingFrame.VotingList.Votes[diff].TotalVoted.Text = #playerList
	end	
end)
	
for _,voteButton in pairs(VotingFrame.VotingList.Votes:GetChildren()) do
	if voteButton:IsA("TextButton") and voteButton.Name ~= "VoteEx" then
		voteButton.MouseButton1Down:Connect(function()
			if VoteTimer.Value > -1 then
				Events.Setup.VoteDiff:FireServer(voteButton.Name)
			end		
		end)
	end
end

-- Dialog System
local AnimateUI = require(RS.Modules.UI.AnimateUI)

local DialogFrame = playingUI.Dialog
DialogFrame.Visible = false

local RunService = game:GetService("RunService")

local countdownTilRemoveDialog

local currentText

Events.Players.DialogSend.OnClientEvent:Connect(function(subject, text, readTime)	
	currentText = text
	
	DialogFrame.Visible = true
	
	DialogFrame.Subject.Text = subject
	
	AnimateUI.typeWrite(DialogFrame.SpeakText, text, 0.03)
	
	coroutine.wrap(function()
		local oldText = text
		wait(readTime)
		
		if oldText ~= currentText then return end
		DialogFrame.Visible = false
	end)()
	
end)

local TopFrame = playingUI.TopFrame
TopFrame.Visible = false

local CurrentWave = MapValues:WaitForChild("CurrentWave")
local MapTimer = MapValues:WaitForChild("MapTimer")
local WaitingTimer = MapValues:WaitForChild("WaitingTimer")

local VoteSkipRound = MapValues:WaitForChild("VoteSkipRound")

local function digital_format(n)
	return string.format("%d:%02d", math.floor(n/60), n%60)
end

VoteTimer:GetPropertyChangedSignal("Value"):Connect(function()
	VotingFrame.Visible = true

	VotingFrame.VotingLabel.Text = 'Game Difficulty Voting (Time Remaining: ' .. VoteTimer.Value .. ' seconds)'

	if VoteTimer.Value <= -1 then
		VotingFrame.Visible = false
	end
end)

CurrentWave:GetPropertyChangedSignal("Value"):Connect(function()
	TopFrame.Visible = true	
	TopFrame.WaveLabel.Text = "Wave " .. CurrentWave.Value
end)

MapTimer:GetPropertyChangedSignal("Value"):Connect(function()
	TopFrame.Visible = true	
	TopFrame.Timer.Text = digital_format(MapTimer.Value)
end)

WaitingTimer:GetPropertyChangedSignal("Value"):Connect(function()
	TopFrame.Visible = true
	
	TopFrame.WaveLabel.Text = 'Waiting for players...'
	TopFrame.Timer.Text = digital_format(WaitingTimer.Value)

	if WaitingTimer.Value <= -1 then
		TopFrame.Visible = false
	end
end)

local SkipVoteFrame = playingUI.Others.SkipVoteFrame
SkipVoteFrame.Visible = false

local VotingSkip = false

local function SkipRoundShow()
	if VoteSkipRound.Value then
		VotingSkip = true
		SkipVoteFrame.Visible = true
	else
		VotingSkip = false
		SkipVoteFrame.Visible = false
	end
end

SkipVoteFrame.Yes.MouseButton1Down:Connect(function()
	if VotingSkip then
		SkipVoteFrame.Visible = false
		Events.Players.VoteActivate:FireServer()
	end
end)

SkipVoteFrame.No.MouseButton1Down:Connect(function()
	SkipVoteFrame.Visible = false
end)

Events.Players.VoteActivate.OnClientEvent:Connect(function(numVoted)
	if VotingSkip then
		SkipVoteFrame.TitleLabel.Text = "Skip Wave? (" .. numVoted .. "/" .. #Players:GetPlayers() .. ")"
	end
end)

local GameLostVal = MapValues:WaitForChild("GameLost")

Events.Game.GameLostActivate.OnClientEvent:Connect(function()
	if GameLostVal.Value then
		playingUI.Enabled = false
	end	
end)

SkipRoundShow()

VoteSkipRound:GetPropertyChangedSignal("Value"):Connect(SkipRoundShow)

-- SOUND DETECTION
local SettingsToggle = playingUI.ToggleButtons.Others.SettingsToggleButton

local SettingsFolder = playingUI.Settings
local SettingsFrame = SettingsFolder.SettingsFrame
local SettingsValue = SettingsFolder.SettingsValue

SettingsFrame.Visible = false

local GameplayMusic = MapFound:WaitForChild("Music")

local function PlayBGMusic()
	if playerCurrentData then
		SettingsValue.MusicVolume.Value = playerCurrentData.SettingsData.MusicVolume
		
		local Scale = playerCurrentData.SettingsData.MusicVolume / 1.02564102564

		SettingsFrame.List.MusicSlider.ToggleSlide.Position = UDim2.new(Scale-0.01, 0, 0.5, 0)
		SettingsFrame.List.MusicSlider.Fill.Size = UDim2.fromScale(Scale, 1)

		SettingsFrame.List.MusicSlider.VolumeLabel.Text = "Music Volume (" .. math.floor(playerCurrentData.SettingsData.MusicVolume*100 + 0.5) .. "%)"	

		GameplayMusic.Gameplay.Volume = SettingsValue.MusicVolume.Value
	end
end

local function UpdateEffect()
	if playerCurrentData then
		SettingsValue.EffectVolume.Value = playerCurrentData.SettingsData.EffectVolume
		
		UpdateEffectVol(playerCurrentData.SettingsData.EffectVolume)
		
		local Scale = playerCurrentData.SettingsData.EffectVolume / 1.02564102564

		SettingsFrame.List.EffectSlider.ToggleSlide.Position = UDim2.new(Scale-0.01, 0, 0.5, 0)
		SettingsFrame.List.EffectSlider.Fill.Size = UDim2.fromScale(Scale, 1)

		SettingsFrame.List.EffectSlider.VolumeLabel.Text = "Effect Volume (" .. math.floor(playerCurrentData.SettingsData.EffectVolume*100 + 0.5) .. "%)"
	end
end

function UpdateSounds()
	if not playerCurrentData then return end

	UpdateEffect()
	PlayBGMusic()
end

local ContentProvider = game:GetService("ContentProvider")

local LoadedSounds = {}

UnitsFolder.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Sound") and EffectVolume then
		
		spawn(function()
			if not table.find(LoadedSounds, descendant.SoundId) then
				table.insert(LoadedSounds,descendant.SoundId)
				ContentProvider:PreloadAsync({descendant})
			end
		end)		
		
		descendant.Volume = descendant.Volume * EffectVolume
	end 
end)

EnemiesFolder.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Sound") and EffectVolume then
		
		spawn(function()
			if not table.find(LoadedSounds, descendant.SoundId) then
				table.insert(LoadedSounds,descendant.SoundId)
				ContentProvider:PreloadAsync({descendant})
			end
		end)
		
		descendant.Volume = descendant.Volume * EffectVolume
	end 
end)

local function ZipSettings()
	local SettingsZip = {}

	for _,setting in pairs(SettingsValue:GetChildren()) do
		if not SettingsZip[setting.Name] then
			SettingsZip[setting.Name] = setting.Value
		end
	end

	return SettingsZip
end

SettingsToggle.MouseButton1Down:Connect(function()
	if not SettingsFrame.Visible then
		SettingsFrame.Visible = true
	else
		SettingsFrame.Visible = false

		local SettingsZip = ZipSettings()
		Events.Settings.SaveGlobalSetting:FireServer(SettingsZip)
	end
end)

SettingsFrame.DoneButton.MouseButton1Down:Connect(function()
	if SettingsFrame.Visible then
		SettingsFrame.Visible = false

		local SettingsZip = ZipSettings()
		Events.Settings.SaveGlobalSetting:FireServer(SettingsZip)
	end
end)

function UpdateVolumeBar()
	local MousePos = UserInputService:GetMouseLocation().X
	local SliderSize = SettingsFrame.List.MusicSlider.AbsoluteSize.X
	local SliderPos = SettingsFrame.List.MusicSlider.AbsolutePosition.X

	local Scale = math.clamp(((MousePos-SliderPos)/SliderSize),0,0.975)

	SettingsFrame.List.MusicSlider.ToggleSlide.Position = UDim2.new(Scale-0.01, 0, 0.5, 0)

	local ToVolume = Scale * 1.02564102564

	SettingsValue.MusicVolume.Value = ToVolume
	
	GameplayMusic.Gameplay.Volume = ToVolume

	SettingsFrame.List.MusicSlider.Fill.Size = UDim2.fromScale(Scale, 1)

	SettingsFrame.List.MusicSlider.VolumeLabel.Text = "Music Volume (" .. math.floor(ToVolume*100 + 0.5) .. "%)"
end

function UpdateEffectBar()
	local MousePos = UserInputService:GetMouseLocation().X
	local SliderSize = SettingsFrame.List.EffectSlider.AbsoluteSize.X
	local SliderPos = SettingsFrame.List.EffectSlider.AbsolutePosition.X

	local Scale = math.clamp(((MousePos-SliderPos)/SliderSize),0,0.975)

	SettingsFrame.List.EffectSlider.ToggleSlide.Position = UDim2.new(Scale-0.01, 0, 0.5, 0)

	local ToVolume = Scale * 1.02564102564

	SettingsValue.EffectVolume.Value = ToVolume

	SettingsFrame.List.EffectSlider.Fill.Size = UDim2.fromScale(Scale, 1)
	
	UpdateEffectVol(ToVolume)

	SettingsFrame.List.EffectSlider.VolumeLabel.Text = "Effect Volume (" .. math.floor(ToVolume*100 + 0.5) .. "%)"
end

local HoldingMusicSlider, HoldingEffectSlider = false, false

RunService.RenderStepped:Connect(function()
	if HoldingMusicSlider then
		UpdateVolumeBar()
	end

	if HoldingEffectSlider then
		UpdateEffectBar()
	end 
end)

SettingsFrame.List.MusicSlider.ToggleSlide.MouseButton1Down:Connect(function()
	HoldingMusicSlider = true
end)

SettingsFrame.List.EffectSlider.ToggleSlide.MouseButton1Down:Connect(function()
	HoldingEffectSlider = true
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if HoldingMusicSlider then HoldingMusicSlider = false end
		if HoldingEffectSlider then 
			
			if EffectVolume then
				SFX.Volume = EffectVolume
			end
			
			SFX.SoundId = "rbxassetid://405321226"
			SFX:Play()
			HoldingEffectSlider = false
		end
	end
end)

UserInputService.TouchEnded:Connect(function(touch, gameProcessedEvent)
	if HoldingMusicSlider then HoldingMusicSlider = false end
	if HoldingEffectSlider then
		
		if EffectVolume then
			SFX.Volume = EffectVolume
		end
		
		SFX.SoundId = "rbxassetid://405321226"
		SFX:Play()
		
		HoldingEffectSlider = false 
	end
end)

--loading player data

Events.Saves.LoadPlayer.OnClientEvent:Connect(function(plr_data)
	if GameLostVal.Value then
		playingUI.Enabled = false
	else
		playingUI.Enabled = true
	end
	
	playerCurrentData = plr_data
	
	UpdateSlot()	
	UpdateSounds()
end)
