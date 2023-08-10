local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedData = require(ReplicatedStorage:WaitForChild('ReplicatedData'))
local RNetModule = require(ReplicatedStorage:WaitForChild('RNet'))

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
		while true do
			task.wait(0.25)
			Data.Stats.Experience += 8
			if Data.Stats.Experience % 48 == 0 then
				Data.Stats.Experience = 0
				Data.Stats.Level += 1
				Data.Inventory.Apple["AAAA-AAAA-AAAA"].Quantity += 2
				Data.Inventory.Pear["BBBB-BBBB-BBBB"].Quantity += 1
			end
		end
	end)
end

for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
	task.defer( OnPlayerAdded, LocalPlayer )
end
Players.PlayerAdded:Connect(OnPlayerAdded)

ReplicatedData:Init()
ReplicatedData:Start()
