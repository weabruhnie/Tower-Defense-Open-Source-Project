local person = workspace.Snoobper

local Weld = Instance.new("Weld")

Weld.Parent = workspace

Weld.Part0 = person["Right Arm"]
Weld.Part1 = person["Sniper Rifle"].Body

Weld.C0 = person["Right Arm"].Attachment.CFrame
Weld.C1 = person["Sniper Rifle"].Body.Attachment.CFrame