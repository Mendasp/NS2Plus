local kCHUDUnrecognizedOptionMsg = "Unrecognized option. Type \"plus\" to see a list of available options or change them in the NS2+ Options menu."

-- Wrap the text so it fits on screen
local function PrintConsoleText(text)
	local item = GetGUIManager():CreateTextItem()
	item:SetFontName(Fonts.kArial_15)
	
	Shared.Message(WordWrap(item, text, 0, Client.GetScreenWidth()-10))
	
	GUI.DestroyItem(item)
end

local function isInteger(x)
	return math.floor(x)==x
end

function CHUDGetOption(key)
	if CHUDOptions[key] ~= nil then
		if CHUDOptions[key].disabled then
			local ret = ConditionalValue(CHUDOptions[key].disabledValue == nil, CHUDOptions[key].defaultValue, CHUDOptions[key].disabledValue)
			return ret
		elseif CHUDOptions["castermode"] and CHUDOptions["castermode"].currentValue and not CHUDOptions[key].ignoreCasterMode then
			return CHUDOptions[key].defaultValue
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
		local value
		if CHUDOptions["castermode"] and CHUDOptions["castermode"].currentValue and not CHUDOptions[key].ignoreCasterMode then
			value = CHUDOptions[key].defaultValue
		else
			value = CHUDOptions[key].currentValue
		end
		
		return CHUDOptions[key].valueTable[value+1]
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
		defaultValue = option.defaultValue
				
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
			elseif value == "reset" or value == "default" then
				Client.SetOptionBoolean(option.name, defaultValue)
				option.currentValue = defaultValue
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
			elseif value == "reset" or value == "default" then
				Client.SetOptionFloat(option.name, defaultValue)
				option.currentValue = defaultValue
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
			elseif value == "reset" or value == "default" then
				Client.SetOptionInteger(option.name, defaultValue)
				option.currentValue = defaultValue
				setValue = option.currentValue
			end
			
		elseif option.valueType == "color" then
			local number = tonumber(value)
			if IsNumber(number) then
				Client.SetOptionInteger(option.name, number)
				option.currentValue = number
				setValue = option.currentValue
			elseif value == "reset" or value == "default" then
				Client.SetOptionInteger(option.name, defaultValue)
				option.currentValue = defaultValue
				setValue = option.currentValue
			end
		end
		
		-- Don't waste time reapplying settings we already have active
		if oldValue ~= option.currentValue and option.applyFunction and option.disabled == nil and not CHUDMainMenu then
			option.applyFunction()
		end
		
	end
	
	return setValue
end

function GetCHUDSettings()
	-- Set the default to something different than the current one
	local lastCHUD = Client.GetOptionInteger("CHUD_LastCHUDVersion", 0)
	
	if lastCHUD < kCHUDVersion then
		Client.SetOptionInteger("CHUD_LastCHUDVersion", kCHUDVersion)
	end
	
	for name, option in pairs(CHUDOptions) do
		-- If setting is not what we expect we reset to default
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
			
		elseif option.valueType == "color" then
			value = Client.GetOptionInteger(option.name, option.defaultValue)
			local number = tonumber(value)
			if IsNumber(number) and isInteger(number) then
				CHUDOptions[name].currentValue = number
			else
				CHUDSetOption(name, option.defaultValue)
			end
		end
		
		if lastCHUD < kCHUDVersion and option.resetSettingInBuild and kCHUDVersion >= option.resetSettingInBuild and lastCHUD < option.resetSettingInBuild then
			PrintConsoleText(string.format("[NS2+] The default setting for \"%s\" was changed in NS2+ build %d, resetting to default.", option.label, option.resetSettingInBuild))
			if option.type == "slider" then
				local multiplier = option.multiplier or 1
				CHUDSetOption(name, option.defaultValue * multiplier )
			else
				CHUDSetOption(name, option.defaultValue )
			end
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

	PrintConsoleText("-------------------------------------")
	PrintConsoleText("NS2+ Commands")
	PrintConsoleText("-------------------------------------")
	for i=1+(linesPerPage*curPage),linesPerPage*curPage+linesPerPage do
		local option = CHUDOptions[SortedOptions[i]]
		if option then
			local helpStr = "plus " .. SortedOptions[i]
			if option.valueType == "float" then
				local multiplier = option.multiplier or 1
				helpStr = helpStr .. " <float> - Values: " .. option.minValue * multiplier .. " to " .. option.maxValue * multiplier .. " or reset/default"
			elseif option.valueType == "int" then
				helpStr = helpStr .. " <integer> - Values: 0 to " .. #option.values-1 .. " or cycle or reset/default"
			elseif option.valueType == "bool" then
				helpStr = helpStr .. " <true/false> or <0/1> or cycle or reset/default"
			elseif option.valueType == "color" then
				helpStr = helpStr .. " <Red (0-255)> <Green (0-255)> <Blue (0-255> or reset/default"
			end
			helpStr = helpStr .. " - " .. option.tooltip
			PrintConsoleText(helpStr)
		end
	end
	PrintConsoleText("-------------------------------------")
	PrintConsoleText(string.format("Page %d of %d. Type \"plus page <number>\" to see other pages.", curPage+1, numPages))
	PrintConsoleText("-------------------------------------")
end

local function CHUDHelp(optionName)
	
	if CHUDOptions[optionName] ~= nil then
		option = CHUDOptions[optionName]
		local multiplier = option.multiplier or 1
		PrintConsoleText("-------------------------------------")
		PrintConsoleText(option.label)
		PrintConsoleText("-------------------------------------")
		PrintConsoleText(option.tooltip)
		local default = option.defaultValue
		local helpStr = "Usage: plus " .. optionName
		if option.valueType == "float" then
			helpStr = helpStr .. " <float> - Values: " .. option.minValue * multiplier .. " to " .. option.maxValue * multiplier .. " or reset/default"
			default = default * multiplier
		elseif option.valueType == "int" then
			helpStr = helpStr .. " <integer> - Values: 0 to " .. #option.values-1 .. " or cycle or reset/default"
		elseif option.valueType == "bool" then
			helpStr = helpStr .. " <true/false> or <0/1> or cycle or reset/default"
		elseif option.valueType == "color" then
			helpStr = helpStr .. " <Red (0-255)> <Green (0-255)> <Blue (0-255> or reset/default"
			local tmpColor = ColorIntToColor(default)
			default = tostring(math.floor(tmpColor.r*255)) .. " " .. tostring(math.floor(tmpColor.g*255)) .. " " .. tostring(math.floor(tmpColor.b*255))
		end
		PrintConsoleText(helpStr .. " - Example (default value): plus " .. optionName .. " " .. tostring(default))
		if option.type == "select" then
			if option.valueType == "int" then
				for index, value in pairs(option.values) do
					PrintConsoleText("plus " .. optionName .. " " .. index-1 .. " - " .. value)
				end
				PrintConsoleText("-------------------------------------")
				helpStr = option.values[option.currentValue+1]
			elseif option.valueType == "bool" then
				if option.currentValue then
					helpStr = option.values[2]
				else
					helpStr = option.values[1]
				end
				helpStr = helpStr .. " (" .. tostring(option.currentValue) .. ")"
			end
		elseif option.valueType == "color" then
			local tmpColor = ColorIntToColor(option.currentValue)
			helpStr = tostring(math.floor(tmpColor.r*255)) .. " " .. tostring(math.floor(tmpColor.g*255)) .. " " .. tostring(math.floor(tmpColor.b*255))
		else
			helpStr = tostring(Round(option.currentValue * multiplier), 4)
		end
		PrintConsoleText("Current value: " .. helpStr)
		PrintConsoleText("-------------------------------------")
			
	else
		PrintConsoleText(kCHUDUnrecognizedOptionMsg)
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

	elseif #args > 1 and args[1] ~= "page" then
		if CHUDOptions[args[1]] ~= nil then
			option = CHUDOptions[args[1]]
			local multiplier = option.multiplier or 1
			if option.valueType == "color" and args[2] ~= "reset" and args[2] ~= "default" then
				local r = tonumber(args[2])
				local g = tonumber(args[3]) or 0
				local b = tonumber(args[4]) or 0
				if IsNumber(r) and IsNumber(g) and IsNumber(b) then
					r = math.max(0, math.min(r, 255))
					g = math.max(0, math.min(g, 255))
					b = math.max(0, math.min(b, 255))
					args[2] = bit.lshift(r, 16) + bit.lshift(g, 8) + b
				else
					args[2] = nil
				end
			end
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
			elseif option.valueType == "color" then
				local tmpColor = ColorIntToColor(option.currentValue)
				helpStr = tostring(math.floor(tmpColor.r*255)) .. " " .. tostring(math.floor(tmpColor.g*255)) .. " " .. tostring(math.floor(tmpColor.b*255))
			else
				helpStr = tostring(option.currentValue * multiplier)
			end
			if setValue ~= nil then
				local mainMenu = GetCHUDMainMenu()
				if mainMenu and mainMenu.CHUDOptionElements then
					if option.valueType == "bool" then
						mainMenu.CHUDOptionElements[option.name]:SetOptionActive(setValue == true and 2 or 1)
					elseif option.valueType == "int" then
						mainMenu.CHUDOptionElements[option.name]:SetOptionActive(setValue+1)
					elseif option.valueType == "float" then
						local multiplier = option.multiplier or 1
						local minValue = option.minValue or 0
						local maxValue = option.maxValue or 1
						local value = (setValue - minValue) / (maxValue - minValue)
						mainMenu.CHUDOptionElements[option.name]:SetValue(value)
					elseif option.valueType == "color" then
						mainMenu.CHUDOptionElements[option.name]:GetBackground():SetColor(ColorIntToColor(setValue))
						mainMenu.colorPickerWindow:SetIsVisible(false)
						if option.defaultValue == setValue then
							mainMenu.CHUDOptionElements[option.name].text:SetIsVisible(true)
							-- Invert color
							mainMenu.CHUDOptionElements[option.name].text:SetColor(ColorIntToColor(0xFFFFFF - setValue))
							mainMenu.CHUDOptionElements[option.name].resetOption:SetIsVisible(false)
						else
							mainMenu.CHUDOptionElements[option.name].text:SetIsVisible(false)
							mainMenu.CHUDOptionElements[option.name].resetOption:SetIsVisible(true)
						end
					end
				end
				PrintConsoleText(option.label .. " set to: " .. helpStr)
				if option.disabled then
					PrintConsoleText("The server admin has disabled this option (" .. option.label .. "). The option will get saved, but the blocked value will be used." )
				end
			else
				CHUDHelp(args[1])
			end
		else
			PrintConsoleText(kCHUDUnrecognizedOptionMsg)
		end
	elseif #args == 2 and args[1] == "page" and IsNumber(tonumber(args[2])) then
		CHUDPrintCommandsPage(args[2])
	else
		PrintConsoleText(kCHUDUnrecognizedOptionMsg)
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
		local skipOptions = { }
		local OptionsMenuTable = {}
		local categoryOrder = {
			ui = 1,
			hud = 2,
			damage = 3,
			minimap = 4,
			sound = 5,
			graphics = 6,
			stats = 7,
			misc = 8
		}

		-- If an option has hidden children, add them (and their children...) to the skip table
		local function SkipChildren(option)
			if option.children then
				local show = true
				for _, value in pairs(option.hideValues) do
					if option.currentValue == value then
						show = false
					end
				end

				-- Skip children if we skipped the parent
				if skipOptions[option.name] then
					show = false
				end

				for _, optionIndex in pairs(option.children) do
					local optionName = CHUDGetOptionParam(optionIndex, "name")
					if optionName and not show then
						skipOptions[optionName] = true

						SkipChildren(CHUDOptions[optionIndex])
					end
				end
			end
		end

		for idx, option in pairs(CHUDOptions) do
			if not OptionsMenuTable[option.category] then
				OptionsMenuTable[option.category] = {}
			end
			table.insert(OptionsMenuTable[option.category], CHUDOptions[idx])
			
			-- Add the options that are hidden in the options menu here so we don't print them later
			SkipChildren(option)
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
		
		local CHUDOptionsMenu = {}
		for name, category in pairs(OptionsMenuTable) do
			table.sort(category, CHUDOptionsSort)
			table.insert(CHUDOptionsMenu, {
				name = string.upper(name) .. " TAB",
				options = OptionsMenuTable[name],
				sort = categoryOrder[name],
			})
		end
		
		table.sort(CHUDOptionsMenu, CHUDOptionsSort)
		
		local function PrintSetting(optionIdx)
			if not skipOptions[optionIdx.name] then
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
				elseif optionIdx.valueType == "color" then
					if currentValue == optionIdx.defaultValue then
						currentValue = "Default"
					else
						local tmpColor = ColorIntToColor(currentValue)
						currentValue = tostring(math.floor(tmpColor.r*255)) .. " " .. tostring(math.floor(tmpColor.g*255)) .. " " .. tostring(math.floor(tmpColor.b*255))
					end
				end
				local optionString = optionIdx.label .. ": " .. currentValue .. "\r\n"
				settingsFile:write(optionString)
			end
		end
		
		for _, category in pairs(CHUDOptionsMenu) do
			settingsFile:write(category.name .. "\r\n-----------\r\n")
			for _, option in ipairs(category.options) do
				PrintSetting(option)
			end
			settingsFile:write("\r\n")
		end
		
		settingsFile:write("\r\nDate exported: " .. CHUDFormatDateTimeString(Shared.GetSystemTime()))
		
		PrintConsoleText("Exported NS2+ config. You can find it in \"%APPDATA%\\Natural Selection 2\\NS2Plus\\ExportedSettings.txt\"")
		io.close(settingsFile)
	end
end

Event.Hook("Console_plus_export", OnCommandPlusExport)

Event.Hook("Console_plus", OnCommandCHUD)
if not CHUDMainMenu then
	Client.HookNetworkMessage("CHUDOption", OnCHUDOption)
end

local function OnCommandSetPlusVersion(version)
	if Shared.GetCheatsEnabled() then
		Client.SetOptionInteger("CHUD_LastCHUDVersion", tonumber(version))
		Print("Version set to: " .. version)
	end
end

Event.Hook("Console_setplusversion", OnCommandSetPlusVersion)