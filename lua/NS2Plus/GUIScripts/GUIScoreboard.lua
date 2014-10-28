local originalScoreboardUpdateTeam
originalScoreboardUpdateTeam = Class_ReplaceMethod( "GUIScoreboard", "UpdateTeam",
function(self, updateTeam)
	originalScoreboardUpdateTeam(self, updateTeam)
	
	local teamNumber = updateTeam["TeamNumber"]
    local teamScores = updateTeam["GetScores"]()
	
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

local originalLocaleResolveString = Locale.ResolveString
function Locale.ResolveString(string)
	if string == "SB_ASSISTS" and CHUDGetOption("kda") then
		return originalLocaleResolveString("SB_DEATHS")
	elseif string == "SB_DEATHS" and CHUDGetOption("kda") then
		return originalLocaleResolveString("SB_ASSISTS")
	else
		return originalLocaleResolveString(string)
	end
end