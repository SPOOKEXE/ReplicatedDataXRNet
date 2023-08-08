
local RunService = game:GetService('RunService')

local RNet = require(script.Parent.RNet)
local Event = require(script.Event)
local Table = require(script.Table)

local DataReplication = RNet.Create("DataReplication")

local ReplicateEnums = {
	Create = 1,
	Update = 2,
	Remove = 3,
}

-- // Module // --
local Module = {}

local ReplicationUpdated = Event.New("ReplicationUpdated")
Module.ReplicationUpdated = ReplicationUpdated

if RunService:IsServer() then

	Module.IndexBlacklist = { "Tags", "Banned", "DeletedSaves", "BanHistory" }

	local Replications = { }
	local TableComparisonCache = {}

	function Module:SetDataForCategory( category : string, reference : any, whitelistPlayers : { Player }? )

	end

	function Module:SetDataForId( id : string, reference : any, whitelistPlayers : { Player }? )

	end

	function Module:GetDataFromCategory( category : string, yield : boolean? )

	end

	function Module:GetDataFromId( id : string, yield : boolean? )

	end

	function Module:RemoveCategory( category : string, blacklist : { Player }? )

	end

	function Module:RemoveId( id : string )

	end

	function Module:Start()

	end

	function Module:Init( _ )

	end

else

	local DataCache = {}

	function Module:GetDataFromCategory( category : string, yield : boolean? )

	end

	function Module:GetDataFromId( id : string, yield : boolean? )

	end

	function Module:Start()

	end

	function Module:Init( _ )

	end

end

return Module
