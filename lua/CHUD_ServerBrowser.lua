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
	
	if Client.GetServerHasTag(serverIndex, "CHUD") then
		serverEntry.mode = "CHUD"
	end
	
	serverEntry.CHUD_MCR = Client.GetServerHasTag(serverIndex, "CHUD_MCR")
    
    return serverEntry
    
end

originalSetServerData = Class_ReplaceMethod( "ServerEntry", "SetServerData",
	function(self, serverData)
		originalSetServerData(self, serverData)
		if serverData.mode == "CHUD" then
			self.modName:SetColor(kYellow)
		end
		// Mapchange required
		if serverData.CHUD_MCR then
			self.playerCount:SetColor(kRed)
		end
	end
)
