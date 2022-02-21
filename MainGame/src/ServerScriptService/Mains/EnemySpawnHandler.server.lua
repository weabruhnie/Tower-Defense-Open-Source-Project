local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

local ServerStorage = game.ServerStorage
local ServerEvents = ServerStorage.Events

local EnemyController = require(ServerStorage.Modules.Enemies.EnemyController)

local MapHandler = require(ServerStorage.Modules.MapHandler)

PhysicsService:CreateCollisionGroup("Map")

PhysicsService:CreateCollisionGroup("EnemyCollision")
PhysicsService:CreateCollisionGroup("UnitCollision")

PhysicsService:CreateCollisionGroup("PlacementCollision")

PhysicsService:CreateCollisionGroup("MouseRay")

PhysicsService:CreateCollisionGroup("RangeCollision")

PhysicsService:CollisionGroupSetCollidable("EnemyCollision", "Default", false)
PhysicsService:CollisionGroupSetCollidable("UnitCollision", "Default", false)
PhysicsService:CollisionGroupSetCollidable("MouseRay", "Default", false)

PhysicsService:CollisionGroupSetCollidable("RangeCollision", "Default", false)

PhysicsService:CollisionGroupSetCollidable("PlacementCollision", "Default", false)
PhysicsService:CollisionGroupSetCollidable("PlacementCollision", "UnitCollision", false)

PhysicsService:CollisionGroupSetCollidable("RangeCollision", "UnitCollision", false)
PhysicsService:CollisionGroupSetCollidable("RangeCollision", "EnemyCollision", true)
PhysicsService:CollisionGroupSetCollidable("RangeCollision", "Map", false)
PhysicsService:CollisionGroupSetCollidable("RangeCollision", "MouseRay", false)

PhysicsService:CollisionGroupSetCollidable("RangeCollision", "RangeCollision", false)

PhysicsService:CollisionGroupSetCollidable("EnemyCollision", "Map", false)
PhysicsService:CollisionGroupSetCollidable("UnitCollision", "Map", true)

PhysicsService:CollisionGroupSetCollidable("MouseRay", "UnitCollision", true)
PhysicsService:CollisionGroupSetCollidable("MouseRay", "EnemyCollision", true)

PhysicsService:CollisionGroupSetCollidable("MouseRay", "Map", false)
PhysicsService:CollisionGroupSetCollidable("MouseRay", "PlacementCollision", false)

PhysicsService:CollisionGroupSetCollidable("EnemyCollision", "UnitCollision", false)
PhysicsService:CollisionGroupSetCollidable("EnemyCollision", "PlacementCollision", false)

PhysicsService:CollisionGroupSetCollidable("EnemyCollision", "EnemyCollision", false)
PhysicsService:CollisionGroupSetCollidable("UnitCollision", "UnitCollision", true)

-- ADDING ENEMIES

workspace.Enemies.ChildAdded:Connect(function(child)
	if child:FindFirstChild("HumanoidRootPart") then
		CollectionService:AddTag(child, "Enemies")
	end
end)

local CurrentEnemies = {}

local function AddEnemyTag(enemy)
	CurrentEnemies[enemy] = EnemyController.setup(enemy)
end

local function RemoveEnemyTag(enemy)
	if CurrentEnemies[enemy] then
		CurrentEnemies[enemy] = nil
	end
end


for _,enemy in pairs(CollectionService:GetTagged("Enemies")) do
	AddEnemyTag(enemy)
end

CollectionService:GetInstanceAddedSignal("Enemies"):Connect(AddEnemyTag)
CollectionService:GetInstanceRemovedSignal("Enemies"):Connect(RemoveEnemyTag)

ServerEvents.Enemies.GetEnemy.OnInvoke = function(enemy)
	if CurrentEnemies[enemy] then
		return CurrentEnemies[enemy]
	end
end

ServerEvents.Game.GameLost.Event:Connect(function(amt)
	MapHandler.GameEnd = true
	
	for k,v in pairs(CurrentEnemies) do
		v:Delete()
	end
end)

--local ConnectionPathUpdate

--ConnectionPathUpdate = game:GetService("RunService").Heartbeat:Connect(function()
--	MapHandler.MapPath:UpdateProgress()

--	for k,v in pairs(MapHandler.MapPath:GetAllProgress()) do
--		if CurrentEnemies[k] then
--			CurrentEnemies[k].ProgressMade = v
--		end
--	end
--end)

--ServerEvents.DamageEnemy.Event:Connect(function(enemy, dmg)
--	if CurrentEnemies[enemy] then
--		print("su")
--		CurrentEnemies[enemy].Damaged(dmg)
--	end
--end)