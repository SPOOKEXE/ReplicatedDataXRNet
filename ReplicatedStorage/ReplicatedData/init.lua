local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')

local RNet = require(script.Parent.RNet)
local Event = require(script.Event)
local Table = require(script.Table)

local DataReplication = RNet.Create("DataReplication")

local ReplicateEnums = {
	Set = 1,
	Update = 2,
	Remove = 3,
}

-- // Module // --
local Module = {}

local ReplicationUpdated = Event.New("ReplicationUpdated")
Module.ReplicationUpdated = ReplicationUpdated

if RunService:IsServer() then

	Module.IndexBlacklist = { "Tags", "Banned", "DeletedSaves", "BanHistory" }

	local ScriptUUID = HttpService:GenerateGUID(false)
	script:SetAttribute('IDD', ScriptUUID)

	-- TODO; call events to remove/set/edit data on clients

	local Replications = { }
	local UUIDToCategory = { }

	local TableComparisonCache = {}
	local function CheckIfDataUpdated( uuid : string, data : any ) : boolean
		if TableComparisonCache[uuid] then
			local cacheValue = typeof(data) == "Instance" and data or HttpService:JSONEncode(data)
			if TableComparisonCache[uuid] == cacheValue then
				return false
			end
			TableComparisonCache[uuid] = cacheValue
		else
			if typeof(data) ~= "Instance" then
				data = HttpService:JSONEncode(data)
			end
			TableComparisonCache[uuid] = data
		end
		return true
	end

	function Module:AppendDataForCategory( category : string, reference : any, whitelistPlayers : { Player }? ) : string
		if not Replications[category] then
			Replications[category] = { }
		end
		local UUID = HttpService:GenerateGUID(false)
		-- update clients
		Replications[category][UUID] = { Data = reference, Players = whitelistPlayers }
		return UUID
	end

	function Module:SetDataForId( uuid : string, reference : any, newWhitelist : {Player}? )
		local Category = UUIDToCategory[uuid]
		local Replication = Category and Replications[Category]
		if not Replication then
			return
		end

		Replication.Data = reference
		if typeof(newWhitelist) == "table" then
			-- update clients
			Replication.Players = newWhitelist
		end
	end

	function Module:GetFirstDataFromCategory( category : string, yield : boolean? )
		while true do
			local UUIDs = Replications[category]
			if UUIDs then
				for _, Data in pairs( UUIDs ) do
					return Data
				end
			end
			if not yield then
				break
			end
			task.wait(0.2)
		end
		return nil
	end

	function Module:GetDataFromId( uuid : string, yield : boolean? )
		local Category = UUIDToCategory[uuid]
		local Replication = Category and Replications[Category]
		local Data = Replication and Replication[uuid]
		while yield and (not Data) do
			task.wait(0.2)
			Category = UUIDToCategory[uuid]
			Replication = Category and Replications[Category]
			Data = Replication and Replication[uuid]
		end
		return Data
	end

	function Module:RemoveFirstCategory( category : string, blacklist : { Player }? )
		local Replication = Replications[category]
		if not Replication then
			return
		end

		for UUID, Data in pairs( Replication ) do
			if not blacklist then
				-- TODO: fire all clients
				Replication[UUID] = nil
				return
			end
			local removedPlayers = { }
			for _, BlacklistItem in ipairs( blacklist ) do
				local index = table.find( Data.Players, BlacklistItem )
				if index then
					table.remove(Data.Players, index)
					table.insert(removedPlayers, BlacklistItem)
				end
			end
			if #Data.Players == 0 then
				-- TODO: update clients
				Replication[UUID] = nil
			elseif #removedPlayers > 0 then
				-- TODO: update players
			end
			break
		end
	end

	function Module:ClearCategory( category : string, blacklist : { Player }? )
		local Replication = Replications[category]
		if not Replication then
			return
		end

		if not blacklist then
			-- TODO: fire all clients
			Replications[category] = nil
			return
		end

		for UUID, Data in pairs( Replication ) do
			local removedPlayers = { }
			for _, BlacklistItem in ipairs( blacklist ) do
				local index = table.find( Data.Players, BlacklistItem )
				if index then
					table.remove(Data.Players, index)
					table.insert(removedPlayers, BlacklistItem)
				end
			end
			if #Data.Players == 0 then
				Replication[UUID] = nil
			elseif #removedPlayers > 0 then
				-- TODO: remote
			end
		end
	end

	function Module:RemoveId( uuid : string )
		local Category = UUIDToCategory[uuid]
		if not Category then
			return
		end
		local UUIDs = Replications[Category]
		UUIDs[uuid] = nil
		UUIDToCategory[uuid] = nil
	end

	local function CheckForDataUpdates( TargetPlayer : Player? )
		-- TODO: update func
	end

	function Module:Start()

		local Debounce = {}
		DataReplication:OnServerEvent(function(LocalPlayer, UID)
			if UID ~= ScriptUUID then
				return
			end
			if Debounce[LocalPlayer.Name] and time() < Debounce[LocalPlayer.Name] then
				return
			end
			Debounce[LocalPlayer.Name] = time() + 2
			task.defer( CheckForDataUpdates, LocalPlayer )
		end)

		Players.PlayerRemoving:Connect(function(LocalPlayer)
			Debounce[LocalPlayer.Name] = nil
		end)

		task.defer(function()
			while true do
				task.wait(0.25)
				CheckForDataUpdates()
			end
		end)

	end

	function Module:Init( _ )

	end

else

	local DataCache = {}

	function Module:GetFromCategory( category : string, yield : boolean? )

	end

	function Module:GetFromUUID( uuid : string, yield : boolean? )

	end

	function Module:Start()

		--[[DataReplication:OnClientEvent(function()

		end)]]

		DataReplication:FireServer( script:GetAttribute('IDD') )

	end

	function Module:Init( _ )

	end

end

return Module
