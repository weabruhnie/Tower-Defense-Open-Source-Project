local ServerStorage = game.ServerStorage
local ReplicatedStorage = game.ReplicatedStorage

local UnitSkins = ServerStorage.UnitSkins

local PhysicsService = game:GetService("PhysicsService")
local HttpService = game:GetService("HttpService")

local Players = game:GetService("Players")

local Events = ReplicatedStorage.Events
local ServerEvents = ServerStorage.Events

local MapHandler = require(ServerStorage.Modules.MapHandler)
local UnitHandler = require(ServerStorage.Modules.Units.UnitHandler)

local UnitsDatabase = require(ServerStorage.Database.UnitsDatabase)

local Units = {}

local MaximumUnits = 16

local function CountSpecificUnitsFromPlayer(player, unit)
	local PlayerUnitCount = 0
	
	for k,v in pairs(Units) do
		if v.Unit.Name == unit and v.Owner == player then
			PlayerUnitCount += 1
		end
	end
	
	return PlayerUnitCount
end

local function getMaxPlacement()
	local totalPlrs = #Players:GetPlayers()
	
	local MaxPlace
	if totalPlrs == 1 then
		MaxPlace = 40
	elseif totalPlrs == 2 then
		MaxPlace = 35
	elseif totalPlrs == 3 then
		MaxPlace = 30
	elseif totalPlrs == 4 then
		MaxPlace = 20
	else
		MaxPlace = 15
	end
	
	return MaxPlace
end

local function isOverallUnitMax(player)
	local TotalUnit = 0
	local MaxPlace = getMaxPlacement()
	
	for k,_ in pairs(UnitsDatabase.Units) do
		TotalUnit += CountSpecificUnitsFromPlayer(player, k)
	end

	if TotalUnit >= MaxPlace then
		return true
	end

	return false
end

function PlayerHasSkin(plr_Data, unitName, skinName)
	if plr_Data.Inventory[unitName].CurrentSkin ~= nil then
		
		if plr_Data.Inventory[unitName].CurrentSkin == "Default" then
			return true			
		else
			if plr_Data.SkinInventory[unitName] and table.find(plr_Data.SkinInventory[unitName], skinName) then
				return true
			end			
		end	
		
	end
	
	return false
end

Events.Placement.RequestPlace.OnServerInvoke = function(player, unitChosen, unitSkin, unitCFrame)
	local plr_Data = ServerEvents.Saves.RequestPlayerData:Invoke(player)
	
	local Map = MapHandler:getMap()
	
	if plr_Data.Inventory[unitChosen] and table.find(plr_Data.CurrentEquipped, unitChosen) then
		
		if not PlayerHasSkin(plr_Data, unitChosen, unitSkin) then return false end
		
		local rayOrigin = unitCFrame.Position
		local rayDirection = Vector3.new(0, -100, 0)
		
		local unitInfo = UnitsDatabase.find(unitChosen)
		
		if not unitInfo then			
			return false 
		end
		
		local playerCash = ServerEvents.Economy.GetPlayerCash:Invoke(player)
		
		local attemptPurchase = playerCash:Purchase(unitInfo.Cost)
		
		if not attemptPurchase then 
			return false, "Not enough cash to place the unit!"
		end
		
		if isOverallUnitMax(player) then
			return false, "You have reached the max amount of unit placement (" .. getMaxPlacement() .. ")!"
		end
		
		if unitInfo.PlaceLimit then
			local getCountFromUnit = CountSpecificUnitsFromPlayer(player, unitChosen)
			
			if getCountFromUnit >= unitInfo.PlaceLimit then
				return false, "You have reached the max amount for this unit (" .. unitInfo.PlaceLimit .. ")!"
			end
		end
		
		playerCash:Update()
		
		local raycastResult = workspace:Raycast(rayOrigin, rayDirection)
		
		if raycastResult then
			local hitPart = raycastResult.Instance
			
			if hitPart.Parent == Map.Placeable and hitPart.Name == unitInfo.Type then
				
				local unitFind = UnitSkins:FindFirstChild(unitChosen):FindFirstChild(unitSkin)["1"]
				
				if unitFind then
					local PlacingUnit = unitFind:Clone()
					PlacingUnit.Parent = workspace.Units
					
					PlacingUnit.Name = unitChosen
					
					--for _,unitPart in pairs(PlacingUnit:GetDescendants()) do
					--	if unitPart:IsA("BasePart") then
					--		PhysicsService:SetPartCollisionGroup(unitPart, "UnitCollision")
					--	end
					--end
					local unitID = HttpService:GenerateGUID(false)
					
					Units[unitID] = UnitHandler.Int(player, PlacingUnit, unitInfo, unitCFrame, unitID, unitSkin)
					return unitID
				end
			end
		end
	end
	
	return false, "Error: unable to find unit"
end

ReplicatedStorage.Events.Units.UnitGetNextUpgrade.OnServerInvoke = function(player, unitRequest)
	if Units[unitRequest] then
		return Units[unitRequest]:getNextUpdateInfo()
	end
	
	return false
end

ReplicatedStorage.Events.Units.UpgradeUnit.OnServerInvoke = function(player, unitRequest)
	if Units[unitRequest] then		
		local currentUnit = Units[unitRequest]
		
		local nextUpgrade = currentUnit:getNextUpdateInfo()
		
		if not nextUpgrade then return end
		
		local playerCash = ServerEvents.Economy.GetPlayerCash:Invoke(player)

		local attemptPurchase = playerCash:Purchase(nextUpgrade.Cost)

		if not attemptPurchase then 
			return false, "Not enough cash to upgrade!"
		end
		
		playerCash:Update()
		
		currentUnit:Upgrade()
		
		ReplicatedStorage.Events.Units.UpdateUnitUI:FireClient(player, currentUnit.Unit)
		
		return true
	end
	
	return false, "Error: unable to find unit"
end

ReplicatedStorage.Events.Units.SellUnit.OnServerInvoke = function(player, unitRequest)
	if Units[unitRequest] then		
		local currentUnit = Units[unitRequest]

		local playerCash = ServerEvents.Economy.GetPlayerCash:Invoke(player)	

		local attemptIncome = playerCash:Income(math.floor(currentUnit.TotalCost / 2 + 0.5))
		
		currentUnit:Delete()
		Units[unitRequest] = nil

		playerCash:Update()
		
		return true
	end
	
	return false
end

ReplicatedStorage.Events.Units.ChangeTargetUnit.OnServerInvoke = function(player, unitRequest)
	
	if Units[unitRequest] then		
		local currentUnit = Units[unitRequest]

		currentUnit:NextTargetMode()

		ReplicatedStorage.Events.Units.UpdateUnitUI:FireClient(player, currentUnit.Unit)
	end	
	
end

ServerEvents.Economy.ActivateFarms.Event:Connect(function()
	local Farms = {}
	
	for id, unit in pairs(Units) do
		if unit.UnitMode == "Farm" then
			table.insert(Farms, id)
		end
	end
	
	for _,farmId in pairs(Farms) do
		if Units[farmId].ReceiveCashRound and type(Units[farmId].ReceiveCashRound) == 'function' then
			Units[farmId].ReceiveCashRound()
		end		
	end

end)