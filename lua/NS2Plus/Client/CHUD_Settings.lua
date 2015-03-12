local kCHUDUnrecognizedOptionMsg = "Unrecognized option. Type \"plus\" to see a list of available options or change them in the NS2+ Options menu."

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
			elseif value == "cycle" then
				Client.SetOptionBoolean(option.name, not oldValue)
				option.currentValue = not oldValue
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
			elseif value == "cycle" then
				if oldValue == #option.values-1 then
					Client.SetOptionInteger(option.name, 0)
					option.currentValue = 0
					setValue = option.currentValue
				else
					Client.SetOptionInteger(option.name, oldValue+1)
					option.currentValue = oldValue+1
					setValue = option.currentValue
				end
			end
		end
		
		// Don't waste time reapplying settings we already have active
		if oldValue ~= option.currentValue and option.applyFunction and option.disabled == nil and not CHUDMainMenu then
			option.applyFunction()
		end
		
	end
	
	return setValue
end

function GetCHUDSettings()
	// Set the default to something different than the current one
	local lastCHUD = Client.GetOptionInteger("CHUD_LastCHUDVersion", kCHUDVersion-1)
	
	if lastCHUD < kCHUDVersion then
		Client.SetOptionInteger("CHUD_LastCHUDVersion", kCHUDVersion)
	end
	
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
		
		if lastCHUD < kCHUDVersion and option.resetSettingInBuild and kCHUDVersion >= option.resetSettingInBuild and lastCHUD < option.resetSettingInBuild then
			Shared.Message(string.format("[NS2+] The default setting for \"%s\" was changed in NS2+ build %d, resetting to default.", option.label, option.resetSettingInBuild))
			CHUDSetOption(name, option.defaultValue)
		end
		
		if option.applyOnLoadComplete and option.applyFunction and not CHUDMainMenu then
			option.applyFunction()
		end
	end
end


-- Through scientific methods like taking a screenshot of the console and guessing sizes
-- I have determined that each line takes 18 pixels
local sizePerLine = 18
local SortedOptions = { }

local function CHUDPrintCommandsPage(page)

	-- Internally pages start at 0, but we display from 1 to n
	page = page-1
	-- Sort the options if they aren't sorted yet
	if #SortedOptions == 0 then
		for idx, option in pairs(CHUDOptions) do
			table.insert(SortedOptions, idx)
			table.sort(SortedOptions)
		end
	end

	local linesPerPage = math.floor((Client.GetScreenHeight() / 18)/2) - 5
	local numPages = math.ceil(#SortedOptions/linesPerPage)
	local curPage = page >= 0 and page < numPages and page or 0

	Shared.Message("-------------------------------------")
	Shared.Message("NS2+ Commands")
	Shared.Message("-------------------------------------")
	for i=1+(linesPerPage*curPage),linesPerPage*curPage+linesPerPage do
		local option = CHUDOptions[SortedOptions[i]]
		if option then
			local helpStr = "plus " .. SortedOptions[i]
			if option.valueType == "float" then
				local multiplier = option.multiplier or 1
				helpStr = helpStr .. " <float> - Values: " .. option.minValue * multiplier .. " to " .. option.maxValue * multiplier
			elseif option.valueType == "int" then
				helpStr = helpStr .. " <integer> - Values: 0 to " .. #option.values-1 .. " or cycle"
			elseif option.valueType == "bool" then
				helpStr = helpStr .. " <true/false> or <0/1> or cycle"
			end
			helpStr = helpStr .. " - " .. option.tooltip
			Shared.Message(helpStr)
		end
	end
	Shared.Message("-------------------------------------")
	Shared.Message(string.format("Page %d of %d. Type \"plus page <number>\" to see other pages.", curPage+1, numPages))
	Shared.Message("-------------------------------------")
end

local function CHUDHelp(optionName)
	
	if CHUDOptions[optionName] ~= nil then
		option = CHUDOptions[optionName]
		local multiplier = option.multiplier or 1
		Shared.Message("-------------------------------------")
		Shared.Message(option.label)
		Shared.Message("-------------------------------------")
		Shared.Message(option.tooltip)
		local default = option.defaultValue
		local helpStr = "Usage: plus " .. optionName
		if option.valueType == "float" then
			helpStr = helpStr .. " <float> - Values: " .. option.minValue * multiplier .. " to " .. option.maxValue * multiplier
			default = default * multiplier
		elseif option.valueType == "int" then
			helpStr = helpStr .. " <integer> - Values: 0 to " .. #option.values-1 .. " or cycle"
		elseif option.valueType == "bool" then
			helpStr = helpStr .. " <true/false> or <0/1> or <cycle>"
		end
		Shared.Message(helpStr .. " - Example (default value): plus " .. optionName .. " " .. tostring(default))
		if option.type == "select" then
			if option.valueType == "int" then
				for index, value in pairs(option.values) do
					Shared.Message("plus " .. optionName .. " " .. index-1 .. " - " .. value)
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
			helpStr = tostring(Round(option.currentValue * multiplier), 4)
		end
		Shared.Message("Current value: " .. helpStr)
		Shared.Message("-------------------------------------")
			
	else
		Shared.Message(kCHUDUnrecognizedOptionMsg)
	end
end

local function OnCommandCHUD(...)
	local args = {...}
	
	for idx, arg in pairs(args) do
		args[idx] = string.lower(arg)
	end
	
	if #args == 0 then
		CHUDPrintCommandsPage(1)

	elseif #args == 1 then
		CHUDHelp(args[1])

	elseif #args == 2 and args[1] ~= "page" then
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
			Shared.Message(kCHUDUnrecognizedOptionMsg)
		end
	elseif #args == 2 and args[1] == "page" and IsNumber(tonumber(args[2])) then
		CHUDPrintCommandsPage(args[2])
	else
		Shared.Message(kCHUDUnrecognizedOptionMsg)
	end
end

local function OnCHUDOption(msg)
	local key = msg.disabledOption
	
	if CHUDOptions[key] ~= nil then
		CHUDOptions[key].disabled = true
		if CHUDOptions[key].applyFunction then
			CHUDOptions[key].applyFunction()
		end
	end
end

local function OnCommandPlusExport()
	local settingsFileName = "config://NS2Plus/ExportedSettings.txt"
	local settingsFile = io.open(settingsFileName, "w+")
	if settingsFile then
		local HUDOptionsMenu = { }
		local FuncOptionsMenu = { }
		local CompOptionsMenu = { }
		
		for idx, option in pairs(CHUDOptions) do
			if option.category == "hud" then
				table.insert(HUDOptionsMenu, CHUDOptions[idx])
			elseif option.category == "func" then
				table.insert(FuncOptionsMenu, CHUDOptions[idx])
			elseif option.category == "comp" then
				table.insert(CompOptionsMenu, CHUDOptions[idx])
			end
			
			local function CHUDOptionsSort(a, b)
				if a.sort == nil then
					a.sort = "Z" .. a.name
				end
				if b.sort == nil then
					b.sort = "Z" .. b.name
				end
				
				return a.sort < b.sort
			end
			table.sort(HUDOptionsMenu, CHUDOptionsSort)
			table.sort(FuncOptionsMenu, CHUDOptionsSort)
			table.sort(CompOptionsMenu, CHUDOptionsSort)
		end
		
		local function PrintSetting(optionIdx)
			local currentValue = optionIdx.currentValue
			if optionIdx.valueType == "float" then
				currentValue = tostring(Round(currentValue * (optionIdx.multiplier or 1), 4))
			elseif optionIdx.valueType == "bool" then
				if optionIdx.currentValue == true then
					currentValue = optionIdx.values[2]
				else
					currentValue = optionIdx.values[1]
				end
			elseif optionIdx.valueType == "int" then
				currentValue = optionIdx.values[currentValue+1]
			end
			local optionString = optionIdx.label .. ": " .. currentValue .. "\r\n"
			settingsFile:write(optionString)
		end
		
		settingsFile:write("VISUAL TAB:\r\n-----------\r\n")
		for _, option in ipairs(FuncOptionsMenu) do
			PrintSetting(option)
		end
		
		settingsFile:write("\r\nHUD TAB:\r\n-----------\r\n")
		for _, option in ipairs(HUDOptionsMenu) do
			PrintSetting(option)
		end
		
		settingsFile:write("\r\nMISC TAB:\r\n-----------\r\n")
		for _, option in ipairs(CompOptionsMenu) do
			PrintSetting(option)
		end
		
		settingsFile:write("\r\nDate exported: " .. CHUDFormatDateTimeString(Shared.GetSystemTime()))
		
		Shared.Message("Exported NS2+ config. You can find it in \"%APPDATA%\\Natural Selection 2\\NS2Plus\\ExportedSettings.txt\"")
		io.close(settingsFile)
	end
end

Event.Hook("Console_plus_export", OnCommandPlusExport)

Event.Hook("Console_plus", OnCommandCHUD)
if not CHUDMainMenu then
	Client.HookNetworkMessage("CHUDOption", OnCHUDOption)
end