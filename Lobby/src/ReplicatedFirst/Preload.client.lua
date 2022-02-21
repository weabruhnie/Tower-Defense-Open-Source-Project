local ContentProvider = game:GetService("ContentProvider")

local RS = game:GetService("ReplicatedStorage")

local OpenCrateVisual = require(RS:WaitForChild("Modules").OpenCrateVisual)

local ThingsToLoad = {}

for _,anim in pairs(OpenCrateVisual.Animations) do
	local newAnim = Instance.new("Animation")
	newAnim.AnimationId = anim
	table.insert(ThingsToLoad, newAnim)
end

for _,sound in pairs(OpenCrateVisual.Sounds) do
	local newSound = Instance.new("Sound")
	newSound.SoundId = sound
	table.insert(ThingsToLoad, newSound)
end

for _,s in pairs(RS:WaitForChild("Sounds"):GetDescendants()) do
	if s:IsA("Sound") then
		table.insert(ThingsToLoad, s)
	end
end

ContentProvider:PreloadAsync(ThingsToLoad)