local ClearAllBars, GetFreeBar, kBackgroundTexture, kBackgroundSize, kBackgroundYSpace, kBackgroundOffset, loggedIn
function New_GUIVoiceChat_Update( self, deltaTime )

    PROFILE("GUIVoiceChat:Update")

    ClearAllBars(self)
    
    local allPlayers = ScoreboardUI_GetAllScores()
    // How many items per player.
    local numPlayers = table.count(allPlayers)
    local currentBar = 0
    
    for i = 1, numPlayers do
    
        local playerName = allPlayers[i].Name
        local clientIndex = allPlayers[i].ClientIndex
        local clientTeam = allPlayers[i].EntityTeamNumber
        
        if clientIndex and ChatUI_GetIsClientSpeaking(clientIndex) then
        
            local chatBar = GetFreeBar(self)
            
            chatBar.Background:SetIsVisible(true)
			chatBar.Background:SetLayer(15)
            
			local textureSet, fontColor
			if clientTeam == kTeam1Index then
				textureSet = "marine"
				fontColor = GUIVoiceChat.kMarineFontColor
            elseif clientTeam == kTeam2Index then
                textureSet = "alien"
                fontColor = GUIVoiceChat.kAlienFontColor
			else
				textureSet = "spectator"
				fontColor = Color(1, 1, 1, 1)
            end    

            chatBar.Background:SetTexture(string.format(kBackgroundTexture, textureSet))
            
            chatBar.Name:SetText(playerName)
            chatBar.Name:SetColor( ConditionalValue(allPlayers[i].IsCommander, GUIVoiceChat.kCommanderFontColor, ConditionalValue(allPlayers[i].IsRookie, kNewPlayerColorFloat, fontColor) ) )
            chatBar.Icon:SetColor( ConditionalValue(allPlayers[i].IsCommander, GUIVoiceChat.kCommanderFontColor, fontColor ) )
            
            local currentBarPosition = Vector(0, (kBackgroundSize.y + kBackgroundYSpace) * currentBar, 0)
            chatBar.Background:SetPosition(kBackgroundOffset + currentBarPosition)
            
            currentBar = currentBar + 1
            
        end

    end
	
	local player = Client.GetLocalPlayer()
	if loggedIn ~= player:isa("Commander") and ChatUI_GetIsClientSpeaking(1) then
		loggedIn = player:isa("Commander")
		Client.VoiceRecordStop()
	end
	
end

SetUpValues( New_GUIVoiceChat_Update, GetUpValues( GUIVoiceChat.Update ) )
GUIVoiceChat.Update = New_GUIVoiceChat_Update