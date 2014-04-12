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
	
	serverEntry.CHUD = Client.GetServerHasTag(serverIndex, "CHUD")
	serverEntry.CHUD_MCR = Client.GetServerHasTag(serverIndex, "CHUD_MCR")
	
	if serverEntry.CHUD and serverEntry.mode == "ns2" then
		serverEntry.mode = "ns2+"
	end
    
    return serverEntry
    
end

originalSetServerData = Class_ReplaceMethod( "ServerEntry", "SetServerData",
	function(self, serverData)
		originalSetServerData(self, serverData)
		
		if serverData.CHUD then
			self.modName:SetColor(kYellow)
		end
		// Mapchange required
		if serverData.CHUD_MCR then
			self.playerCount:SetColor(kRed)
		end
	end
)
