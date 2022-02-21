local physics = {}
physics.joint = {}

function physics.joint.new(p0, p1, c0, c1)
	local joint 			= Instance.new("Weld")
		
	joint.Part0				= p0
	joint.Part1				= p1
	if c0 then
		joint.C0 			= c0
		joint.C1			= c1 or CFrame.new()
	else
		joint.C0			= CFrame.new()
		joint.C1			= p1.CFrame:toObjectSpace(p0.CFrame)
	end
		
	joint.Parent			= p1
		
	return joint
end
	
function physics.joint.combine(model, root)
	for iteration, descendant in ipairs(model:GetChildren()) do
		if (descendant:IsA("BasePart") or descendant:IsA("UnionOperation")) and descendant ~= root then
			physics.joint.new(descendant, root)
			descendant.Anchored = false
		end
		root.Anchored = false
	end
end 

return physics
