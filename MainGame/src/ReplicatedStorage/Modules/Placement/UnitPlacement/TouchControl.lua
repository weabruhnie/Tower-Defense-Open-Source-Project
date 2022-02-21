local UserInputService = game:GetService("UserInputService")
local Mouse = game.Players.LocalPlayer:GetMouse()

local ContextActionService = game:GetService("ContextActionService")

local Events = game.ReplicatedStorage.Events

local SoundService = game:GetService("SoundService")

local camera = game.Workspace.CurrentCamera

local length = 500

return function(placement, unitInfo, playingUI, placeClone, rayCastParams, EffectVol)
	local Map = workspace:WaitForChild("Map")
	
	Mouse.TargetFilter = placeClone

	local Rotation = 0
	
	local MobilePlaceInstruct = Instance.new("TextLabel")
	MobilePlaceInstruct.Parent = playingUI
	
	MobilePlaceInstruct.AnchorPoint = Vector2.new(0.5,1)
	MobilePlaceInstruct.Position = UDim2.fromScale(0.5,0.75)
	
	MobilePlaceInstruct.Size = UDim2.fromScale(1,0.08)
	
	MobilePlaceInstruct.BackgroundTransparency = 1
	MobilePlaceInstruct.Text = "Tap and hold to place the unit"
	MobilePlaceInstruct.TextScaled = true
	
	MobilePlaceInstruct.Font = Enum.Font.GothamBold
	MobilePlaceInstruct.TextColor3 = Color3.fromRGB(255, 255, 255)
	MobilePlaceInstruct.TextStrokeTransparency = 0

	--placeClone:SetPrimaryPartCFrame(CFrame.new(Mouse.Hit.p.X, Mouse.Hit.p.Y, Mouse.Hit.p.Z) * CFrame.new(Vector3.new(0,placeClone.PrimaryPart.Size.Y*1.5,0)) * CFrame.Angles(0,math.rad(Rotation),0))
	
	local TouchedTapConnection, TouchHoldPlace
	
	TouchedTapConnection = UserInputService.TouchTapInWorld:Connect(function(position, processedByUI)
		if processedByUI then return end
		
		if placeClone.Parent ~= workspace.LocalPlace then TouchedTapConnection:Disconnect() return end
		
		local unitRay = camera:ViewportPointToRay(position.X, position.Y)
		local TouchRayResults = workspace:Raycast(unitRay.Origin, unitRay.Direction * length, rayCastParams)

		if TouchRayResults then
			local hitPart = TouchRayResults.Instance
			local worldPosition = TouchRayResults.Position
			
			placeClone:SetPrimaryPartCFrame(CFrame.new(worldPosition) * CFrame.new(Vector3.new(0,placeClone.PrimaryPart.Size.Y*1.5,0)) * CFrame.Angles(0,math.rad(Rotation),0))
			
			local rayOrigin = placeClone.PrimaryPart.Position
			local rayDirection = Vector3.new(0, -100, 0)

			local raycastResult = workspace:Raycast(rayOrigin, rayDirection, rayCastParams)
			
			if not raycastResult then return end

			local raycastInt = raycastResult.Instance 

			if raycastInt.Parent == Map.Placeable and hitPart.Parent == Map.Placeable and raycastInt.Name == unitInfo.Type and hitPart.Name == unitInfo.Type then
				
				placement.isPlaceable = true

				if placeClone:FindFirstChild("Hitbox") then
					if #workspace.Units:GetChildren() > 0 then
						for _,currentUnit in pairs(workspace.Units:GetChildren()) do
							if currentUnit:FindFirstChild("Hitbox") then
								if (currentUnit.Hitbox.Position - placeClone.Hitbox.Position).magnitude < currentUnit.Hitbox.Size.magnitude/2 then
									placement.isPlaceable = false
								end
							end							
						end
					end
				end

			else
				placement.isPlaceable = false					
			end

			if placement.isPlaceable then
				placeClone.Range.Color = Color3.fromRGB(116, 183, 255)
			else
				placeClone.Range.Color = Color3.fromRGB(255, 48, 48)
			end
		end	
	end)

	TouchHoldPlace = UserInputService.TouchLongPress:Connect(function(TouchPositions, state, gameProcessedEvent)
		if gameProcessedEvent then return end
		
		if state == Enum.UserInputState.Begin then			
			if placeClone.Parent ~= workspace.LocalPlace then TouchHoldPlace:Disconnect() return end

			if placement.RequestingPlace then return end

			if not placement.isPlaceable then return end
			
			MobilePlaceInstruct:Destroy()
			if TouchedTapConnection then TouchedTapConnection:Disconnect() end

			placement.RequestingPlace = true

			local placingPos = placeClone.PrimaryPart.CFrame
			placeClone:Destroy()

			local sound = Instance.new("Sound", SoundService)	
			sound.PlayOnRemove = true
			
			if EffectVol then
				sound.Volume = EffectVol
			end

			local RequestingPlacement, ErrorMsg = Events.Placement.RequestPlace:InvokeServer(placement.current_unit, placement.current_skin, placingPos)

			if RequestingPlacement then
				sound.SoundId = "rbxassetid://315912428"
				sound:Destroy()

				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
					placement:startPlacing()
				else
					playingUI.Events.JustPlacedInteract:Fire(RequestingPlacement)
				end
			else
				Events.Notify.SendNotif:Fire(ErrorMsg)

				sound.SoundId = "rbxassetid://654933750"
				sound:Destroy()
			end
			
			ContextActionService:UnbindAction("Cancel")
			
			playingUI.PlacementLabel.Visible = false

			placement.RequestingPlace = false
			placement.Placing = false

			TouchHoldPlace:Disconnect()
		end
	end)
	
	local function CancelPlace(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			if TouchedTapConnection then TouchedTapConnection:Disconnect() end
			if TouchHoldPlace then TouchHoldPlace:Disconnect() end
			
			MobilePlaceInstruct:Destroy()
			
			placeClone:Destroy()

			playingUI.PlacementLabel.Visible = false

			placement.Placing = false

			ContextActionService:UnbindAction("Cancel")
		end
	end

	-- Bind action to function
	ContextActionService:BindAction("Cancel", CancelPlace, true)	
	ContextActionService:SetTitle("Cancel", "Cancel")
	ContextActionService:SetPosition("Cancel", UDim2.new(0.65, 0, 0.2, 0))
end
