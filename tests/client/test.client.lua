
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

ReplicatedData:Init()
ReplicatedData:Start()
