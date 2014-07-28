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
    serverEntry.tickrate = GetServerTickRate(serverIndex)
    serverEntry.serverId = serverIndex
    serverEntry.modded = Client.GetServerIsModded(serverIndex)
    serverEntry.favorite = GetServerIsFavorite(serverEntry.address)
    serverEntry.history = GetServerIsHistory(serverEntry.address)
    serverEntry.customNetworkSettings = Client.GetServerHasTag(serverIndex, "custom_network_settings")
    
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
