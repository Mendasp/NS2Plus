local originalScoreboardUpdateTeam
originalScoreboardUpdateTeam = Class_ReplaceMethod( "GUIScoreboard", "UpdateTeam",
function(self, updateTeam)
	originalScoreboardUpdateTeam(self, updateTeam)
	
	local teamNumber = updateTeam["TeamNumber"]
    local teamScores = updateTeam["GetScores"]()
	
	// Add number of players connecting
	if teamNumber == kTeamReadyRoom then
		local numPlayersReported, numPlayersTotal = PlayerUI_GetServerNumPlayers()
		if numPlayersReported < numPlayersTotal then
			local teamNameGUIItem = updateTeam["GUIs"]["TeamName"]			
			local teamNameText = updateTeam["TeamName"]
			local numPlayers = table.count(updateTeam["GetScores"]())
			
			local playersOnTeamText = numPlayers > 0 and string.format( "%d %s, ", numPlayers, Locale.ResolveString( numPlayers == 1 and "SB_PLAYER" or "SB_PLAYERS" ) ) or ""				
			local teamHeaderText = string.format("%s (%s%d Connecting)", teamNameText, playersOnTeamText,	numPlayersTotal - numPlayersReported )		
			teamNameGUIItem:SetText( teamHeaderText )
			
			updateTeam["GUIs"]["Background"]:SetIsVisible( true )
		end
	end
	
	
	local currentPlayerIndex = 1
	local playerList = updateTeam["PlayerList"]
	for index, player in pairs(playerList) do
		local playerRecord = teamScores[currentPlayerIndex]
		
		// Swap KDA/KAD
		if CHUDGetOption("kda") and player["Assists"]:GetPosition().x < player["Deaths"]:GetPosition().x then
			local temp = player["Assists"]:GetPosition()
			player["Assists"]:SetPosition(player["Deaths"]:GetPosition())
			player["Deaths"]:SetPosition(temp)
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