local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local MainUI = script.Parent

MainUI.Enabled = false

local QueueUI = MainUI.Queue

local RS = game:GetService("ReplicatedStorage")
local Events = RS.Events

local Database = RS:WaitForChild("Database")

local UnitSkins = RS:WaitForChild("UnitSkins")

local Modules = game.ReplicatedStorage.Modules

local LootManager = require(Modules.LootManager)

local LayoutUtil = require(Modules.LayoutUtil)
local SPList = require(Modules.SPList)

local UnitsDatabase = require(Database:WaitForChild("UnitsDatabase"))
local CratesDatabase = require(Database:WaitForChild("CratesDatabase"))

local OpenCrateVisual = require(Modules.OpenCrateVisual)

local playerCurrentData

-- PREVENT GUIS
repeat
	local success, failure = pcall(function()
		game.StarterGui:SetCore("ResetButtonCallback", false)
	end)
	wait()
until success

--SETTINGS
local SettingsToggle = MainUI.ToggleButtons.Others.SettingsToggleButton

local SettingsFolder = MainUI.Settings
local SettingsFrame = SettingsFolder.SettingsFrame
local SettingsValue = SettingsFolder.SettingsValue

-- SFX
local sfx = Instance.new("Sound", SoundService)
sfx.Name = "SFX"

local function PlaySFX(soundID)
	sfx.Volume = SettingsValue.EffectVolume.Value
	sfx.SoundId = soundID
	sfx:Play()
end

-- EXTRA FUNCITONS

-- QUEUES

Events.Queues.PlayerEntered.OnClientEvent:Connect(function(area)
	QueueUI.Leave.Visible = true
	
	QueueUI.Leave.Active = true
	
	QueueUI.Leave.Activated:Connect(function()
		QueueUI.Leave.Active = false
		QueueUI.Leave.Visible = false
		
		Events.Queues.PlayerLeaving:FireServer(area)		
	end)
end)

local ToggleButtons = MainUI.ToggleButtons

-- Inventory
local Inventory = MainUI.Inventory

local UnitInv_Temp = Inventory.MainFrame.ScrollingFrame.UnitTemplate
UnitInv_Temp.Parent = nil

local CrateInv_Temp = Inventory.MainFrame.ScrollingFrame.CrateTemplate
CrateInv_Temp.Parent = nil

local SpinningConnection
local SpinningConnection2

local current_unit_selected = nil

local Equipping = false

local menus = SPList:new()

local InventoryPage = {
	Units = 0,
	Crates = 1,
	Skins = 2,
}

local CurrentInvPage = InventoryPage.Units

local ShopPage = {
	Units = 0,
	Crates = 1,
}

local CurrentShopPage = ShopPage.Units

local function push_gui(gui)
	if menus:contains(gui) then
		menus:remove(gui)
	end
	
	menus:push_front(gui)
	
	gui.Visible = true
	
	for i=2,menus:count() do
		menus:get(i).Visible = false
	end
	
	
end

function UpdateSlot()	
	if not playerCurrentData or not playerCurrentData.CurrentEquipped then return end
	
	local currentEquipData = playerCurrentData.CurrentEquipped
	
	for _,v in pairs(MainUI.Inventory.UnitSelection.Main.Slots:GetChildren()) do
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
		local currentSlot = MainUI.Inventory.UnitSelection.Main.Slots[i]
		
		local currentUnit = currentEquipData[i]

		local viewPort = Instance.new("ViewportFrame")
		
		viewPort.BackgroundTransparency = 1
		viewPort.Size = UDim2.fromScale(1,1)

		local WorldModel = Instance.new("WorldModel")

		viewPort.Parent = currentSlot
		WorldModel.Parent = viewPort
		
		currentSlot:SetAttribute("Selected", currentUnit)
		
		local unitInfo = UnitsDatabase.find(currentUnit)
		currentSlot.CashCost.Text = "$" .. unitInfo.Cost
		currentSlot.CashCost.Visible = true

		local ModelUnit = UnitSkins:FindFirstChild(currentUnit)[playerCurrentData.Inventory[currentUnit].CurrentSkin]["1"]

		if ModelUnit then
			local viewportClone = ModelUnit:Clone()

			viewportClone.Parent = WorldModel
			
			if viewportClone:FindFirstChild("Hitbox") then
				viewportClone.Hitbox.Transparency = 1
			end
			
			viewportClone.PrimaryPart.Anchored = true

			local animations = viewportClone:FindFirstChild("Animations")

			if animations then
				local animationTrack = viewportClone.Humanoid:LoadAnimation(animations.Idle)			
				animationTrack:Play()
			end	

			local viewportCamera = Instance.new("Camera")
			viewPort.CurrentCamera = viewportCamera

			viewportCamera.Parent = WorldModel
			
			local cframe = ModelUnit.PrimaryPart.CFrame * CFrame.Angles(0, 0, 0) * CFrame.new(0, 1.5, -2) 
			viewportCamera.CFrame = CFrame.new(cframe.p, ModelUnit.Head.Position) * CFrame.new(0, -1, .5) 
		end
	end

end

function isUnitEquipped(unit)
	for _,v in pairs(MainUI.Inventory.UnitSelection.Main.Slots:GetChildren()) do
		if v:IsA("TextButton") then			
			if v:GetAttribute("Selected") == unit then
				return true
			end
		end
	end
	
	return false
end

Inventory.MainFrame.Visible = false
Inventory.SkinsFrame.Visible = false

local inv_origpos = Inventory.MainFrame.Position

local InvToggleButton = ToggleButtons.Main.InvToggleButton

InvToggleButton.MouseButton1Down:Connect(function()	
	if not Inventory.MainFrame.Visible then
		push_gui(Inventory.MainFrame)	
	else	
		Inventory.MainFrame.Visible = false
	end	
end)

function reset_inv_info()
	for _,model in pairs(Inventory.MainFrame.Info.ViewportFrame.WorldModel:GetChildren()) do
		model:Destroy()
	end
	
	Inventory.MainFrame.Info.UnitName.Text = ""
	Inventory.MainFrame.Info.Stats.Text = ""
	
	Inventory.MainFrame.Info.Equip.Visible = false
	Inventory.MainFrame.Info.Skins.Visible = false

	Inventory.MainFrame.Info.OpenCrate.Visible = false
end

function reset_inv_list()
	for _,v in pairs(Inventory.MainFrame.ScrollingFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
end

reset_inv_info()
reset_inv_list()

LayoutUtil.new(Inventory.MainFrame.ScrollingFrame.UIGridLayout)

function Setup_UnitInventory()
	PlaySFX(RS.Sounds.SFX.TabClick.SoundId)
	
	if CurrentInvPage ~= InventoryPage.Units then
		reset_inv_info()
	end
	
	CurrentInvPage = InventoryPage.Units
	
	if not playerCurrentData then return end
	
	reset_inv_list()
	
	local inv_data = playerCurrentData.Inventory
	
	Inventory.MainFrame.ScrollingFrame.UIGridLayout.SortOrder = Enum.SortOrder.Name
	
	for unitName, currentSkin in pairs(inv_data) do
		local findUnit = UnitsDatabase.find(unitName)
		
		if findUnit then
			
			local unitEle = UnitInv_Temp:Clone()
			unitEle.Parent = Inventory.MainFrame.ScrollingFrame
			unitEle.Name = unitName
			
			unitEle.UnitLabel.Text = unitName
			
			local ModelUnit = UnitSkins:FindFirstChild(unitName)[inv_data[unitName].CurrentSkin]["1"]
			
			if ModelUnit then
				local WorldModel = Instance.new("WorldModel")
				WorldModel.Parent = unitEle.ViewportFrame
				
				local viewportClone = ModelUnit:Clone()
				
				viewportClone.PrimaryPart.Anchored = true
				
				if viewportClone:FindFirstChild("Hitbox") then
					viewportClone.Hitbox.Transparency = 1
				end
				
				viewportClone.Parent = WorldModel

				local animations = viewportClone:FindFirstChild("Animations")

				if animations then
					local animationTrack = viewportClone.Humanoid:LoadAnimation(animations.Idle)			
					animationTrack:Play()
				end	
				
				local viewportCamera = Instance.new("Camera")
				unitEle.ViewportFrame.CurrentCamera = viewportCamera
			
				viewportCamera.Parent = WorldModel
				
				local cframe = ModelUnit.PrimaryPart.CFrame * CFrame.Angles(0, 0, 0) * CFrame.new(0, 1.5, -2) 
				viewportCamera.CFrame = CFrame.new(cframe.p, ModelUnit.Head.Position) * CFrame.new(0, -1, .5)
				
				if playerCurrentData then
					if table.find(playerCurrentData.CurrentEquipped, unitName) then
						unitEle.Equipped.Visible = true
					else
						unitEle.Equipped.Visible = false
					end
				end
			end
			
			unitEle.MouseButton1Down:Connect(function()
				reset_inv_info()
				
				PlaySFX(RS.Sounds.SFX.ItemClick.SoundId)
				
				current_unit_selected = unitName
				
				Inventory.MainFrame.Info.UnitName.Text = unitName

				Inventory.MainFrame.Info.Stats.Text = "Starting Cost: " .. findUnit.Cost
				
				if findUnit.Type ~= "Farm" then
					Inventory.MainFrame.Info.Stats.Text = Inventory.MainFrame.Info.Stats.Text .. "\nInitial ATK: " .. findUnit.Upgrades[1].Stats.ATK
					Inventory.MainFrame.Info.Stats.Text = Inventory.MainFrame.Info.Stats.Text .. "\nInitial RNG: " .. findUnit.Upgrades[1].Stats.RNG
					Inventory.MainFrame.Info.Stats.Text = Inventory.MainFrame.Info.Stats.Text .. "\nInitial SPD: " .. findUnit.Upgrades[1].Stats.SPD
				else
					Inventory.MainFrame.Info.Stats.Text = Inventory.MainFrame.Info.Stats.Text .. "\nInitial Income: " .. findUnit.Upgrades[1].Stats.ATK
				end	
				
				local infoUnitClone = ModelUnit:Clone()
				
				infoUnitClone.Parent = Inventory.MainFrame.Info.ViewportFrame.WorldModel
				
				infoUnitClone.PrimaryPart.Anchored = true
				
				if infoUnitClone:FindFirstChild("Hitbox") then
					infoUnitClone.Hitbox.Transparency = 1
				end
				
				local animations = infoUnitClone:FindFirstChild("Animations")

				if animations then
					local animationTrack = infoUnitClone.Humanoid:LoadAnimation(animations.Idle)			
					animationTrack:Play()
				end	
				
				local viewportInfoCamera = Instance.new("Camera")
				Inventory.MainFrame.Info.ViewportFrame.CurrentCamera = viewportInfoCamera
				
				viewportInfoCamera.Parent = Inventory.MainFrame.Info.ViewportFrame.WorldModel		
				
				local c = 0;
				
				if SpinningConnection then SpinningConnection:Disconnect() end
				
				coroutine.wrap(function()
					SpinningConnection = RunService.RenderStepped:Connect(function(step)
						local cframe = ModelUnit.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(c), 0) * CFrame.new(0, 1.5, -2) 
						--  Change the angles accordingly, and the -5 should be distance from the objects center outwards.
						-- Once you have that, you want to take that position and have it face the position of the sword, and then set the Viewport's camera cframe to that new cframe.
						cframe = CFrame.new(cframe.p, ModelUnit.Head.Position) * CFrame.new(0, -1, .5) 
						viewportInfoCamera.CFrame = cframe;

						c += 1.15;
					end)		
				end)()
				
				Inventory.MainFrame.Info.Equip.Visible = true	
				Inventory.MainFrame.Info.Skins.Visible = true
				
				if isUnitEquipped(unitName) then
					Inventory.MainFrame.Info.Equip.Text = "Unequip"
				else
					Inventory.MainFrame.Info.Equip.Text = "Equip"
				end
			end)
		end
	end
end

local current_crate_selected = nil


function Setup_CratesInventory()
	PlaySFX(RS.Sounds.SFX.TabClick.SoundId)
	
	CurrentInvPage = InventoryPage.Crates
	
	if not playerCurrentData then return end
	
	reset_inv_info()
	reset_inv_list()
	
	local inv_crate_data = playerCurrentData.CratesInventory
	
	for i,crateName in pairs(inv_crate_data) do
		
		if CratesDatabase.Crates[crateName] then
			local crateInvClone = CrateInv_Temp:Clone()
			
			crateInvClone.Parent = Inventory.MainFrame.ScrollingFrame
			crateInvClone.Name = crateName
			
			crateInvClone.CrateLabel.Text = crateName
			
			crateInvClone.MouseButton1Down:Connect(function()
				current_crate_selected = {Name = crateName, Index = i}
				
				reset_inv_info()
				
				PlaySFX(RS.Sounds.SFX.ItemClick.SoundId)
				
				Inventory.MainFrame.Info.UnitName.Text = crateName
				
				if CratesDatabase.Crates[crateName] then
					local currentCrate = CratesDatabase.Crates[crateName]
					
					local ChancesTable = LootManager:GetChances(currentCrate.Percentage)

					local ChanceList = {}

					for rarity, v in pairs(ChancesTable) do
						table.insert(ChanceList, {Rarity = rarity, Chance = v.Chance})
					end

					table.sort(ChanceList,
						function(a,b)
							return CratesDatabase.getOrderRarity(a.Rarity) < CratesDatabase.getOrderRarity(b.Rarity)
						end
					)
					
					for i=1, #ChanceList do
						local currentSlot = ChanceList[i]
						
						local RarityColor = OpenCrateVisual.getColorFromRarity(currentSlot.Rarity)
						
						local Text = string.format(
							"<font color=\"rgb(%d,%d,%d)\">\%s\</font>",
							RarityColor.R*255,
							RarityColor.G*255,
							RarityColor.B*255,
							currentSlot.Rarity .. ": " .. math.floor(currentSlot.Chance*10000) / 100 .. "%"
						)
						
						Inventory.MainFrame.Info.Stats.Text = Inventory.MainFrame.Info.Stats.Text .. Text

						if i ~= #ChanceList then							
							Inventory.MainFrame.Info.Stats.Text = Inventory.MainFrame.Info.Stats.Text .. "\n"
						end
					end
					
					if CurrentInvPage == InventoryPage.Crates then
						Inventory.MainFrame.Info.OpenCrate.Visible = true
					end
				end
		
			end)
		end
		
	end
end

Inventory.MainFrame.Info.Equip.MouseButton1Down:Connect(function()
	if Equipping then return end
	if not current_unit_selected then return end

	Equipping = true

	if isUnitEquipped(current_unit_selected) then 
		local UnequipRequest = Events.Inventory.Unequipping:InvokeServer(current_unit_selected)

		if UnequipRequest then
			Inventory.MainFrame.Info.Equip.Text = "Equip"
		else
			Inventory.MainFrame.Info.Equip.Text = "Unequip"
		end	
	else
		local EquipRequest = Events.Inventory.Equipping:InvokeServer(current_unit_selected)

		if EquipRequest then
			Inventory.MainFrame.Info.Equip.Text = "Unequip"
		else
			Inventory.MainFrame.Info.Equip.Text = "Equip"
		end
		
	end
	
	Equipping = false
end)

-- SKINS FRAME
local Inv_Skins_Temp = Inventory.SkinsFrame.ScrollingFrame.SkinTemplate
Inv_Skins_Temp.Parent = nil

local SpinningConnection3

function reset_skins_info()
	for _,model in pairs(Inventory.SkinsFrame.Info.ViewportFrame.WorldModel:GetChildren()) do
		model:Destroy()
	end
	
	if SpinningConnection3 then SpinningConnection3:Disconnect() end
	
	Inventory.SkinsFrame.Info.UnitName.Text = ""
	Inventory.SkinsFrame.Info.Stats.Text = ""
	
	Inventory.SkinsFrame.Info.Equip.Visible = false
end

function reset_skins_list()
	for _,v in pairs(Inventory.SkinsFrame.ScrollingFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
end

Inventory.SkinsFrame.ScrollingFrame.UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
LayoutUtil.new(Inventory.SkinsFrame.ScrollingFrame.UIGridLayout)

local current_skin_selected = nil

function LoadSkinsUnit()		
	CurrentInvPage = InventoryPage.Skins
	
	if not current_unit_selected then return end
	if not playerCurrentData then return end
	
	reset_skins_info()
	reset_skins_list()
	
	local skinsUnitList = {}
	
	local defaultFound = UnitSkins[current_unit_selected]:FindFirstChild("Default")
	
	if defaultFound then
		table.insert(skinsUnitList, "Default")
	end
	
	if playerCurrentData.SkinInventory[current_unit_selected] then
		local current_unit_skins = playerCurrentData.SkinInventory[current_unit_selected]
		
		for i,skinName in pairs(current_unit_skins) do
			table.insert(skinsUnitList, skinName)
		end
	end
	
	for i,skinName in pairs(skinsUnitList) do
		local skinUnitFound = UnitSkins[current_unit_selected]:FindFirstChild(skinName)

		if skinUnitFound then
			local cloneSkinUnit = Inv_Skins_Temp:Clone()
			cloneSkinUnit.Parent = Inventory.SkinsFrame.ScrollingFrame 

			cloneSkinUnit.SkinLabel.Text = skinName

			cloneSkinUnit.LayoutOrder = i

			local WorldModel = Instance.new("WorldModel")
			WorldModel.Parent = cloneSkinUnit.ViewportFrame

			local viewportClone = skinUnitFound['1']:Clone()

			viewportClone.PrimaryPart.Anchored = true

			if viewportClone:FindFirstChild("Hitbox") then
				viewportClone.Hitbox.Transparency = 1
			end

			viewportClone.Parent = WorldModel

			local animations = viewportClone:FindFirstChild("Animations")

			if animations then
				local animationTrack = viewportClone.Humanoid:LoadAnimation(animations.Idle)			
				animationTrack:Play()
			end	

			local viewportCamera = Instance.new("Camera")
			cloneSkinUnit.ViewportFrame.CurrentCamera = viewportCamera

			viewportCamera.Parent = WorldModel

			local cframe = viewportClone.PrimaryPart.CFrame * CFrame.Angles(0, 0, 0) * CFrame.new(0, 1.5, -2) 
			viewportCamera.CFrame = CFrame.new(cframe.p, viewportClone.Head.Position) * CFrame.new(0, -1, .5)

			if playerCurrentData then
				if playerCurrentData.Inventory[current_unit_selected].CurrentSkin == skinName then
					cloneSkinUnit.Equipped.Visible = true
				else
					cloneSkinUnit.Equipped.Visible = false
				end
			end
			
			cloneSkinUnit.MouseButton1Down:Connect(function()
				reset_skins_info()
				
				PlaySFX(RS.Sounds.SFX.ItemClick.SoundId)
				
				current_skin_selected = skinName

				Inventory.SkinsFrame.Info.UnitName.Text = skinName

				local infoUnitClone = viewportClone:Clone()

				infoUnitClone.Parent = Inventory.SkinsFrame.Info.ViewportFrame.WorldModel

				infoUnitClone.PrimaryPart.Anchored = true

				if infoUnitClone:FindFirstChild("Hitbox") then
					infoUnitClone.Hitbox.Transparency = 1
				end

				local animations = infoUnitClone:FindFirstChild("Animations")

				if animations then
					local animationTrack = infoUnitClone.Humanoid:LoadAnimation(animations.Idle)			
					animationTrack:Play()
				end	

				local viewportInfoCamera = Instance.new("Camera")
				Inventory.SkinsFrame.Info.ViewportFrame.CurrentCamera = viewportInfoCamera

				viewportInfoCamera.Parent = Inventory.SkinsFrame.Info.ViewportFrame.WorldModel		

				local c = 0;			

				coroutine.wrap(function()
					SpinningConnection3 = RunService.RenderStepped:Connect(function(step)						
						local cframe = infoUnitClone.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(c), 0) * CFrame.new(0, 1.5, -2) 
						--  Change the angles accordingly, and the -5 should be distance from the objects center outwards.
						-- Once you have that, you want to take that position and have it face the position of the sword, and then set the Viewport's camera cframe to that new cframe.
						cframe = CFrame.new(cframe.p, infoUnitClone.Head.Position) * CFrame.new(0, -1, .5) 
						viewportInfoCamera.CFrame = cframe;

						c += 1.15;
					end)		
				end)()

				Inventory.SkinsFrame.Info.Equip.Visible = true	

				if playerCurrentData.Inventory[current_unit_selected].CurrentSkin == skinName then
					Inventory.SkinsFrame.Info.Equip.Text = "Equipped"
					Inventory.SkinsFrame.Info.Equip.Active = false
				else
					Inventory.SkinsFrame.Info.Equip.Text = "Equip"
					Inventory.SkinsFrame.Info.Equip.Active = true
				end
			end)
		end
	end
	
end

-- Skin equip
Inventory.SkinsFrame.Info.Equip.Activated:Connect(function()
	if not playerCurrentData then return end
	
	if current_skin_selected and current_unit_selected then
		local EquipSkin = Events.Inventory.EquipSkin:InvokeServer(current_unit_selected, current_skin_selected)
		
		if EquipSkin then
			LoadSkinsUnit()
			Inventory.SkinsFrame.Info.Equip.Text = "Equipped"
			Inventory.SkinsFrame.Info.Equip.Active = false
		end
	end
	
end)

-- Skin activation
Inventory.MainFrame.Info.Skins.MouseButton1Down:Connect(function()
	if not Inventory.SkinsFrame.Visible then
		push_gui(Inventory.SkinsFrame)
		LoadSkinsUnit()
	else	
		Inventory.SkinsFrame.Visible = false
	end
end)

Inventory.SkinsFrame.Back.MouseButton1Down:Connect(function()
	Inventory.SkinsFrame.Visible = false
	push_gui(Inventory.MainFrame)
	Setup_UnitInventory()
end)

-- open crates

local OpeningCrate = false

Inventory.MainFrame.Info.OpenCrate.MouseButton1Down:Connect(function()
	if OpeningCrate then return end
	if not current_crate_selected then return end
	
	OpeningCrate = true
	
	local OpenCrateRequest, isDuplicate = Events.Inventory.OpenCrateRequest:InvokeServer(current_crate_selected)
	
	if OpenCrateRequest then
		local unitChosen = OpenCrateRequest[1]
		local skinType = OpenCrateRequest[2]
		local rarity = OpenCrateRequest[3]
		
		MainUI.Enabled = false
		
		OpenCrateVisual.init(unitChosen, skinType, current_crate_selected.Name, rarity, isDuplicate)
	end
	
	OpeningCrate = false
	
end)

MainUI.Inventory.MainFrame.UnitsTab.MouseButton1Down:Connect(Setup_UnitInventory)
MainUI.Inventory.MainFrame.CratesTab.MouseButton1Down:Connect(Setup_CratesInventory)

-- Shop

local ShopFolder = MainUI.Shop

local ShopFrame = ShopFolder.ShopFrame

ShopFrame.Visible = false

local InfoFrame = ShopFrame.InfoFrame
local LeftFrame = ShopFrame.LeftFrame

local Shop_List = LeftFrame.List.ScrollingFrame

local UnitShop_Temp = LeftFrame.List.ScrollingFrame.ShopUnitTemplate
UnitShop_Temp.Parent = nil

local ShopCrate_Temp = LeftFrame.List.ScrollingFrame.ShopCrateTemplate
ShopCrate_Temp.Parent = nil

function clear_shop_elements()
	for _,v in pairs(Shop_List:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
end

function reset_info_frame()
	local findWorld = InfoFrame.ViewThumb:FindFirstChildWhichIsA("WorldModel")

	if findWorld then
		findWorld:Destroy()
	end
	
	InfoFrame.ItemTitle.Text = ""
	InfoFrame.Stats.Text = ""
	
	InfoFrame.DescriptionFrame.Description.Text = ""
	
	InfoFrame.BuyButton.Visible = false
end

local current_selected_shop_unit = nil
local current_shop_crate = nil

InfoFrame.BuyButton.Visible = false

LayoutUtil.new(Shop_List.UIGridLayout)

function Setup_Shop_Units()
	PlaySFX(RS.Sounds.SFX.TabClick.SoundId)
	
	if CurrentShopPage == ShopPage.Crates then
		InfoFrame.BuyButton.Visible = false
		reset_info_frame()
	end
	
	CurrentShopPage = ShopPage.Units
	
	current_shop_crate = nil
	
	Inventory.MainFrame.ScrollingFrame.UIGridLayout.SortOrder = Enum.SortOrder.Name

	clear_shop_elements()

	for k,v in pairs(UnitsDatabase.Units) do
		if v.isOnMarket then 
			local ShopUnitEle = UnitShop_Temp:Clone()
			ShopUnitEle.Parent = Shop_List
			ShopUnitEle.Name = k
			
			ShopUnitEle.Visible = true

			ShopUnitEle.UnitLabel.Text = k
			
			if playerCurrentData then
				if playerCurrentData.Inventory[k] then
					ShopUnitEle.Owned.Visible = true
				else
					ShopUnitEle.Owned.Visible = false
				end
			end

			local ModelUnit = UnitSkins:FindFirstChild(k)["Default"]["1"]

			if ModelUnit then
				local WorldModel = Instance.new("WorldModel")
				WorldModel.Parent = ShopUnitEle.ViewportFrame

				local viewportClone = ModelUnit:Clone()

				viewportClone.PrimaryPart.Anchored = true

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
				ShopUnitEle.ViewportFrame.CurrentCamera = viewportCamera

				viewportCamera.Parent = WorldModel
				
				local cframe = ModelUnit.PrimaryPart.CFrame * CFrame.Angles(0, 0, 0) * CFrame.new(0, 1.5, -2) 
				viewportCamera.CFrame = CFrame.new(cframe.p, ModelUnit.Head.Position) * CFrame.new(0, -1, .5) 
			end
			
			ShopUnitEle.MouseButton1Down:Connect(function()
				reset_info_frame()
				
				PlaySFX(RS.Sounds.SFX.ItemClick.SoundId)
				
				current_selected_shop_unit = {Name = k, Values = v}
				
				InfoFrame.ItemTitle.Text = k
				InfoFrame.DescriptionFrame.Description.Text = v.Description
				
				InfoFrame.Stats.Text = "Starting Cost: " .. v.Cost
				
				if v.Type ~= "Farm" then
					InfoFrame.Stats.Text = InfoFrame.Stats.Text .. "\nInitial ATK: " .. v.Upgrades[1].Stats.ATK
					InfoFrame.Stats.Text = InfoFrame.Stats.Text .. "\nInitial RNG: " .. v.Upgrades[1].Stats.RNG
					InfoFrame.Stats.Text = InfoFrame.Stats.Text .. "\nInitial SPD: " .. v.Upgrades[1].Stats.SPD
				else
					InfoFrame.Stats.Text = InfoFrame.Stats.Text .. "\nInitial Income: " .. v.Upgrades[1].Stats.ATK
				end						
				
				local worldModelClone = ShopUnitEle.ViewportFrame.WorldModel:Clone()
				
				worldModelClone.Parent = InfoFrame.ViewThumb
				
				InfoFrame.ViewThumb.CurrentCamera = worldModelClone.Camera
				
				local character = worldModelClone:FindFirstChildWhichIsA("Model")
				
				local animations = character:FindFirstChild("Animations")

				if animations then
					local animationTrack = character.Humanoid:LoadAnimation(animations.Idle)			
					animationTrack:Play()
				end	
				
				local c = 0;
				
				if SpinningConnection2 then SpinningConnection2:Disconnect() end
				
				coroutine.wrap(function()
					SpinningConnection2 = RunService.RenderStepped:Connect(function(step)
						local cframe = ModelUnit.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(c), 0) * CFrame.new(0, 1.5, -2) 
						--  Change the angles accordingly, and the -5 should be distance from the objects center outwards.
						-- Once you have that, you want to take that position and have it face the position of the sword, and then set the Viewport's camera cframe to that new cframe.
						cframe = CFrame.new(cframe.p, ModelUnit.Head.Position) * CFrame.new(0, -1, .5) 
						InfoFrame.ViewThumb.CurrentCamera.CFrame = cframe;

						c += 1.15;
					end)		
				end)()
				
				InfoFrame.BuyButton.BackgroundColor3 = Color3.fromRGB(232, 194, 0)
				
				InfoFrame.BuyButton.Visible = true
				
				if playerCurrentData then
					if playerCurrentData.Inventory[k] then
						InfoFrame.BuyButton.Text = "Owned"
						InfoFrame.BuyButton.Active = false
					else
						InfoFrame.BuyButton.Text = v.MarketPrice .. " Coins"
						InfoFrame.BuyButton.Active = true
					end
				end
			end)
		end
	end
end

LeftFrame.UnitsButton.MouseButton1Down:Connect(Setup_Shop_Units)

function Setup_Shop_Crates()
	PlaySFX(RS.Sounds.SFX.TabClick.SoundId)
	
	if CurrentShopPage == ShopPage.Units then
		InfoFrame.BuyButton.Visible = false
		reset_info_frame()
	end
	
	CurrentShopPage = ShopPage.Crates
	
	current_selected_shop_unit = nil
	
	clear_shop_elements()
	
	Inventory.MainFrame.ScrollingFrame.UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	for k,v in pairs(CratesDatabase.Crates) do
		local shopcrateClone = ShopCrate_Temp:Clone()
		
		shopcrateClone.Parent = Shop_List
		
		shopcrateClone.Visible = true
		
		shopcrateClone.CrateLabel.Text = k
		shopcrateClone.LayoutOrder = v.Order	
		
		shopcrateClone.MouseButton1Down:Connect(function()		
			reset_info_frame()
			
			PlaySFX(RS.Sounds.SFX.ItemClick.SoundId)
			
			current_shop_crate = {Name = k, Values = v}
			
			InfoFrame.ItemTitle.Text = k
			
			if v.CoinCost then
				InfoFrame.BuyButton.BackgroundColor3 = Color3.fromRGB(232, 194, 0)
				InfoFrame.BuyButton.Text = v.CoinCost .. " Coins"
			else
				InfoFrame.BuyButton.BackgroundColor3 = Color3.fromRGB(2, 255, 192)
				InfoFrame.BuyButton.Text = v.GemCost .. " Gems"
			end
			
			local ChancesTable = LootManager:GetChances(v.Percentage)
			
			local ChanceList = {}
			
			for rarity, v in pairs(ChancesTable) do
				table.insert(ChanceList, {Rarity = rarity, Chance = v.Chance})
			end
			
			table.sort(ChanceList,
				function(a,b)
					return CratesDatabase.getOrderRarity(a.Rarity) < CratesDatabase.getOrderRarity(b.Rarity)
				end
			)
			
			InfoFrame.Stats.Text = ""
			
			for i=1, #ChanceList do
				local currentSlot = ChanceList[i]
				
				local RarityColor = OpenCrateVisual.getColorFromRarity(currentSlot.Rarity)

				local Text = string.format(
					"<font color=\"rgb(%d,%d,%d)\">\%s\</font>",
					RarityColor.R*255,
					RarityColor.G*255,
					RarityColor.B*255,
					currentSlot.Rarity .. ": " .. math.floor(currentSlot.Chance*10000) / 100 .. "%"
				)
				
				InfoFrame.Stats.Text = InfoFrame.Stats.Text .. Text
				
				if i ~= #ChanceList then
					InfoFrame.Stats.Text = InfoFrame.Stats.Text .. "\n"
				end
			end
			
			InfoFrame.BuyButton.Visible = true
		end)
		
	end	
end

LeftFrame.CratesButton.MouseButton1Down:Connect(Setup_Shop_Crates)

local ShopToggleButton = ToggleButtons.Main.ShopToggleButton

ShopToggleButton.MouseButton1Down:Connect(function()
	if ShopFrame.Visible then
		ShopFrame.Visible = false
	else
		push_gui(ShopFrame)
	end
end)

-- BUYING SHOP

InfoFrame.BuyButton.Activated:Connect(function()
	if CurrentShopPage == ShopPage.Units then
		if current_selected_shop_unit and current_selected_shop_unit.Name then
			if playerCurrentData.Inventory[current_selected_shop_unit.Name] then return end

			local requestPurchase = Events.Shop.RequestPurchaseUnit:InvokeServer(current_selected_shop_unit.Name)

			if requestPurchase then
				--playerCurrentData = requestPurchase

				--MainUI.Currency.Coins.Text = playerCurrentData.Coins
				--MainUI.Currency.Gems.Text = playerCurrentData.Gems
				
				PlaySFX(RS.Sounds.SFX.PurchasedSound.SoundId)
				
				InfoFrame.BuyButton.Text = "Owned"
				InfoFrame.BuyButton.Active = false

				InfoFrame.BuyButton.Visible = true
			end
		end
	elseif CurrentShopPage == ShopPage.Crates then
		
		if current_shop_crate and current_shop_crate.Name and current_shop_crate.Values then
			InfoFrame.BuyButton.Active = false
			InfoFrame.BuyButton.Text = "Purchasing..."

			local boughtCrate = current_shop_crate

			local requestPurchase = Events.Shop.RequestPurchaseCrate:InvokeServer(current_shop_crate.Name)

			if requestPurchase then			
				InfoFrame.BuyButton.Text = "Bought 1 crate!"
				InfoFrame.BuyButton.Active = true

				PlaySFX(RS.Sounds.SFX.PurchasedSound.SoundId)

				coroutine.wrap(function()
					wait(3)

					if CurrentShopPage == ShopPage.Crates and InfoFrame.ItemTitle.Text == boughtCrate.Name then 
						if boughtCrate.Values.CoinCost then
							InfoFrame.BuyButton.BackgroundColor3 = Color3.fromRGB(232, 194, 0)
							InfoFrame.BuyButton.Text = boughtCrate.Values.CoinCost .. " Coins"
						else
							InfoFrame.BuyButton.BackgroundColor3 = Color3.fromRGB(2, 255, 192)
							InfoFrame.BuyButton.Text = boughtCrate.Values.GemCost .. " Gems"
						end 
					end
				end)()		
			else
				InfoFrame.BuyButton.Text = "Not enough currency!"
				InfoFrame.BuyButton.Active = true

				coroutine.wrap(function()
					wait(3)

					if CurrentShopPage == ShopPage.Crates and InfoFrame.ItemTitle.Text == boughtCrate.Name then 
						if boughtCrate.Values.CoinCost then
							InfoFrame.BuyButton.BackgroundColor3 = Color3.fromRGB(232, 194, 0)
							InfoFrame.BuyButton.Text = boughtCrate.Values.CoinCost .. " Coins"
						else
							InfoFrame.BuyButton.BackgroundColor3 = Color3.fromRGB(2, 255, 192)
							InfoFrame.BuyButton.Text = boughtCrate.Values.GemCost .. " Gems"
						end 
					end
				end)()	
			end
		end
		
	end
end)

-- MUSIC MANAGER:
local e7musicbg = Instance.new("Sound", SoundService)
e7musicbg.Name = "LobbyBGMusic"

e7musicbg.SoundId = "rbxassetid://3441266043"
e7musicbg.Looped = true
e7musicbg.Volume = 0.2

local function PlayBGMusic()
	if playerCurrentData then
		SettingsValue.MusicVolume.Value = playerCurrentData.SettingsData.MusicVolume
		
		e7musicbg.Volume = playerCurrentData.SettingsData.MusicVolume
		
		local Scale = playerCurrentData.SettingsData.MusicVolume / 1.02564102564
		
		SettingsFrame.List.MusicSlider.ToggleSlide.Position = UDim2.new(Scale-0.01, 0, 0.5, 0)
		SettingsFrame.List.MusicSlider.Fill.Size = UDim2.fromScale(Scale, 1)
		
		SettingsFrame.List.MusicSlider.VolumeLabel.Text = "Music Volume (" .. math.floor(playerCurrentData.SettingsData.MusicVolume*100 + 0.5) .. "%)"
	end

	e7musicbg:Play()
end

local function UpdateEffectVol()
	if playerCurrentData then
		SettingsValue.EffectVolume.Value = playerCurrentData.SettingsData.EffectVolume
		
		local Scale = playerCurrentData.SettingsData.EffectVolume / 1.02564102564

		SettingsFrame.List.EffectSlider.ToggleSlide.Position = UDim2.new(Scale-0.01, 0, 0.5, 0)
		SettingsFrame.List.EffectSlider.Fill.Size = UDim2.fromScale(Scale, 1)

		SettingsFrame.List.EffectSlider.VolumeLabel.Text = "Effect Volume (" .. math.floor(playerCurrentData.SettingsData.EffectVolume*100 + 0.5) .. "%)"
	end
end

function UpdateSounds()
	if not playerCurrentData then return end
	
	for _,d in pairs(ToggleButtons:GetDescendants()) do
		if d:IsA("ImageButton") then
			d.MouseButton1Down:Connect(function()				
				PlaySFX(RS.Sounds.SFX.ToggleClick.SoundId)
			end)
		end
	end
	
	UpdateEffectVol()
	PlayBGMusic()
end

-- SETTINGS
local UserInputService = game:GetService("UserInputService")

local HoldingMusicSlider, HoldingEffectSlider = false, false

SettingsFrame.Visible = false

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
		push_gui(SettingsFrame)
	else
		SettingsFrame.Visible = false
		
		local SettingsZip = ZipSettings()
		Events.Settings.SaveGlobalSetting:FireServer(SettingsZip)
	end
end)

SettingsFrame.DoneButton.MouseButton1Down:Connect(function()
	PlaySFX(RS.Sounds.SFX.ToggleClick.SoundId)
	
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

	SettingsFrame.List.MusicSlider.Fill.Size = UDim2.fromScale(Scale, 1)

	e7musicbg.Volume = ToVolume
	
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

	SettingsFrame.List.EffectSlider.VolumeLabel.Text = "Effect Volume (" .. math.floor(ToVolume*100 + 0.5) .. "%)"
end

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
			PlaySFX(RS.Sounds.SFX.Beep2.SoundId)
			HoldingEffectSlider = false
		end
	end
end)

UserInputService.TouchEnded:Connect(function(touch, gameProcessedEvent)
	if HoldingMusicSlider then HoldingMusicSlider = false end
	if HoldingEffectSlider then
		PlaySFX(RS.Sounds.SFX.Beep2.SoundId)
		HoldingEffectSlider = false 
	end
end)

-- UPDATE LEVEL BAR
local LevelBar = Inventory.UnitSelection.LevelBar
local ExpFill = LevelBar.ExpFill

local function getNextLvlExp(level)
	return 0.04 * (level ^ 3) + 0.8 * (level ^ 2) + 2 * level
end

function UpdateLevelBar()
	if not playerCurrentData then return end
	
	if playerCurrentData.Level and playerCurrentData.CurrentEXP then
		local ExpNeeded = getNextLvlExp(playerCurrentData.Level)
		
		local ExpScale = math.clamp(playerCurrentData.CurrentEXP/ExpNeeded, 0, 1)		
		ExpFill.Size = UDim2.fromScale(ExpScale, 1)
		
		LevelBar.TextLabel.Text = "Level " .. playerCurrentData.Level .. " (".. math.floor(playerCurrentData.CurrentEXP + 0.5) .. "/" .. math.floor(ExpNeeded + 0.5) .. ")"
	end
end

-- LOADING DATA

local LoadedFirstTime = false

function LoadData(plr_data)
	playerCurrentData = plr_data
	
	print(playerCurrentData)

	if CurrentInvPage == InventoryPage.Units then
		Setup_UnitInventory()
	else
		Setup_CratesInventory()
	end

	if CurrentShopPage == ShopPage.Units then
		Setup_Shop_Units()
	else
		Setup_Shop_Crates()
	end

	UpdateSlot()

	MainUI.Currency.Coins.Text = playerCurrentData.Coins
	MainUI.Currency.Gems.Text = playerCurrentData.Gems
	
	UpdateLevelBar()
	
	if not LoadedFirstTime then
		LoadedFirstTime = true
		UpdateSounds()
	end
	
	MainUI.Enabled = true
end

Events.Saves.LoadPlayer.OnClientEvent:Connect(LoadData)