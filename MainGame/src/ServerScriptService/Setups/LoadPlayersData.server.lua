local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local HttpService = game:GetService("HttpService")

local ServerEvents = ServerStorage.Events

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
	print(player.Name .. " has logged in " .. tostring(profile.Data.LogInTimes)
		.. " time" .. ((profile.Data.LogInTimes > 1) and "s" or ""))
	--GiveCash(profile, 100)
	print(player.Name .. " has " .. tostring(profile.Data.Coins) .. " coins now!")
	
	ReplicatedStorage.Events.Saves.LoadPlayer:FireClient(player, profile.Data)
end

local function PlayerAdded(player)
	ServerStorage.Events.PlayerAdded:Fire(player)
	
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

-- requesting data

ServerEvents.Saves.RequestPlayerData.OnInvoke = function(player)
	if Profiles[player] then
		return Profiles[player].Data
	end
end

-- Global settings save
function SaveGlobalSettingFunc(plr,settingsData)
	local global_k = "cli_" .. plr.UserId

	local function Setup()
		local newConfig = Instance.new("Configuration", GlobalUserSettings)

		newConfig.Name = global_k

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

----- Connections -----

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]
	if profile ~= nil then
		profile:Release()
	end
end)


