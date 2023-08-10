local RunService = game:GetService('RunService')

local EventClass = require(script.Event)
local TableUtility = require(script.Table)

local RNetModule = require(script.Parent.RNet)
local Bridge = RNetModule.Create("ReplicatedData")

local RemoteEnums = {
	Set = 1,
	Update = 2,
	Remove = 3,
}

-- // Module // --
local Module = {}

local OnUpdatedEvent = EventClass.New()
Module.OnUpdated = OnUpdatedEvent

if RunService:IsServer() then

	Module.Comparison = { Public = {}, Private = {}, }
	Module.Replications = { Public = {}, Private = {}, }

	local function CheckComparisonUpdate( category, data, whitelist : { Player }? )

	end

	function Module:SetCategory( category : string, data : any, whitelist : { Player }? )
		if whitelist then
			
		else

		end
	end

	function Module:GetFirst( category : string )

	end

	function Module:GetAll( category : string )

	end

	function Module:RemoveFirst( category : string )

	end

	function Module:RemoveAll( category : string )

	end

	function Module:RemoveAllForPlayer( LocalPlayer : Player )

	end

else

	Module.Replications = { }

	function Module:GetData( category : string, yield : boolean? )

	end

end

return Module
