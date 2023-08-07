local RunService = game:GetService('RunService')
local HttpService = game:GetService('HttpService')

local zlibModule = require(script.Parent.zlib)

--[[
	TODO:
	- function to convert a table into a compress string
	with instance support through UUID->Instance mapping in the data
]]

-- // Utilities // --
local function ToHex( input : string ) : string
	return string.gsub(input, ".", function(c)
		return string.format("%02X", string.byte(c :: any))
	end)
end

local function FromHex( input : string ) : string
	return string.gsub( input, "..", function(cc)
		return string.char(tonumber(cc, 16) :: number)
	end)
end

local function DeepCopy(passed_table)
	local clonedTable = {}
	if typeof(passed_table) == "table" then
		for k,v in pairs(passed_table) do
			clonedTable[DeepCopy(k)] = DeepCopy(v)
		end
	else
		clonedTable = passed_table
	end
	return clonedTable
end

local function ConvertTableToCompressedValues( array )
	-- array = DeepCopy(array)

	--[[local cachedInstances = {}
	local visited = { }

	local function deepSearch( t )
		if visited[t] then
			return
		end
		visited[t] = true
		for propName, propValue in pairs(t) do
			-- index
			if typeof(propName) == "table" then
				deepSearch( propName )
			elseif typeof(propName) == "Instance" then
				local UUID = HttpService:GenerateGUID(false)
				cachedInstances[propName] = UUID
				t[UUID] = propValue
				t[propName] = nil
			end
			-- value
			if typeof(propValue) == "table" then
				deepSearch( propValue )
			elseif typeof(propValue) == "Instance" then
				local UUID = HttpService:GenerateGUID(false)
				cachedInstances[propValue] = UUID
				t[propName] = UUID
			end
		end
	end

	deepSearch( array )]]

	array = HttpService:JSONEncode(array)
	array = ToHex(array)
	array = zlibModule.Zlib.Compress(array)
	return array--, cachedInstances
end

local function ConvertCompressedValuesToTable( compressed, instanceCache )
	compressed = zlibModule.Zlib.Decompress(compressed)
	compressed = FromHex(compressed)
	compressed = HttpService:JSONDecode(compressed)

	--[[local visited = { }

	local function deepSearch( t )
		if visited[t] then
			return
		end
		visited[t] = true
		for propName, propValue in pairs(t) do
			-- index
			if typeof(propName) == "table" then
				deepSearch( propName )
			elseif typeof(propName) == "string" then
				local inst = instanceCache[propName]
				if inst then
					t[inst] = propValue
					t[propName] = nil
				end
			end
			-- value
			if typeof(propValue) == "table" then
				deepSearch( propValue )
			elseif typeof(propValue) == "string" then
				local inst = instanceCache[propValue]
				if inst then
					t[propName] = inst
				end
			end
		end
	end

	deepSearch( compressed )]]
	return compressed
end

-- // Module // --
local Module = {}

if RunService:IsServer() then

	-- SERVER SIDE
	function Module:Fire( remoteEvent : RemoteEvent, target : Player, ARGS : { any } )
		remoteEvent:FireClient(target, ConvertTableToCompressedValues(ARGS))
	end

	function Module:FireAll( remoteEvent : RemoteEvent, ARGS : { any } )
		remoteEvent:FireAllClients(ConvertTableToCompressedValues(ARGS))
	end

	function Module:InvokeClient( remoteFunction : RemoteFunction, target : Player, ... : any? )
		remoteFunction:InvokeClient(target, ...)
	end

	function Module:ReceiveEvent( remoteEvent : RemoteEvent, callback : (...any?) -> any? )
		remoteEvent.OnServerEvent:Connect(function(playerInstance, ARGS : { any })
			local decompressed = ConvertCompressedValuesToTable(ARGS)
			callback(playerInstance, unpack(decompressed))
		end)
	end

	function Module:ReceiveInvoke( remoteFunction : RemoteFunction, callback : (...any?) -> any? )
		remoteFunction.OnServerInvoke = callback
	end

else

	-- CLIENT SIDE
	function Module:Fire( remoteEvent : RemoteEvent, ARGS : { any } )
		remoteEvent:FireServer(ConvertTableToCompressedValues(ARGS))
	end

	function Module:Invoke( remoteFunction : RemoteFunction, ... : any? )
		return remoteFunction:InvokeServer(...)
	end

	function Module:ReceiveEvent( remoteEvent : RemoteEvent, callback : (...any?) -> any? )
		remoteEvent.OnClientEvent:Connect(function(ARGS : { any })
			local value = ConvertCompressedValuesToTable(ARGS)
			callback(unpack(value))
		end)
	end

	function Module:ReceiveInvoke( remoteFunction : RemoteFunction, callback : (...any?) -> any? )
		remoteFunction.OnClientInvoke = callback
	end

end

return Module
