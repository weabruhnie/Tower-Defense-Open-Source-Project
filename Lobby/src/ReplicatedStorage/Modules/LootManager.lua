local module = {}


local function usingWeights(slots)
	for i, v in pairs(slots)do
		if(v.Weight)then
			return true
		end
		return false
	end
end


--[[
	Gets total weight between all slots
]]
function module:GetTotalWeight(slots)
	local total = 0
	for _, slot in pairs(slots) do total = total + slot.Weight end
	return total
end


--[[
	Selects a random slot from the table for you.
]]
function module:GetRandomSlot(slots)
	--get total weight/chances
	local total = usingWeights(slots) and self:GetTotalWeight(slots) or 1
	--get a random number based on total weight/chances
	local randomNumber = math.random()*total
	
	--iterate through all slots and select a random one based on weights/chances
	for _, slot in pairs(slots) do
		local n = slot.Weight or slot.Chance
		if  randomNumber <= n then
			return slot
		else
			randomNumber = randomNumber - n
		end
	end
end


--[[
	Convert Weights into percentages (for debugging purposes / visualization purposes)
	You DONT need this function to create a table based on perctanges.
]]
function module:GetChances(slots)
	local chances = {}
	local total = self:GetTotalWeight(slots)
	for key, slot in pairs(slots)do
		if(not slot.Weight)then return end

		chances[key] = {Chance = slot.Weight / total}
		
		for i, v in pairs(slot) do
			if(i ~= "Weight") then
				chances[key][i] = v		
			end
		end
	end
	return chances
end




return module