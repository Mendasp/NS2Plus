local oldGUIVoiceChatUpdate = GUIVoiceChat.Update
local ClearAllBars, GetFreeBar, kBackgroundTexture, kBackgroundSize, kBackgroundYSpace, kBackgroundOffset, loggedIn
function GUIVoiceChat:Update(deltaTime)

    PROFILE("GUIVoiceChat:Update")

    local time = Shared.GetTime()
    
    -- Delayed Push-To-Talk Release
    if self.recordEndTime and self.recordEndTime < time then
        Client.VoiceRecordStop()
        self.recordEndTime = nil
    end
        
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
            local isSpectator = false
            
            chatBar.Background:SetIsVisible(true)
            
            //Show voice chat over death screen
            chatBar.Background:SetLayer(kGUILayerDeathScreen+1)
            
            local textureSet, fontColor
            if clientTeam == kTeam1Index then
                textureSet = "marine"
                fontColor = GUIVoiceChat.kMarineFontColor
            elseif clientTeam == kTeam2Index then
                textureSet = "alien"
                fontColor = GUIVoiceChat.kAlienFontColor
            else
                textureSet = "marine"
                fontColor = GUIVoiceChat.kSpectatorFontColor
                isSpectator = true
            end

            chatBar.Background:SetTexture(string.format(kBackgroundTexture, textureSet))
            // Apply a tint to the marine background for spectator so it looks a bit more different
            if isSpectator then
                chatBar.Background:SetColor(Color(1, 200/255, 150/255, 1))
            else
                chatBar.Background:SetColor(Color(1, 1, 1, 1))
            end
            
            chatBar.Name:SetText(playerName)
            chatBar.Name:SetColor( ConditionalValue(allPlayers[i].IsCommander, GUIVoiceChat.kCommanderFontColor, ConditionalValue(allPlayers[i].IsRookie, kNewPlayerColorFloat, fontColor) ) )
            chatBar.Icon:SetColor( ConditionalValue(allPlayers[i].IsCommander, GUIVoiceChat.kCommanderFontColor, fontColor ) )
            
            local currentBarPosition = Vector(0, (kBackgroundSize.y + kBackgroundYSpace) * currentBar, 0)
            chatBar.Background:SetPosition(kBackgroundOffset + currentBarPosition)
            
            currentBar = currentBar + 1
            
        end
    end
    
end
CopyUpValues( GUIVoiceChat.Update, oldGUIVoiceChatUpdate )

function GUIVoiceChat:SendKeyEvent(key, down, amount)

    local player = Client.GetLocalPlayer()
    
    if down then
        if not ChatUI_EnteringChatMessage() then
            if not player:isa("Commander") then
                if GetIsBinding(key, "VoiceChat") then
                    self.recordBind = "VoiceChat"
                    self.recordEndTime = nil
					Client.VoiceRecordStart()
                end
            else
                if GetIsBinding(key, "VoiceChatCom") then
                    self.recordBind = "VoiceChatCom"
					self.recordEndTime = nil
                    Client.VoiceRecordStart()
                end
            end
        end
    else
        if self.recordBind and GetIsBinding( key, self.recordBind ) then
            self.recordBind = nil
            self.recordEndTime = Shared.GetTime() + CHUDGetOption("voiceenddelay")
        end
    end
    
end