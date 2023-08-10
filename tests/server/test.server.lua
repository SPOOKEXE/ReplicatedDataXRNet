local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedData = require(ReplicatedStorage:WaitForChild('ReplicatedData'))
local RNetModule = require(ReplicatedStorage:WaitForChild('RNet'))

local Counter = { Value = 1 }
ReplicatedData:SetData('TestRep', Counter)

--[[ReplicatedData.OnAdded:Connect(function(...)
	print("Added: ", ...)
end)

ReplicatedData.OnUpdated:Connect(function(...)
	print("Updated: ", ...)
end)

ReplicatedData.OnRemoved:Connect(function(...)
	print("Removed: ", ...)
end)]]

local PlayerDataCache = {}

local function Increment(Data)
	Data.Stats.Experience += 8
	if Data.Stats.Experience % 48 == 0 then
		Data.Stats.Experience = 0
		Data.Stats.Level += 1
		Data.Inventory.Apple["AAAA-AAAA-AAAA"].Quantity += 2
		Data.Inventory.Pear["BBBB-BBBB-BBBB"].Quantity += 1
	end
end

local function OnPlayerAdded( LocalPlayer )

	PlayerDataCache[LocalPlayer] = {
		Banned = nil,

		Counter = 0,
		Stats = {
			Level = 1,
			Experience = 8,

			AttributePoints = 3,
			SkillPoints = 2,
		},

		Inventory = {
			Apple = {
				["AAAA-AAAA-AAAA"] = { Quantity = 3 }
			},
			Pear = {
				["BBBB-BBBB-BBBB"] = { Quantity = 6 }
			},
		},
	}

	print("Set Replicated Data: ", LocalPlayer.Name)
	ReplicatedData:SetData('PlayerData', PlayerDataCache[LocalPlayer], { LocalPlayer })
end

RNetModule.StartService()
ReplicatedData:Init()
ReplicatedData:Start()

for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
	task.defer( OnPlayerAdded, LocalPlayer )
end
Players.PlayerAdded:Connect(OnPlayerAdded)

task.defer(function()

	while true do
		task.wait(0.25)
		for playerInstance, playerData in pairs( PlayerDataCache ) do
			playerData.Counter += 1
			Counter.Value += 1
			if playerData.Counter > 30 then
				PlayerDataCache[playerInstance] = nil
				continue
			end
			Increment( playerData )
		end
	end

end)
