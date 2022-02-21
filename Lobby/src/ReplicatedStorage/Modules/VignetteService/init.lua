local physics = require(script:WaitForChild("Physics"))

local function getHorizontalFov()
	local vFov = game.Workspace.CurrentCamera.FieldOfView
	local viewportSize = game.Workspace.CurrentCamera.ViewportSize
	local aspectRatio = viewportSize.X/viewportSize.Y
	
	local cameraHeightAt1 = math.tan(math.rad(vFov) * .5)
	return math.deg(math.atan(cameraHeightAt1 * aspectRatio) * 2)
end

local function createViewModel(effects)
	local viewModel = {}
	
	local vFOV = game.Workspace.CurrentCamera.FieldOfView
	local hFOV = getHorizontalFov(vFOV)
	
	hFOV = vFOV + ((hFOV - vFOV) / 1.65)
	local corners = {
		topLeft = CFrame.new() * CFrame.Angles(math.rad(vFOV/2), math.rad(hFOV/2), 0) * CFrame.new(0,0,-5),
		topRight = CFrame.new() * CFrame.Angles(math.rad(vFOV/2), -math.rad(hFOV/2), 0) * CFrame.new(0,0,-5),
		bottomLeft = (CFrame.new() * CFrame.Angles(-math.rad(vFOV/2), math.rad(hFOV/2), 0)) * CFrame.new(0,0,-5),
		bottomRight = (CFrame.new() * CFrame.Angles(-math.rad(vFOV/2), -math.rad(hFOV/2), 0)) * CFrame.new(0,0,-5)
	}
	
	local xSize = (corners.topLeft.Position - corners.topRight.Position).magnitude
	local ySize = (corners.topLeft.Position - corners.bottomLeft.Position).magnitude
	
	viewModel.sides = {
		Top	= {
			Size = Vector3.new(.2, .2, xSize),
			Corners = {"topLeft", "topRight"}
		},
		
		Bottom = {
			Size = Vector3.new(.2, .2, xSize),
			Corners = {"bottomRight", "bottomLeft"}
		},
		
		Right= {
			Size = Vector3.new(.2, .2, ySize),
			Corners = {"topRight", "bottomRight"}
		},	
		
		Left = {
			Size = Vector3.new(.2, .2, ySize),
			Corners = {"topLeft", "bottomLeft"}
		},		
	}
	
	viewModel.sideInstances = {
		
	}
	 
	viewModel.corePart = Instance.new("Part")
	viewModel.corePart.Size = Vector3.new(.2,.2,.2)
	viewModel.corePart.Transparency = 1
	viewModel.corePart.CanCollide = false
	viewModel.corePart.Parent = game.Workspace
	
	local function updateCorePart() 
		viewModel.corePart.CFrame = game.Workspace.CurrentCamera.CFrame
	end

	
	viewModel.Connection = game:GetService("RunService").RenderStepped:connect(updateCorePart)
	
	for side,sideInfo in next, viewModel.sides do
		local part = Instance.new("Part")
		part.Anchored = false
		print(sideInfo.Size)
		part.Size = sideInfo.Size
		part.Transparency = 1
		part.Parent = game.Workspace
		part.CanCollide = false
		
		--part.CFrame = cameraCFrame * CFrame.new(corners[sideInfo.Corners[1]].Position, corners[sideInfo.Corners[2]].Position) * CFrame.new(0, 0, -sideInfo.Size.Z / 2)
		
		local c1 = CFrame.new(corners[sideInfo.Corners[1]].Position, corners[sideInfo.Corners[2]].Position) * CFrame.new(0, 0, -sideInfo.Size.Z / 2)
		local joint = physics.joint.new(part, viewModel.corePart, CFrame.new(), c1)
		
		viewModel.sideInstances[side] = {
				Object = part,
				Joint = joint
			}
		for iteration, effect in ipairs(effects) do
			local eff = effect:Clone()
			eff.Parent = part
		end
	end

	return viewModel
end

local function adjustViewModel(viewmodel,distance)
	local vFOV = game.Workspace.CurrentCamera.FieldOfView
	local hFOV = getHorizontalFov(vFOV)
	
	hFOV = vFOV + ((hFOV - vFOV) / 1.65)
	
	local corners = {
		topLeft = CFrame.new() * CFrame.Angles(math.rad(vFOV/2), math.rad(hFOV/2), 0) * CFrame.new(0,0,-distance),
		topRight = CFrame.new() * CFrame.Angles(math.rad(vFOV/2), -math.rad(hFOV/2), 0) * CFrame.new(0,0,-distance),
		bottomLeft = (CFrame.new() * CFrame.Angles(-math.rad(vFOV/2), math.rad(hFOV/2), 0)) * CFrame.new(0,0,-distance),
		bottomRight = (CFrame.new() * CFrame.Angles(-math.rad(vFOV/2), -math.rad(hFOV/2), 0)) * CFrame.new(0,0,-distance)
	}
	
	
	
	local xSize = (corners.topLeft.Position - corners.topRight.Position).magnitude
	local ySize = (corners.topLeft.Position - corners.bottomLeft.Position).magnitude
	
	
	viewmodel.sides.Top.Size = Vector3.new(.2, .2, xSize)
	viewmodel.sides.Bottom.Size = Vector3.new(.2, .2, xSize)
	viewmodel.sides.Right.Size = Vector3.new(.2, .2, ySize)
	viewmodel.sides.Left.Size = Vector3.new(.2, .2, ySize)
	
	
	for side,sideInfo in next, viewmodel.sides do
		--part.CFrame = cameraCFrame * CFrame.new(corners[sideInfo.Corners[1]].Position, corners[sideInfo.Corners[2]].Position) * CFrame.new(0, 0, -sideInfo.Size.Z / 2)
		local c1 = CFrame.new(corners[sideInfo.Corners[1]].Position, corners[sideInfo.Corners[2]].Position) * CFrame.new(0, 0, -sideInfo.Size.Z / 2)
		viewmodel.sideInstances[side].Object.Size = sideInfo.Size
		viewmodel.sideInstances[side].Joint.C1 = c1
		print("done")
	end
end

local module = {}


local vignette = {}

function vignette.new(viewmodel)
	local self = setmetatable({},{__index = vignette})
	
	self.viewmodel = viewmodel
	self.effects = {}
	self.enabled = true
	self.distance = 5
	self.updating = false
	
	self.updateConnections = {
		viewport = nil,
		fov		 = nil
	}
	
	for side, instance in next, viewmodel.sideInstances do
		for iteration, eff in ipairs(instance.Object:GetChildren()) do
			print("added effect...")
			table.insert(self.effects, eff)
		end
	end

	return self
end

function vignette:Enabled(bool)
	self.enabled = bool
	
	for iteration, effect in ipairs(self.effects) do
		effect.Enabled = self.enabled
	end
end

function vignette:SetDistance(distance)
	adjustViewModel(self.viewmodel, distance)
	self.distance = distance
end

function vignette:UpdateEnabled(bool)
	self.updating = bool
	if self.updating then
		self.updateConnections.viewport = game.Workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
			adjustViewModel(self.viewmodel,self.distance)
		end)
		
		self.updateConnections.fov = game.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			adjustViewModel(self.viewmode,self.distance)
		end)
	else
		if self.updateConnections.fov then
			self.updateConnections.fov:Disconnect()
		end
		if self.upateConnections.viewport then
			self.updateConnections.viewport:Disconnect()
		end
	end
end

function vignette:Destroy()
	for side, instance in next, self.viewmodel.sideInstances do
		instance.Object:Destroy()
	end
	self.viewmodel.Connection:Disconnect()
	self.viewmodel.corePart:Destroy()
end

function module:CreateVignette(effects)
	assert(typeof(effects) == "table", "CreateVignette only accepts a table of 'ParticleEmitter' objects!")
	
	for iteration, effect in ipairs(effects) do
		assert(typeof(effect) == "Instance", "All objects provided must be an instance 'ParticleEmitter'! You provided a " .. typeof(effect))
		assert(effect:IsA("ParticleEmitter"), "All objects provided must be an instance 'ParticleEmitter'! You provided a ".. effect.ClassName)
	end
	
	local viewModel = createViewModel(effects)
	
	local vig = vignette.new(viewModel)
	return vig
end

return module
