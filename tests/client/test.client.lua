
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedData = require(ReplicatedStorage:WaitForChild('ReplicatedData'))
local RNetModule = require(ReplicatedStorage:WaitForChild('RNet'))

ReplicatedData.OnUpdate:Connect(print)

ReplicatedData:Init()
ReplicatedData:Start()