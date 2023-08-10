local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedData = require(ReplicatedStorage:WaitForChild('ReplicatedData'))
local RNetModule = require(ReplicatedStorage:WaitForChild('RNet'))

ReplicatedData.OnAdded:Connect(function(...)
	print("Added: ", ...)
end)

ReplicatedData.OnUpdated:Connect(function(...)
	print("Updated: ", ...)
end)

ReplicatedData.OnRemoved:Connect(function(...)
	print("Removed: ", ...)
end)

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

	local Data = {
		Banned = nil,

		Stats = {
			Level = 1,
			Experience = 8,

			AttributePoints = 3,
			SkillPoints = 2,
		},

		Inventory = {
			["Apple"] = {
				["AAAA-AAAA-AAAA"] = { Quantity = 3 }
			},
			["Pear"] = {
				["BBBB-BBBB-BBBB"] = { Quantity = 6 }
			},
		},
	}

	print("Set Replicated Data: ", LocalPlayer.Name)
	ReplicatedData:SetData('PlayerData', Data, { LocalPlayer })

	task.defer(function()
		for _ = 1, 10 do
			task.wait(0.25)
			Increment(Data)
		end
		ReplicatedData:RemoveDataForPlayer('PlayerData', LocalPlayer)
	end)
end

ReplicatedData:Init()
ReplicatedData:Start()

for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
	task.defer( OnPlayerAdded, LocalPlayer )
end
Players.PlayerAdded:Connect(OnPlayerAdded)
