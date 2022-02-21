local NewCore = workspace.Core:Clone()
local CoreDead = false
local DialogueEvent = game.ReplicatedStorage:WaitForChild("DialogueEvent")

function wait(TimeToWait)
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

function Message(Text,Duration)
	local Msg = Instance.new("Message",workspace)
	Msg.Text = Text
	wait(Duration)
	if Msg then Msg:Destroy() end
end

function playMusic(music)
	local mu = workspace.BGMusic:FindFirstChild(music)
	if mu then
		mu:Play()
	end
end

function StopMusic()

	local BGMusic = workspace.BGMusic:GetDescendants()
	local BThemes = workspace.BossThemes:GetDescendants()

	for i,v in pairs(BGMusic) do
		if v:IsA("Sound") then
			v:Stop()
		end
	end

	for i,v in pairs(BThemes) do
		if v:IsA("Sound") then
			v:Stop()
		end
	end

end

wait(15)

local DialogSpeaker = "GAME"
	local DialogText = {
		"Welcome to Noob Defense 4",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
wait(5)
local Msg = Instance.new("Hint",workspace)
for i = 10,0,-1 do
	wait(game:GetService("RunService"):IsStudio() and 0.1 or 1)
	Msg.Text = "Vote start in "..i.." seconds"
end
Msg.Text = ""
for i = 30,0,-1 do
	--workspace.DifficultyVote.Timer.Value = i
	for _, Player in pairs(game.Players:GetPlayers()) do
		local VoteGui = Player.PlayerGui:FindFirstChild("VoteGUI")
		if VoteGui == nil then
			VoteGui = game.ServerStorage.VoteGUI:Clone()
			VoteGui.Parent = Player.PlayerGui
		end
	end
	wait(game:GetService("RunService"):IsStudio() and 0.1 or 1)
end
print("Passed voting phrase")
local ChildhoodVote = 0
local EasyVote = 0
local NormalVote = 0
local HardVote = 0
local HELLVote = 0
local NightVote = 0
for _, Player in pairs(game.Players:GetPlayers()) do
	local VoteGui = Player.PlayerGui:FindFirstChild("VoteGUI")
	if VoteGui then
		VoteGui:Destroy()
	end
	local Vote = Player:FindFirstChild("Vote")
	if Vote then
		if Vote.Value == "Childhood" then
			ChildhoodVote = ChildhoodVote + 1
		elseif Vote.Value == "Easy" then
			EasyVote = EasyVote + 1
		elseif Vote.Value == "Normal" then
			NormalVote = NormalVote + 1
		elseif Vote.Value == "Hard" then
			HardVote = HardVote + 1
		elseif Vote.Value == "HELL!" then
			HELLVote = HELLVote + 1
		elseif Vote.Value == "Nightmare" then
			NightVote = NightVote + 1
		end
	end
end
if NormalVote >= ChildhoodVote and NormalVote >= EasyVote and NormalVote >= HardVote and NormalVote >= HELLVote and NormalVote >= NightVote then
	workspace.Difficulty.Value = 0
	workspace.Stage.MaxValue = 10
	local DialogSpeaker = "GAME"
	local DialogText = {
		"Normal mode was chosen.",
		"Enemies are the same. There are 10 stages to complete.",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
elseif ChildhoodVote >= EasyVote and ChildhoodVote >= NormalVote and ChildhoodVote >= HardVote and ChildhoodVote >= HELLVote and ChildhoodVote >= NightVote then
	workspace.Difficulty.Value = -2
	workspace.Core.Humanoid.MaxHealth = 7500 workspace.Core.Humanoid.Health = 7500
	workspace.Stage.MaxValue = 1
	local DialogSpeaker = "GAME"
	local DialogText = {
		"Childhood mode was chosen. WHY?",
		"Enemies have 75% less health than usual.",
		"There is only one stage. Never choose this mode again.",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
elseif EasyVote >= ChildhoodVote and EasyVote >= NormalVote and EasyVote >= HardVote and EasyVote >= HELLVote and EasyVote >= NightVote then
	workspace.Difficulty.Value = -1
	workspace.Core.Humanoid.MaxHealth = 5000 workspace.Core.Humanoid.Health = 5000
	local DialogSpeaker = "GAME"
	local DialogText = {
		"Easy mode was chosen.",
		"Enemies have 50% less health than usual.",
		"There are only 9 stages.",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
	wait(7.5)
	workspace.Stage.MaxValue = 9
elseif HardVote >= ChildhoodVote and HardVote >= EasyVote and HardVote >= NormalVote and HardVote >= HELLVote and HardVote >= NightVote then
	workspace.Difficulty.Value = 1
	workspace.Stage.MaxValue = 11
	--workspace.ZombieMaxNPC.Value = workspace.ZombieMaxNPC.Value + 3
	local DialogSpeaker = "GAME"
	local DialogText = {
		"Hard mode was chosen.",
		"A step up to normal. Will pose a challenge to new players.",
		"Enemies will have 50% more health than usual.",
		"There will also be a extra stage, where you fight a exclusive boss only available for hard mode or higher.",
		"Good luck.",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
	wait(7.5)
elseif HELLVote >= ChildhoodVote and HELLVote >= EasyVote and HELLVote >= NormalVote and HELLVote >= HardVote and HELLVote >= NightVote then
	workspace.Difficulty.Value = 2
	workspace.Stage.MaxValue = 11
	--workspace.ZombieMaxNPC.Value = workspace.ZombieMaxNPC.Value + 5
	local DialogSpeaker = "GAME"
	local DialogText = {
		"Impossible Mode was chosen.",
		"A extremely hard difficulty to complete. Good luck.",
		"Enemies will have 100% more health than usual.",
		"Some bosses will have impossible specific abilities activated.",
		"Win this and you get the exclusive Impossible Badge,",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
	wait(7.5)
	workspace.Stage.MaxValue = 11
elseif NightVote >= ChildhoodVote and NightVote >= EasyVote and NightVote >= NormalVote and NightVote >= HardVote and NightVote >= HELLVote then
	workspace.Difficulty.Value = 3
	workspace.Core.Humanoid.MaxHealth = 1000
	workspace.Core.Humanoid.Health = 1000
	workspace.CoreLives.Value = 1
	workspace.Stage.MaxValue = 11
	local DialogSpeaker = "GAME"
	local DialogText = {
		"Wow, you guys chose Nightmare.",
		"Good luck, because this is harder than Impossible.",
		"The core only has 1,000 HP, and only 1 life.",
		"Enemies will have 1000% more health than usual.",
		"You will also face a Nightmare Exclusive boss titled ?????",
		"Win this and you get the exclusive Nightmare Badge. Good Luck.",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
	wait(7.5)
end
for i = 30,0,-1 do
	wait(1)
	Msg.Text = "Starting in "..i.." seconds"
end
if Msg then Msg:Destroy() end
local DialogSpeaker = "?????"
	local DialogText = {
		"Hmph.",
		"Hello peasants.",
		"I heard that Core of yours generates power...",
		"Too bad I will purge it from YOU!",
		"WAHHAUHUWAHUHAUHUAHWHAAH!!!!!!!!!!",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
	wait(7.5)
if workspace:FindFirstChild("Core") then
	if workspace.Core:FindFirstChild("ForceField") then workspace.Core.ForceField:Destroy() end
end
playMusic("Battle"..math.random(1,33))
workspace.AllySpawn.Disabled = false
workspace.EnemySpawn.Disabled = false

function CoreDestroyed()
	if not CoreDead then
		CoreDead = true
		local FinalBoss = workspace:FindFirstChild("Cursed Eclipser") or workspace:FindFirstChild("Corrupted Exterminator") or workspace:FindFirstChild("Rexterminator")
		if FinalBoss then
			Instance.new("ForceField",FinalBoss) --A code that preventing from winning and losing at a same time.
		end
		StopMusic()
		if workspace.CoreLives.Value > 1 then
			workspace.CoreLives.Value = workspace.CoreLives.Value - 1
			workspace.AllySpawn.Disabled = true
			workspace.EnemySpawn.Disabled = true
			if workspace.CoreLives.Value == 1 then
				local DialogSpeaker ="GAME"
				local DialogText = {
		"The Core has only 1 life left.",
		"This is our last chance! Protect harder!",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
	wait(10)
			else
				local DialogSpeaker ="GAME"
				local DialogText = {
		"The Core has "..game.Workspace.CoreLives.Value.." lives left.",
		"The stage will restart soon.",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
	wait(10)
			end
			game.ServerScriptService.Important["Game / Stage Script"].RestartGame:Fire(false)
			workspace.Core.Humanoid.Died:connect(CoreDestroyed)
			--workspace.Core:Destroy()
			--[[wait()
			local ActualNewCore = NewCore:Clone()
			ActualNewCore.Parent = workspace
			ActualNewCore:MakeJoints()
			for _, Players in pairs(game.Players:GetChildren()) do
				Players:LoadCharacter()
			end
			Message("Restarting stage soon...", 20)
			Message("Stage restarted!", 3)
			workspace.AllySpawn.Disabled = false
			workspace.EnemySpawn.Disabled = false]]
		elseif workspace.CoreLives.Value <= 1 then
			StopMusic()
			if workspace.Difficulty.Value == -2 then
				local DialogSpeaker ="?????"
				local DialogText = {
		"...................",
		"PATHETIC, YOU LOST TO MY WEAKEST ARMY.",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
	wait(6)
			else
				local DialogSpeaker ="?????"
				local DialogText = {
		"HAHAHAHAHAHAHA!",
		"NOW THE CORE IS MINE!!! >:)",
	}
	DialogueEvent:FireAllClients("SingularSpeaker", DialogSpeaker, DialogText)
	wait(6)
			end
			for _, Child in pairs(workspace:GetChildren()) do
				local Humanoid = Child:FindFirstChild("Humanoid")
				local TEAM = Child:FindFirstChild("TEAM")
				if Humanoid and TEAM and TEAM.Value == BrickColor.new("Bright green") then
					Child:Destroy()
				end
			end
			workspace.AllySpawn.Disabled = true
			workspace.EnemySpawn.Disabled = true
			local ColorCorrection = Instance.new("ColorCorrectionEffect",game.Lighting)
			for i = 0,-1,-0.025 do
				ColorCorrection.Saturation = i
				wait(0.025)
			end
			wait(5)
			workspace.GameOver:Play()
			Message("Game Over: Undead Brigade Wins.",15)
			wait(5)
			if ColorCorrection then ColorCorrection:Destroy() end
			--[[Bots:Destroy()
			AdvancedBots:Destroy()
			RangedBots:Destroy()
			MiniBosses:Destroy()
			Bosses:Destroy()
			SummonBots:Destroy()
			wait(0.5)
			BotsClone.Parent = game.ServerStorage
			RangedBotsClone.Parent = game.ServerStorage
			AdvancedBotsClone.Parent = game.ServerStorage
			SummonBotsClone.Parent = game.ServerStorage
			MiniBossesClone.Parent = game.ServerStorage
			BossesClone.Parent = game.ServerStorage--]]
			game.ServerScriptService.Important["Game / Stage Script"].RestartGame:Fire(true)
		end
		CoreDead = false
	end
end

workspace.Core.Humanoid.Died:connect(CoreDestroyed)

