CHUDClientOptions = { }

CHUDServerOptions =
{
	allow_ambient = {
		label   = "Ambient sounds",
		tooltip = "Enables or disables the ability to disable map ambient sounds for clients.",
		valueType = "bool",
		defaultValue = true,
		},
	allow_mapparticles = {
		label   = "Map particles",
		tooltip = "Enables or disables the ability to disable the map particles for clients.",
		valueType = "bool",
		defaultValue = true,
		},
	allow_nsllights = {
		label   = "NSL Lights",
		tooltip = "Enables or disables the ability to use the NSL lights for clients.",
		valueType = "bool",
		defaultValue = true,
		},
	allow_deathstats = {
		label   = "NS2+ personal stats",
		tooltip = "Enables or disables the display of stats when players die.",
		valueType = "bool",
		defaultValue = true,
		},
	allow_drawviewmodel = {
		label   = "Draw viewmodel",
		tooltip = "Enables or disables the ability to hide player models for clients.",
		valueType = "bool",
		defaultValue = false,
		},

	autodisplayendstats = {
		label   = "End game stats autodisplay",
		tooltip = "Enables or disables the end game stats displaying automatically upon game end.",
		valueType = "bool",
		defaultValue = true,
		},
	endstatsteambreakdown = {
		label   = "End game stats team breakdown",
		tooltip = "Enables or disables the end game stats displaying the full team breakdown.",
		valueType = "bool",
		defaultValue = true,
		},
	modupdater = {
		label   = "Mod updater",
		tooltip = "Enables or disables the mod update checker.",
		valueType = "bool",
		defaultValue = true,
		},
	modupdatercheckinterval = {
		label   = "Mod updater check interval",
		tooltip = "Sets the update check interval for the mod updater (in minutes).",
		valueType = "float",
		defaultValue = 15,
		minValue = 1,
		maxValue = 999,
		},
	modupdaterreminderinterval = {
		label   = "Mod updater reminder interval",
		tooltip = "Sets the time between reminders when an update has been found. Set to 0 to disable (only shows once).",
		valueType = "float",
		defaultValue = 5,
		minValue = 0,
		maxValue = 999,
		},
	showavgteamskill = {
		label   = "Show average team skills",
		tooltip = "Shows the average team skill on the scoreboard for clients.",
		valueType = "bool",
		defaultValue = false,
		},
	showplayerskill = {
		label   = "Show player skill pregame",
		tooltip = "Shows each player's Hive skill on the scoreboard before the game starts.",
		valueType = "bool",
		defaultValue = false,
		},
	savestats = {
		label   = "Save round stats",
		tooltip = "Saves the last round stats in the NS2Plus\\Stats\\ folder in your config path in json format. Each round played will be saved in a separate file. The file name for each round is the epoch time at round end.",
		valueType = "bool",
		defaultValue = false,
		},
}

-- Compmod servers allow hidden viewmodels by default
local hasCompmod = false
local hasNSLMod = false
for modNum = 1, Server.GetNumActiveMods() do
	if Server.GetActiveModId(modNum) == "e5ffa15" or Server.GetActiveModId(modNum) == "1ecfb5cc" then
		CHUDServerOptions["allow_drawviewmodel"] = nil
		hasCompmod = true
	elseif Server.GetActiveModId(modNum) == "a2ddae8" then
		hasNSLMod = true
	end
end

if hasCompmod and hasNSLMod then
	AddCHUDTagBitmask(CHUDTagBitmask["nslserver"])
end

local configFileName = "NS2PlusServerConfig.json"

local function CHUDSaveServerConfig()
	local saveConfig = { }
	
	for index, option in pairs(CHUDServerOptions) do
		saveConfig[index] = option.currentValue
	end

	SaveConfigFile(configFileName, saveConfig)
end

function CHUDSetServerOption(key, value)
	local setValue = nil

	if CHUDServerOptions[key] ~= nil then
	
		option = CHUDServerOptions[key]
		oldValue = option.currentValue
		
		if option.valueType == "bool" then
			if value == "true" or value == "1" or value == true then
				option.currentValue = true
				setValue = option.currentValue
			elseif value == "false" or value == "0" or value == false then
				option.currentValue = false
				setValue = option.currentValue
			end
			
		elseif option.valueType == "float" then
			local number = tonumber(value)
			if IsNumber(number) and number >= option.minValue and number <= option.maxValue then
				option.currentValue = number
				setValue = option.currentValue
			end
		end
		
		if option.applyFunction then
			option.applyFunction()
		end

		-- Don't waste time saving settings we already have set like that
		if oldValue ~= option.currentValue then
			CHUDSaveServerConfig()
		end
	
	end
	
	return setValue
end

local function CHUDServerHelp(...)
	local args = {...}
	local client = args[1]
	
	if #args == 1 then
		-- Show the options in alphabetical order
		local SortedOptions = { }
		for idx, option in pairs(CHUDServerOptions) do
			table.insert(SortedOptions, idx)
			table.sort(SortedOptions)
		end
		CHUDServerAdminPrint(client, "-------------------------------------")
		CHUDServerAdminPrint(client, "NS2+ Server Settings")
		CHUDServerAdminPrint(client, "-------------------------------------")
		for name, origOption in pairs(SortedOptions) do
			local option = CHUDServerOptions[origOption]
			local helpStr = "sv_plus " .. origOption
			if option.valueType == "float" then
				helpStr = helpStr .. " <float> - Values: " .. option.minValue .. " to " .. option.maxValue
			elseif option.valueType == "bool" then
				helpStr = helpStr .. " <true/false> or <0/1>"
			end
			helpStr = helpStr .. " - " .. option.tooltip
			CHUDServerAdminPrint(client, helpStr)
		end
	elseif #args == 2 then
		if CHUDServerOptions[string.lower(args[2])] ~= nil then
			option = CHUDServerOptions[string.lower(args[2])]
			CHUDServerAdminPrint(client, "-------------------------------------")
			CHUDServerAdminPrint(client, option.label)
			CHUDServerAdminPrint(client, "-------------------------------------")
			CHUDServerAdminPrint(client, option.tooltip)
			local helpStr = "Usage: sv_plus " .. args[2]
			if option.valueType == "float" then
				helpStr = helpStr .. " <float> - Values: " .. option.minValue .. " to " .. option.maxValue
			elseif option.valueType == "bool" then
				helpStr = helpStr .. " <true/false> or <0/1>"
			end
			CHUDServerAdminPrint(client, helpStr)
			CHUDServerAdminPrint(client, "Example (default value): sv_plus " .. args[2] .. " " .. tostring(option.defaultValue))
			CHUDServerAdminPrint(client, "Current value: " .. tostring(option.currentValue))
			CHUDServerAdminPrint(client, "-------------------------------------")
				
		else
			CHUDServerHelp(client)
		end
	end
end

local function CHUDServerSetting(...)
	local args = {...}
	local client = args[1]
	
	for idx, arg in pairs(args) do
		-- First parameter is the client that ran the cmd
		if idx > 1 then
			args[idx] = string.lower(arg)
		end
	end
	
	if #args == 1 then
		CHUDServerHelp(client)

	elseif #args == 2 then
		CHUDServerHelp(client, args[2])

	elseif #args == 3 then
		if CHUDServerOptions[args[2]] ~= nil then
			option = CHUDServerOptions[args[2]]
			local setValue = CHUDSetServerOption(args[2], args[3])
		end
		
		if setValue ~= nil then
			CHUDServerAdminPrint(client, option.label .. " set to: " .. tostring(setValue))
		else
			CHUDServerHelp(client, args[2])
		end
		
	else
		CHUDServerHelp(client)
	end
end

local defaultCHUDConfig = { }
for index, option in pairs(CHUDServerOptions) do
	defaultCHUDConfig[index] = option.defaultValue
end

WriteDefaultConfigFile(configFileName, defaultCHUDConfig)

local config = LoadConfigFile(configFileName) or defaultCHUDConfig

for option, value in pairs(config) do
	-- Make sure the option exists in our table
	if CHUDServerOptions[option] then
		CHUDServerOptions[option].currentValue = value
		local setValue = CHUDSetServerOption(option, value)
		if setValue == nil and CHUDServerOptions[option] then
			CHUDSetServerOption(option, CHUDServerOptions[option].defaultValue)
		end
	end
end

-- Add blocked options to a table so when clients connect we can send them a command to do so
for index, option in pairs(CHUDServerOptions) do
	if option.currentValue == nil then
		CHUDSetServerOption(index, CHUDServerOptions[index].defaultValue)
	end
	
	local _, pos = string.find(index, "allow_")
	if pos and CHUDServerOptions[index].currentValue == false then
		local option = string.sub(index, pos+1)
		table.insert(CHUDClientOptions, option)
		
		-- Add server tags for disabled features
		AddCHUDTagBitmask(CHUDTagBitmask[option])
	end
end

CreateServerAdminCommand("Console_sv_plus", CHUDServerSetting, "Sets NS2+ server settings", false)