// Keep last game time instead of immediatly resetting
local originalScoreboardUpdate
originalScoreboardUpdate = Class_ReplaceMethod( "GUIScoreboard", "Update",
function(self, deltaTime)
	originalScoreboardUpdate(self, deltaTime)
	
    if self.visible then
        local gameTime = PlayerUI_GetGameLengthTime()
        local minutes = math.floor(gameTime / 60)
        local seconds = gameTime - minutes * 60
        local serverName = Client.GetServerIsHidden() and "Hidden" or Client.GetConnectedServerName()
        local gameTimeText = serverName .. " | " .. Shared.GetMapName() .. string.format(" - %d:%02d", minutes, seconds)
        
        self.gameTime:SetText(gameTimeText)
	end
end)
	
	
local originalScoreboardUpdateTeam
originalScoreboardUpdateTeam = Class_ReplaceMethod( "GUIScoreboard", "UpdateTeam",
function(self, updateTeam)
	originalScoreboardUpdateTeam(self, updateTeam)
	
	// Add number of players connecting
	local teamScores
	local teamNumber = updateTeam["TeamNumber"]
	if teamNumber == kTeamReadyRoom then
				
		local numPlayersReported = #Scoreboard_GetPlayerList()
		local numPlayersTotal = PlayerUI_GetServerNumPlayers()
		if numPlayersReported < numPlayersTotal then
			local teamNameGUIItem = updateTeam["GUIs"]["TeamName"]			
			local teamNameText = updateTeam["TeamName"]
			local numPlayers = table.count(updateTeam["GetScores"]())
			
			local playersOnTeamText = numPlayers > 0 and string.format( "%d %s, ", numPlayers, Locale.ResolveString( numPlayers == 1 and "SB_PLAYER" or "SB_PLAYERS" ) ) or ""				
			local teamHeaderText = string.format("%s (%s%d Connecting)", teamNameText, playersOnTeamText,	numPlayersTotal - numPlayersReported )		
			teamNameGUIItem:SetText( teamHeaderText )
			
			updateTeam["GUIs"]["Background"]:SetIsVisible( true )
		end		
		
		teamScores = updateTeam["GetScores"]()
	end
	
			
	// Swap KDA/KAD
	local currentPlayerIndex = 1
	local playerList = updateTeam["PlayerList"]
	for index, player in pairs(playerList) do
		if CHUDGetOption("kda") and player["Assists"]:GetPosition().x < player["Deaths"]:GetPosition().x then
			local temp = player["Assists"]:GetPosition()
			player["Assists"]:SetPosition(player["Deaths"]:GetPosition())
			player["Deaths"]:SetPosition(temp)
		end
		
		// Fix spectator status not showing up when on a team
		if teamNumber == kTeamReadyRoom then
			local playerRecord = teamScores[currentPlayerIndex]
			player["Status"]:SetText( playerRecord.Status )
		end
		
		currentPlayerIndex = currentPlayerIndex + 1
	end
end)


// I removed all of remi.D's semicolons here
local oldCreateTeamBackground = GetUpValue( GUIScoreboard.Initialize, "CreateTeamBackground" )
local function NewCreateTeamBackground( self, teamNumber )
	local textItems = { }
	local oldCreateTextItem = GUIManager.CreateTextItem
	GUIManager.CreateTextItem = 
	function( self )
		local obj = oldCreateTextItem( self )
			table.insert(textItems, obj)
		return obj
	end
	
	local ret = oldCreateTeamBackground( self, teamNumber )
	
	GUIManager.CreateTextItem = oldCreateTextItem
	
	for _, item in pairs(textItems) do
		if item:GetText() == "A" and CHUDGetOption("kda") then
			item:SetText("D")
		elseif item:GetText() == "D" and CHUDGetOption("kda") then
			item:SetText("A")
		end
	end
	
	return ret
end
ReplaceUpValue( GUIScoreboard.Initialize, "CreateTeamBackground", NewCreateTeamBackground )