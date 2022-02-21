local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game.ReplicatedStorage

local VignetteService = require(ReplicatedStorage.Modules.VignetteService)

local GachaVisual = workspace:WaitForChild("GachaVisual")
local CameraPoints = GachaVisual:WaitForChild("CameraPoints")
local SumCath = GachaVisual:WaitForChild("SumCath")
local Beam1 = SumCath:WaitForChild("SummoningBeam")
local Beam2 = SumCath:WaitForChild("SummoningBeamTwo")
local HeroSpawn = GachaVisual:WaitForChild("HeroSpawn")

local NewBeamPos = Vector3.new(420.6, 1032.458, -136.5)
local NewBeam2Pos = Vector3.new(420.6, 51.009, -136.5)

local Camera = workspace.CurrentCamera

local SummonVisualHandler = {}

function swait(TimeToWait)
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

local function TweenCameraPos(Point, Speed)
	TweenService:Create(Camera, TweenInfo.new(Speed, Enum.EasingStyle.Quart), {CFrame = Point}):Play()
end

local function CutsceneTime()
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = CameraPoints.Cam1.CFrame

	swait()

	TweenCameraPos(CameraPoints.Cam2.CFrame, 4)

	swait(4)

	TweenCameraPos(CameraPoints.Cam3.CFrame, 1)

	swait(1)
	Beam1.Transparency = 0

	TweenService:Create(Beam1, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = NewBeamPos}):Play()
	
	spawn(function()
		swait(0.25)
		TweenCameraPos(CameraPoints.Cam4.CFrame, 3)
	end)	
	
	swait(0.5)

	TweenService:Create(Beam1, TweenInfo.new(1, Enum.EasingStyle.Quart), {Transparency = 1}):Play()
	TweenService:Create(Beam2, TweenInfo.new(1, Enum.EasingStyle.Quart), {Position = NewBeam2Pos, Transparency = 1}):Play()
	
	TweenCameraPos(CameraPoints.Cam5.CFrame,1)
	swait(1)
	TweenCameraPos(CameraPoints.Cam6.CFrame,1)
	swait(1)
end

local Shiny = VignetteService:CreateVignette({GachaVisual.ShineEffect})
Shiny:Enabled(false)

function SummonVisualHandler.init(received_unit)
	swait(1)
	
	Shiny:Enabled(true)
	--Shiny:Enabled(false)
	
	CutsceneTime()
end

return SummonVisualHandler
