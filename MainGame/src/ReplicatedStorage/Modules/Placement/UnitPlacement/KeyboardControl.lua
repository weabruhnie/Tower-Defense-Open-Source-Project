local UserInputService = game:GetService("UserInputService")
local Mouse = game.Players.LocalPlayer:GetMouse()

local Events = game.ReplicatedStorage.Events

local SoundService = game:GetService("SoundService")

local RunService = game:GetService("RunService")

return function(placement, unitInfo, playingUI, placeClone, rayCastParams, EffectVol)
	local Map = workspace:WaitForChild("Map")
	
	Mouse.TargetFilter = placeClone -- This insures that it won't lag
	
	local MousePlacingConnect
	
	local Rotation = 0
	
	placeClone:SetPrimaryPartCFrame(CFrame.new(Mouse.Hit.p.X, Mouse.Hit.p.Y, Mouse.Hit.p.Z) * CFrame.new(Vector3.new(0,placeClone.PrimaryPart.Size.Y*1.5,0)) * CFrame.Angles(0,math.rad(Rotation),0))
	
	MousePlacingConnect = RunService.RenderStepped:Connect(function()	
		playingUI.PlacementLabel.Visible = true

		local mouseLocation = UserInputService:GetMouseLocation()

		playingUI.PlacementLabel.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y)

		if placeClone.Parent ~= workspace.LocalPlace then MousePlacingConnect:Disconnect() return end

		local rayOrigin = placeClone.PrimaryPart.Position
		local rayDirection = Vector3.new(0, -100, 0)

		local raycastResult = workspace:Raycast(rayOrigin, rayDirection, rayCastParams)

		placeClone:SetPrimaryPartCFrame(CFrame.new(Mouse.Hit.p.X, Mouse.Hit.p.Y, Mouse.Hit.p.Z) * CFrame.new(Vector3.new(0,placeClone.PrimaryPart.Size.Y*1.5,0)) * CFrame.Angles(0,math.rad(Rotation),0))

		if raycastResult and Mouse.Target then

			local raycastInt = raycastResult.Instance 

			if raycastInt.Parent == Map.Placeable and Mouse.Target.Parent == Map.Placeable and raycastInt.Name == unitInfo.Type and Mouse.Target.Name == unitInfo.Type then
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
	
	local RotateKeyConnect

	RotateKeyConnect = UserInputService.InputBegan:Connect(function(input)
		if placeClone.Parent ~= workspace.LocalPlace then RotateKeyConnect:Disconnect() return end

		if input.KeyCode == Enum.KeyCode.R then
			Rotation += 90
			if Rotation >= 360 then
				Rotation = 0
			end
		end
	end)

	local mouseClick 

	mouseClick = Mouse.Button1Down:Connect(function()
		if placeClone.Parent ~= workspace.LocalPlace then mouseClick:Disconnect() return end

		if placement.RequestingPlace then return end

		if not placement.isPlaceable then return end

		if MousePlacingConnect then MousePlacingConnect:Disconnect() end
		if RotateKeyConnect then RotateKeyConnect:Disconnect() end

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

		playingUI.PlacementLabel.Visible = false

		placement.RequestingPlace = false
		placement.Placing = false

		mouseClick:Disconnect()
	end)

	local cancelButton

	cancelButton = UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Q then					
			if MousePlacingConnect then MousePlacingConnect:Disconnect() end
			if RotateKeyConnect then RotateKeyConnect:Disconnect() end
			if mouseClick then mouseClick:Disconnect() end

			placeClone:Destroy()

			playingUI.PlacementLabel.Visible = false

			placement.Placing = false

			cancelButton:Disconnect()			
		end
	end)


end
