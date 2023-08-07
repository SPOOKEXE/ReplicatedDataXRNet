
local Bridges = require(script.Bridges)

export type Packet = Bridges.Packet
export type ServerBridge = Bridges.ServerBridge
export type ClientBridge = Bridges.ClientBridge

-- // Module // --
local Module = {}

function Module.Create( bridgeName : string ) : ServerBridge | ClientBridge
	return Bridges.Create(bridgeName)
end

function Module.StartService()
	Bridges.StartService()
end

function Module.PauseService()
	Bridges.PauseService()
end

task.defer(function()
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	Bridges.StartService()
end)

return Module
