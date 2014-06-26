// This is basically the normal server browser file, except with the very minimum required to run in the main menu

local function isInteger(x)
	return math.floor(x)==x
end

local CHUDTagBitmask = {
	mcr = 0x1,
	ambient = 0x2,
	mapparticles = 0x4,
	nsllights = 0x8,
	deathstats = 0x0,
}

local CHUDOptions =
{
			ambient = {
				name    = "CHUD_Ambient",
				label   = "Ambient sounds",
				tooltip = "Enables or disables map ambient sounds.",
				type    = "select",
				values  = { "Off", "On" },
				callback = CHUDSaveMenuSettings,
				defaultValue = true,
				category = "comp",
				valueType = "bool",
				applyFunction = SetCHUDAmbients,
				sort = "B1",
			}, 
			mapparticles = {
				name    = "CHUD_MapParticles",
				label   = "Map particles",
				tooltip = "Enables or disables particles, holograms and other map specific effects.",
				type    = "select",
				values  = { "Off", "On" },
				callback = CHUDSaveMenuSettings,
				defaultValue = true,
				category = "comp",
				valueType = "bool",
				applyFunction = SetCHUDCinematics,
				sort = "B2",
			}, 
			nsllights = {
				name    = "lowLights",
				label   = "NSL Low lights",
				tooltip = "Replaces the low quality option lights with the lights from the NSL maps.",
				type    = "select",
				values  = { "Off", "On" },
				callback = CHUDSaveMenuSettings,
				defaultValue = false,
				category = "comp",
				valueType = "bool",
				applyFunction = function()
					lowLightsSwitched = false
					CHUDLoadLights()
				end,
				sort = "B3",
			}, 
			deathstats = { 
                name    = "CHUD_DeathStats",
                label   = "Death stats UI",
				tooltip = "Enables or disables the stats you get after you die. Also visible on voiceover menu (default: X).",
				type    = "select",
				values  = { "Fully disabled", "Only voiceover menu", "Enabled" },
				callback = CHUDSaveMenuSettings,
				defaultValue = 2,
				disabledValue = 0,
				category = "comp",
				valueType = "int",
				sort = "D1",
            },
}

local function CheckCHUDTagOption(bitmask, option)
	return(bit.band(bitmask, option) > 0)
end

local function CHUDGetOption(key)
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

local function GetCHUDSettings()
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
				CHUDOptions[name].currentValue = value
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

originalBuildServerEntry = BuildServerEntry
function BuildServerEntry(serverIndex)

    local mods = Client.GetServerKeyValue(serverIndex, "mods")
    
    local serverEntry = { }
    serverEntry.name = Client.GetServerName(serverIndex)
    serverEntry.mode = FormatGameMode(Client.GetServerGameMode(serverIndex))
    serverEntry.map = GetTrimmedMapName(Client.GetServerMapName(serverIndex))
    serverEntry.numPlayers = Client.GetServerNumPlayers(serverIndex)
    serverEntry.maxPlayers = Client.GetServerMaxPlayers(serverIndex)
	serverEntry.numRS = GetNumServerReservedSlots(serverIndex)
    serverEntry.ping = Client.GetServerPing(serverIndex)
    serverEntry.address = Client.GetServerAddress(serverIndex)
    serverEntry.requiresPassword = Client.GetServerRequiresPassword(serverIndex)
    serverEntry.playerSkill = GetServerPlayerSkill(serverIndex)
    serverEntry.rookieFriendly = Client.GetServerHasTag(serverIndex, "rookie")
	serverEntry.gatherServer = Client.GetServerHasTag(serverIndex, "gather_server")
    serverEntry.friendsOnServer = false
    serverEntry.lanServer = false
    serverEntry.tickrate = Client.GetServerTickRate(serverIndex)
    serverEntry.serverId = serverIndex
    serverEntry.modded = Client.GetServerIsModded(serverIndex)
    serverEntry.favorite = GetServerIsFavorite(serverEntry.address)
    serverEntry.history = GetServerIsHistory(serverEntry.address)
    
    serverEntry.name = FormatServerName(serverEntry.name, serverEntry.rookieFriendly)
	
	local serverTags = { }
	Client.GetServerTags(serverIndex, serverTags)
	
	for t = 1, #serverTags do
		local _, pos = string.find(serverTags[t], "CHUD_0x")
		if pos then
			serverEntry.CHUDBitmask = tonumber(string.sub(serverTags[t], pos+1))
			break
		end
	end
	
	if serverEntry.CHUDBitmask ~= nil and serverEntry.mode == "ns2" then
		serverEntry.mode = "ns2+"
	end
    
    return serverEntry
    
end

originalSetServerData = Class_ReplaceMethod( "ServerEntry", "SetServerData",
	function(self, serverData)
		originalSetServerData(self, serverData)
		
		if serverData.CHUDBitmask ~= nil then
		
			self.modName:SetColor(kYellow)
			
			for index, mask in pairs(CHUDTagBitmask) do
				if CheckCHUDTagOption(serverData.CHUDBitmask, mask) then
					if index == "mcr" then
						self.playerCount:SetColor(kRed)
					else
						local val = ConditionalValue(CHUDOptions[index].disabledValue == nil, CHUDOptions[index].defaultValue, CHUDOptions[index].disabledValue)
						
						if CHUDOptions[index].currentValue ~= val then
							self.modName:SetColor(kRed)
						end
					end
				end
			end
			
		end
		
	end
)
