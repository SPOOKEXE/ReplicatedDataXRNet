
local HttpService = game:GetService('HttpService')

-- check what was EDITED and REMOVED from the previous dictionary
local function deepDictionaryComparison( new_dict, old_dict, visited )
	visited = visited or {}

	local editedDict = { }
	for propName, propValue in pairs( new_dict ) do
		-- if index does not exist in old dictionary
		-- whole tree was appended
		local oldValue = old_dict[propName]
		if oldValue == nil then
			editedDict[propName] = propValue
			continue
		end
		-- instance checking, otherwise json-encode comparison (tables & values supported)
		if typeof(propValue) == 'Instance' or typeof(oldValue) == 'Instance' then
			if propValue == oldValue then
				continue
			end
		elseif HttpService:JSONEncode(propValue) == HttpService:JSONEncode(oldValue) then
			continue
		end
		if typeof(propValue) == "table" and typeof(oldValue) == "table" then
			-- caching for cyclic tables
			if visited[propValue] then
				editedDict[propName] = visited[propValue]
				continue
			end
			-- table-table comparison
			local nestedEdit, nestedRemoved = deepDictionaryComparison( propValue, oldValue, visited )
			local nestData = { __ADD = nestedEdit, __REM = nestedRemoved }
			visited[propValue] = nestData
			editedDict[propName] = nestData
		else
			editedDict[propName] = propValue
		end
	end

	local removedKeys = { }
	for propName, _ in pairs( old_dict ) do
		if new_dict[propName] == nil then -- was removed
			table.insert(removedKeys, propName)
		end
	end

	return editedDict, removedKeys
end

local function deepCopy(reference)
	local clonedTable = {}
	if typeof(reference) == "table" then
		for k,v in pairs(reference) do
			clonedTable[deepCopy(k)] = deepCopy(v)
		end
	else
		clonedTable = reference
	end
	return clonedTable
end

local function applyComparisonDictionary( target, edits, removed )
	target = deepCopy(target)
	local function recurseApply( parent, ADD, REM )
		for propName, propValue in pairs(ADD) do
			if typeof(propValue) == "table" and (propValue.__ADD or propValue.__REM) then
				recurseApply( parent[propName], propValue.__ADD, propValue.__REM )
			else
				parent[propName] = propValue
			end
		end
		for _, remName in ipairs( REM ) do
			parent[remName] = nil
		end
	end
	recurseApply( target, edits, removed )
	return target
end

local new_dict = {
	epic = false,
	inventory = {
		["aaaa"] = { Quantity = 1, },
		["aaaa2"] = { Quantity = 1, }
	},
	bread = {
		Quantity = 1,
	}
}

local old_dict = {
	epic = true,
	inventory = {
		["aaaa"] = { Quantity = 1, },
		["aaaa3"] = { Quantity = 1, }
	}
}


local edits, removed = deepDictionaryComparison( new_dict, old_dict )
print(edits, removed)

local appliedOld = applyComparisonDictionary( old_dict, edits, removed )

print(old_dict, appliedOld, new_dict)
print( HttpService:JSONDecode(new_dict) == HttpService:JSONDecode(appliedOld) )
