local UserInputService = game:GetService("UserInputService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Database = game.ReplicatedStorage:WaitForChild("Database")
local Events = game.ReplicatedStorage.Events

local UnitsDatabase = require(Database:WaitForChild("UnitsDatabase"))

local UnitSkins = game.ReplicatedStorage:WaitForChild("UnitSkins")

local PlayerInput = require(game.ReplicatedStorage.Modules.UI.PlayerInput)

local UnitPlacement = {}

function UnitPlacement.init(slotUI, playingUI)
	local self = {
		slot_ui = slotUI,
		current_unit = slotUI:GetAttribute("Selected"),
		current_skin = slotUI:GetAttribute("CurrentSkin")
	}
	
	local EffectVol
	
	function self:setEffectVol(vol)
		EffectVol = vol
	end
	
	local Map = workspace:WaitForChild("Map")
	
	self.Placing = false
	
	self.RequestingPlace = false
	
	local unitInfo = UnitsDatabase.find(self.current_unit)
	self.slot_ui.CashCost.Text = "$" .. unitInfo.Cost
	
	function self:startPlacing()
		game.ReplicatedStorage.Events.Units.ClearAllPlacing:Fire()
		
		playingUI.UnitUpgradesUI.Visible = false
		
		for _,unit in pairs(workspace:WaitForChild("Units"):GetChildren()) do
			local foundRange = unit:FindFirstChild("Range")

			if foundRange then
				foundRange.Transparency = 1
			end
		end
		
		for _,v in pairs(workspace.LocalPlace:GetChildren()) do
			v:Destroy()
		end
		
		if self.Placing then return end
		
		self.Placing = true
		
		local unitFind = UnitSkins:FindFirstChild(self.current_unit)[self.current_skin]["1"]
		
		if unitFind and unitInfo then
			local inputType, inputEnum = PlayerInput.getInputType()
			
			local placeClone = unitFind:Clone()
			
			for _,unitPart in pairs(placeClone:GetDescendants()) do
				if unitPart:IsA("BasePart") then
					PhysicsService:SetPartCollisionGroup(unitPart, "PlacementCollision")
				end
			end
			
			placeClone.Hitbox.Transparency = 1
			
			placeClone.PrimaryPart.Anchored = true
			
			local attach1 = Instance.new("Attachment")		
			attach1.Parent = placeClone.PrimaryPart
			attach1.Position = Vector3.new(0, -1.35, 0)
			
			if self.current_unit == "Farm" then
				attach1.Position = Vector3.new(0, -0.3, 0)
			end
			
			local rangeClone = game.ReplicatedStorage.Templates.UnitTemplate.Range:Clone()	
			rangeClone.Parent = placeClone
			rangeClone.Name = "Range"
			
			rangeClone.Anchored = false
			rangeClone.CanCollide = false
			
			rangeClone.Size = Vector3.new(0.3, unitInfo.Upgrades[1].Stats.RNG, unitInfo.Upgrades[1].Stats.RNG)
			
			rangeClone.Material = Enum.Material.Plastic
			rangeClone.Transparency = 0.5
			
			local rangeWeld = Instance.new("Weld")
			rangeWeld.Name = "rangeWeld"
			rangeWeld.Part0 = rangeClone
			rangeWeld.Part1 = placeClone.PrimaryPart
			rangeWeld.C0 = rangeWeld.Part0.RangeAttach.CFrame
			rangeWeld.C1 = attach1.CFrame
			
			rangeWeld.Parent = rangeWeld.Part0
			
			placeClone.Parent = workspace.LocalPlace
			
			self.isPlaceable = false
			
			local rayCastParams = RaycastParams.new()
			rayCastParams.CollisionGroup = "UnitCollision"
			
			local InputFunc
			
			print(inputType)
			
			if inputType == "Keyboard/Mouse" then
				InputFunc = require(script.KeyboardControl)			
			elseif inputType == "Touch" then
				InputFunc = require(script.TouchControl)
			end
			
			if InputFunc then
				InputFunc(self, unitInfo, playingUI, placeClone, rayCastParams, EffectVol)
			end		
		end
		
		
	end
	
	local connectionClick = self.slot_ui.MouseButton1Click:Connect(function()
		self:startPlacing()
	end)
		
	return self
end

return UnitPlacement
