local function isInteger(x)
	return math.floor(x)==x
end

function CHUDGetOption(key)
	if CHUDOptions[key] ~= nil then
		if CHUDOptions[key].disabled then
			local ret = ConditionalValue(CHUDOptions[key].disabledValue == nil, CHUDOptions[key].defaultValue, CHUDOptions[key].disabledValue)
			return ret
		else
			return CHUDOptions[key].currentValue
		end
	end
	
	return nil
end

function CHUDGetOptionParam(key, param)
	if CHUDOptions[key][param] ~= nil then
		return CHUDOptions[key][param]
	end
	
	return nil
end

function CHUDGetOptionAssocVal(key)
	if CHUDOptions[key] ~= nil and CHUDOptions[key].type == "select" and CHUDOptions[key].valueType == "int" then
		return CHUDOptions[key].valueTable[CHUDOptions[key].currentValue+1]
	end
	
	return nil
end

function CHUDGetOptionVals(key)
	if CHUDOptions[key] ~= nil and CHUDOptions[key].type == "select" and CHUDOptions[key].valueType == "int" then
		return CHUDOptions[key].valueTable
	end
	
	return nil
end

function CHUDSetOption(key, value)
	local setValue = nil
	
	if CHUDOptions[key] ~= nil then
	
		option = CHUDOptions[key]
		oldValue = option.currentValue
				
		if option.valueType == "bool" then
			if value == "true" or value == "1" or value == true then
				Client.SetOptionBoolean(option.name, true)
				option.currentValue = true
				setValue = option.currentValue
			elseif value == "false" or value == "0" or value == false then
				Client.SetOptionBoolean(option.name, false)
				option.currentValue = false
				setValue = option.currentValue
			end
			
		elseif option.valueType == "float" then
			local number = tonumber(value)
			local multiplier = option.multiplier or 1
			if IsNumber(number) and number >= option.minValue * multiplier and number <= option.maxValue * multiplier then
				number = number / multiplier
				Client.SetOptionFloat(option.name, number)
				option.currentValue = number
				setValue = option.currentValue
			end
			
		elseif option.valueType == "int" then
			local number = tonumber(value)
			if IsNumber(number) and isInteger(number) and number >= 0 and number < #option.values then
				Client.SetOptionInteger(option.name, number)
				option.currentValue = number
				setValue = option.currentValue
			end
		end
		
		// Don't waste time reapplying settings we already have active
		if oldValue ~= option.currentValue and option.applyFunction and option.disabled == nil then
			option.applyFunction()
		end
		
	end
	
	return setValue
end

function GetCHUDSettings()
	for name, option in pairs(CHUDOptions) do
		// If setting is not what we expect we reset to default
		local value
		if option.valueType == "bool" then
			value = Client.GetOptionBoolean(option.name, option.defaultValue)
			if value == true or value == false then
				CHUDOptions[name].currentValue = value
			else
				CHUDSetOption(name, option.defaultValue)
			end
			
		elseif option.valueType == "float" then
			value = Client.GetOptionFloat(option.name, option.defaultValue)
			local number = tonumber(value)
			if IsNumber(number) and number >= option.minValue and number <= option.maxValue then
				CHUDOptions[name].currentValue = number
			else
				CHUDSetOption(name, option.defaultValue)
			end
			
		elseif option.valueType == "int" then
			value = Client.GetOptionInteger(option.name, option.defaultValue)
			local number = tonumber(value)
			if IsNumber(number) and isInteger(number) and number >= 0 and number < #option.values then
				CHUDOptions[name].currentValue = number
			else
				CHUDSetOption(name, option.defaultValue)
			end
		end
	end
end

local function CHUDHelp(...)
	local args = {...}
	if #args == 0 then
		// Show the options in alphabetical order
		local SortedOptions = { }
		for idx, option in pairs(CHUDOptions) do
			table.insert(SortedOptions, idx)
			table.sort(SortedOptions)
		end
		Shared.Message("-------------------------------------")
		Shared.Message("NS2+ Commands")
		Shared.Message("-------------------------------------")
		for name, origOption in pairs(SortedOptions) do
			local option = CHUDOptions[origOption]
			local helpStr = "plus " .. origOption
			if option.valueType == "float" then
				local multiplier = option.multiplier or 1
				helpStr = helpStr .. " <float> - Values: " .. option.minValue * multiplier .. " to " .. option.maxValue * multiplier
			elseif option.valueType == "int" then
				helpStr = helpStr .. " <integer> - Values: 0 to " .. #option.values-1
			elseif option.valueType == "bool" then
				helpStr = helpStr .. " <true/false> or <0/1>"
			end
			helpStr = helpStr .. " - " .. option.tooltip
			Shared.Message(helpStr)
		end
	elseif #args == 1 then
		if CHUDOptions[args[1]] ~= nil then
			option = CHUDOptions[args[1]]
			local multiplier = option.multiplier or 1
			Shared.Message("-------------------------------------")
			Shared.Message(option.label)
			Shared.Message("-------------------------------------")
			Shared.Message(option.tooltip)
			local helpStr = "Usage: plus " .. args[1]
			if option.valueType == "float" then
				helpStr = helpStr .. " <float> - Values: " .. option.minValue * multiplier .. " to " .. option.maxValue * multiplier
			elseif option.valueType == "int" then
				helpStr = helpStr .. " <integer> - Values: 0 to " .. #option.values-1
			elseif option.valueType == "bool" then
				helpStr = helpStr .. " <true/false> or <0/1>"
			end
			Shared.Message(helpStr .. " - Example (default value): plus " .. args[1] .. " " .. tostring(option.defaultValue * multiplier))
			if option.type == "select" then
				if option.valueType == "int" then
					for index, value in pairs(option.values) do
						Shared.Message("plus " .. args[1] .. " " .. index-1 .. " - " .. value)
					end
					Shared.Message("-------------------------------------")
				end
				if option.valueType == "bool" then
					if option.currentValue then
						helpStr = option.values[2]
					else
						helpStr = option.values[1]
					end
					helpStr = helpStr .. " (" .. tostring(option.currentValue) .. ")"
				else
					helpStr = option.values[option.currentValue+1]
				end
			else
				helpStr = tostring(option.currentValue * multiplier)
			end
			Shared.Message("Current value: " .. helpStr)
			Shared.Message("-------------------------------------")
				
		else
			CHUDHelp()
		end
	end
end

local function OnCommandCHUD(...)
	local args = {...}
	
	for idx, arg in pairs(args) do
		args[idx] = string.lower(arg)
	end
	
	if #args == 0 then
		CHUDHelp()

	elseif #args == 1 then
		CHUDHelp(args[1])

	elseif #args == 2 then
		if CHUDOptions[args[1]] ~= nil then
			option = CHUDOptions[args[1]]
			local multiplier = option.multiplier or 1
			local setValue = CHUDSetOption(args[1], args[2])
			if option.type == "select" then
				if option.valueType == "bool" then
					if option.currentValue then
						helpStr = option.values[2]
					else
						helpStr = option.values[1]
					end
					helpStr = helpStr .. " (" .. tostring(option.currentValue) .. ")"
				else
					helpStr = option.values[option.currentValue+1]
				end
			else
				helpStr = tostring(option.currentValue * multiplier)
			end
			if setValue ~= nil then
				Shared.Message(option.label .. " set to: " .. helpStr)
				if option.disabled then
					Shared.Message("The server admin has disabled this option (" .. option.label .. "). The option will get saved, but the blocked value will be used." )
				end
			else
				CHUDHelp(args[1])
			end
		else
			CHUDHelp()
		end
	end
end

function OnCHUDOption(msg)
	local key = msg.disabledOption
	
	if CHUDOptions[key] ~= nil then
		CHUDOptions[key].disabled = true
		if CHUDOptions[key].applyFunction then
			CHUDOptions[key].applyFunction()
		end
	end
end

Event.Hook("Console_plus", OnCommandCHUD)
Client.HookNetworkMessage("CHUDOption", OnCHUDOption)