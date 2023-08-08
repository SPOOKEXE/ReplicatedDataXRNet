local HttpService = game:GetService("HttpService")

local function deltaTable( old, new ) : { ["Edits"] : { [any] : any } , ["Removals"] : { any }  }
	local edits = {}
	for propName, propValue in pairs( new ) do
		-- if value does not exist in the old table, was added
		local oldValue = old[propName]
		if oldValue == nil then
			-- print("New index addition: ", propName)
			edits[propName] = propValue
			continue
		end

		if typeof(propValue) == 'Instance' or typeof(oldValue) == "Instance" then
			if propValue ~= oldValue then
				-- print("Instance at index changed: ", propName)
				edits[propName] = propValue
			end
		elseif typeof(propValue) == "table" and typeof(oldValue) == "table" then
			-- table has not changed
			if HttpService:JSONEncode(propValue) == HttpService:JSONEncode(oldValue) then
				continue
			end
			-- has changed (deepDeltaTable?)
			edits[propName] = propValue
		elseif HttpService:JSONEncode(propValue) ~= HttpService:JSONEncode(oldValue) then
			-- print("Value(s) at index changed: ", propName)
			edits[propName] = propValue
		end
	end

	-- find any deleted items
	local removals = {}
	for propName, _ in pairs( old ) do
		if new[propName] == nil then
			table.insert(removals, propName)
		end
	end

	return {Edits = edits, Removals = removals}
end

local function applyDeltaTable( target, delta )
	for propName, propValue in pairs( delta.Edits ) do
		target[propName] = propValue
	end
	for _, propName in ipairs( delta.Removals ) do
		target[propName] = nil
	end
end

local before = {
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

local after = {
	Banned = false,

	Stats = {
		Level = 2,
		Experience = 40,

		AttributePoints = 2,
		SkillPoints = 1,
	},

	Inventory = {
		["Apple"] = {
			["AAAA-AAAA-AAAA"] = { Quantity = 4 }
		},
		["Pear"] = {
			["BBBB-BBBB-BBBB"] = { Quantity = 7 }
		},
	},
}

local delta = deltaTable( before, after )
print(delta)

applyDeltaTable( before, delta )

print( HttpService:JSONEncode(before) == HttpService:JSONEncode(after) )
