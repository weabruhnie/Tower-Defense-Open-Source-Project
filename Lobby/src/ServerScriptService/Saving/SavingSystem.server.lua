local ServerStorage = game:GetService("ServerStorage")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnitsDatabase = require(ServerStorage.Database.UnitsDatabase)
local CratesDatabase = require(ServerStorage.Database.CratesDatabase)
local SkinsDatabase = require(ServerStorage.Database.SkinsDatabase)

local GlobalUserSettings = Instance.new("Folder", ServerStorage)
GlobalUserSettings.Name = "GlobalUserSettings"

local ProfileTemplate = {
	Coins = 300,
	Gems = 0,
	
	Level = 1,
	CurrentEXP = 0,
	
	Inventory = {
		["Noob"] = {CurrentSkin = "Default"} 
	},

	CurrentEquipped = {},
	
	CratesInventory = {},
	
	SkinInventory = {},
	
	LogInTimes = 0,
	
	isAlphaUser = true,
	
	SettingsData = {
		MusicVolume = 0.5,
		EffectVolume = 0.5
	}
}

local ProfileService = require(ServerStorage.Modules.ProfileService)

local Players = game:GetService("Players")

local ProfileStore = ProfileService.GetProfileStore(
	"players_data",
	ProfileTemplate
)

local Profiles = {}

local function ProfileSetup(player, profile)
	profile.Data.LogInTimes += 1
	print(player.Name .. " has logged in " .. tostring(profile.Data.LogInTimes) .. " time" .. ((profile.Data.LogInTimes > 1) and "s" or ""))
	
	ReplicatedStorage.Events.Saves.LoadPlayer:FireClient(player, profile.Data)
end

local function PurchaseCoinShop(profile, amount)
	if amount < 0 then return false end

	if profile.Data.Coins == nil then
		profile.Data.Coins = 0
	end
	
	if profile.Data.Coins < 0 then
		profile.Data.Coins = 0
	end
	
	if amount <= profile.Data.Coins then
		profile.Data.Coins = profile.Data.Coins - amount
		return true
	end
	
	return false
end

local function PurchaseGemShop(profile, amount)
	if amount < 0 then return false end

	if profile.Data.Gems == nil then
		profile.Data.Gems = 0
	end

	if profile.Data.Gems < 0 then
		profile.Data.Gems = 0
	end

	if amount <= profile.Data.Gems then
		profile.Data.Gems = profile.Data.Gems - amount
		return true
	end

	return false
end

local function PlayerAdded(player)
	local profile = ProfileStore:LoadProfileAsync("user_" .. player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()

			if GlobalUserSettings:FindFirstChild("cli_"..player.UserId) then				
				for _,v in pairs(GlobalUserSettings["cli_"..player.UserId]:GetChildren()) do
					profile.Data.SettingsData[v.Name] = v.Value
				end				
			end
			
			Profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			Profiles[player] = profile
			-- A profile has been successfully loaded:
			ProfileSetup(player, profile)
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick() 
	end
end


-- In case Players have joined the server earlier than this script ran:
for _, player in ipairs(Players:GetPlayers()) do
	coroutine.wrap(PlayerAdded)(player)
end

-- Inventory System
ReplicatedStorage.Events.Inventory.Equipping.OnServerInvoke = function(player, unit)	
	if Profiles[player] then
		local currentProfile = Profiles[player].Data

		if table.find(currentProfile.CurrentEquipped, unit) then return false end
		
		if currentProfile.Inventory[unit] then
			
			if #currentProfile.CurrentEquipped < 5 then
				table.insert(currentProfile.CurrentEquipped, unit)
				ReplicatedStorage.Events.Saves.LoadPlayer:FireClient(player, currentProfile)
				
				return true
			end
			
		end
		
		return false
	end
end

ReplicatedStorage.Events.Inventory.Unequipping.OnServerInvoke = function(player, unit)	
	if Profiles[player] then
		local currentProfile = Profiles[player].Data

		if not table.find(currentProfile.CurrentEquipped, unit) then return false end

		if currentProfile.Inventory[unit] then
			local findUnit = table.find(currentProfile.CurrentEquipped, unit)
			
			if findUnit then
				table.remove(currentProfile.CurrentEquipped, findUnit)
				ReplicatedStorage.Events.Saves.LoadPlayer:FireClient(player, currentProfile)
				
				return true
			end

		end

		return false
	end
end

-- equipping skin

ReplicatedStorage.Events.Inventory.EquipSkin.OnServerInvoke = function(player, unit, skin)	
	if Profiles[player] then
		local currentProfile = Profiles[player].Data
		
		if currentProfile.SkinInventory[unit] and (table.find(currentProfile.SkinInventory[unit], skin) or skin == "Default") then
			if currentProfile.Inventory[unit].CurrentSkin == skin then return false end
			
			currentProfile.Inventory[unit].CurrentSkin = skin
			ReplicatedStorage.Events.Saves.LoadPlayer:FireClient(player, currentProfile)
			
			return true
		end

		return false
	end
end

-- opening crate

local LootManager = require(ServerStorage.Modules.LootManager)

ReplicatedStorage.Events.Inventory.OpenCrateRequest.OnServerInvoke = function(player, requestCrate)
	if Profiles[player] then
		local currentProfile = Profiles[player].Data
		
		local foundCrate = table.find(currentProfile.CratesInventory, requestCrate.Name)
		
		if CratesDatabase.Crates[requestCrate.Name] and foundCrate then
			table.remove(currentProfile.CratesInventory, requestCrate.Index)
			
			local rarityReceived = LootManager:GetRandomSlot(CratesDatabase.Crates[requestCrate.Name].Percentage)
			
			if SkinsDatabase.Skins[rarityReceived] then
				local currentRarityLoots = SkinsDatabase.Skins[rarityReceived]
				
				local keys = {}
				
				for k in pairs(currentRarityLoots) do -- `k` will be "Hat1", then "Hat2", then "Hat3"
					table.insert(keys, k) -- put them all into the `keys` array
				end
				
				if #keys == 0 then return false end
					
				local skinType = keys[math.random(1,#keys)] 		
				
				local AvailableUnits = currentRarityLoots[skinType].AvailableUnits
				local UnitsChosen = AvailableUnits[math.random(1,#AvailableUnits)]
				
				local isDuplicate = false
				
				if currentProfile.SkinInventory[UnitsChosen] then
					local foundSkin = table.find(currentProfile.SkinInventory[UnitsChosen], skinType)
					
					if foundSkin then
						isDuplicate = true
						print("duplicate")
					else
						table.insert(currentProfile.SkinInventory[UnitsChosen], skinType)
					end				
				else
					currentProfile.SkinInventory[UnitsChosen] = {}					
					table.insert(currentProfile.SkinInventory[UnitsChosen], skinType)
				end
				
				table.sort(currentProfile.SkinInventory[UnitsChosen], function(a, b) return a:lower() < b:lower() end)	
				
				ReplicatedStorage.Events.Saves.LoadPlayer:FireClient(player, currentProfile)
				
				return {UnitsChosen, skinType, rarityReceived}, isDuplicate
			end
		end
	end

	return false
end


-- Shop system
ReplicatedStorage.Events.Shop.RequestPurchaseUnit.OnServerInvoke = function(player, requestUnit)
	if Profiles[player] then
		local currentProfile = Profiles[player].Data
		
		if currentProfile.Inventory[requestUnit] then return false end
		
		local unitChosen = UnitsDatabase.Units[requestUnit]	

		if unitChosen and unitChosen.isOnMarket then
			local purchased = PurchaseCoinShop(Profiles[player], unitChosen.MarketPrice)

			if purchased then
				currentProfile.Inventory[requestUnit] = {CurrentSkin = "Default"}
				ReplicatedStorage.Events.Saves.LoadPlayer:FireClient(player, currentProfile)
				
				return true
			end
		end
	end
	
	return false
end

ReplicatedStorage.Events.Shop.RequestPurchaseCrate.OnServerInvoke = function(player, requestCrate)
	if Profiles[player] then
		local currentProfile = Profiles[player].Data

		local crateChosen = CratesDatabase.Crates[requestCrate]

		if crateChosen then
			
			local purchased 			
			if crateChosen.CoinCost then
				purchased = PurchaseCoinShop(Profiles[player], crateChosen.CoinCost)
			else
				purchased = PurchaseGemShop(Profiles[player], crateChosen.GemCost)
			end
			

			if purchased then
				table.insert(currentProfile.CratesInventory, requestCrate)
				
				table.sort(currentProfile.CratesInventory, function(a, b) return CratesDatabase.Crates[a].Order < CratesDatabase.Crates[a].Order end)	
				
				ReplicatedStorage.Events.Saves.LoadPlayer:FireClient(player, currentProfile)
				
				return true
			end
		end
	end

	return false
end

-- Global settings save
function SaveGlobalSettingFunc(plr,settingsData)
	local global_k = "cli_" .. plr.UserId
	
	local function Setup()
		local newConfig = Instance.new("Configuration", GlobalUserSettings)

		newConfig.Name = global_k
		
		print(settingsData)

		for k,v in pairs(settingsData) do
			local newValue = Instance.new("NumberValue", newConfig)
			newValue.Name = k
			newValue.Value = v
		end
		
		print("saved")
	end
	
	if GlobalUserSettings:FindFirstChild(global_k) then
		GlobalUserSettings[global_k]:Destroy()
	end
	
	Setup()
end

ReplicatedStorage.Events.Settings.SaveGlobalSetting.OnServerEvent:Connect(SaveGlobalSettingFunc)

---- LEVELS ----
local LevelHandler = require(ServerStorage.Modules.Level.LevelHandler)
local AddPlrExp = ServerStorage.Events.Level.AddPlrExp

AddPlrExp.Event:Connect(function(plr, exp)
	if Profiles[plr] then
		LevelHandler.AddExp(Profiles[plr].Data, exp)
		ReplicatedStorage.Events.Saves.LoadPlayer:FireClient(plr, Profiles[plr].Data)
	end	
end)

----- Connections -----

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]
	if profile ~= nil then
		profile:Release()
	end
end)