local Admins = {""} 

local Commands = require(game.ServerStorage.Chat.Commands)

local function PlayerAdded(Player)
	if Player:GetRankInGroup(3206627) >= 254 then
		
		Player.Chatted:Connect(function(msg)
			local loweredString = string.lower(msg)
			local args = string.split(loweredString," ")

			if Commands[args[1]] then
				return Commands[args[1]](Player, args)
			end
		end)
		
	end
end


game.Players.PlayerAdded:Connect(PlayerAdded)