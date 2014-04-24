local SetMouseVisible
local function New_GUIScoreboard_Update( self, deltaTime )

    PROFILE("GUIScoreboard:Update")
    
    if not self.visible then
        SetMouseVisible(self, false)
    end
    
    if not self.mouseVisible then
    
        // Click for mouse only visible when not a commander and when the scoreboard is visible.
        local clickForMouseBackgroundVisible = (not PlayerUI_IsACommander()) and self.visible
        self.clickForMouseBackground:SetIsVisible(clickForMouseBackgroundVisible)
        local backgroundColor = PlayerUI_GetTeamColor()
        backgroundColor.a = 0.8
        self.clickForMouseBackground:SetColor(backgroundColor)
        
    end
    
    //First, update teams.
    for index, team in ipairs(self.teams) do
    
        // Don't draw if no players on team
        local numPlayers = table.count(team["GetScores"]())    
        team["GUIs"]["Background"]:SetIsVisible(self.visible and (numPlayers > 0))
        
        if self.visible then
            self:UpdateTeam(team)
        end
        
    end
    
    // update game time
    self.gameTimeBackground:SetIsVisible(self.visible)
    self.gameTime:SetIsVisible(self.visible)
    
    if self.visible then
    
        local gameTime = PlayerUI_GetGameLengthTime()
        local minutes = math.floor(gameTime / 60)
        local seconds = gameTime - minutes * 60
        local serverName = Client.GetServerIsHidden() and "Hidden" or Client.GetConnectedServerName()
        local gameTimeText = string.format(serverName .. " | " .. Shared.GetMapName() .. " - %d:%02d", minutes, seconds)
        
        self.gameTime:SetText(gameTimeText)
        
        // Next, position teams.
        
        local numTeams = table.count(self.teams)
        if numTeams > 0 then
        
            // Update Spectator Position
            for index, team in ipairs(self.teams) do
            
                if team.TeamNumber == kTeamReadyRoom then
                
                    local newPosition = team["GUIs"]["Background"]:GetPosition()
                    newPosition.y = - team["GUIs"]["Background"]:GetSize().y - 35
                    team["GUIs"]["Background"]:SetPosition(newPosition)
                    
                end
                
            end
            
        end
        
        local playerCount = math.max(#ScoreboardUI_GetBlueScores(), #ScoreboardUI_GetRedScores())
        local frameHeight = GUIScoreboard.kPlayerItemHeight * playerCount
        
        local yPos = math.max(-Client.GetScreenHeight()/2, -frameHeight/2 - 160)
        
        self.centeredFrame:SetPosition(Vector(0, yPos, 0))
        
    end
    
    // Detect connection problems and display the indicator.
    self.droppedMoves = self.droppedMoves or 0
    local numberOfDroppedMovesTotal = Shared.GetNumDroppedMoves()
    if numberOfDroppedMovesTotal ~= self.droppedMoves then
    
        self.connectionProblemsDetector:RemoveTokens(numberOfDroppedMovesTotal - self.droppedMoves)
        self.droppedMoves = numberOfDroppedMovesTotal
        
    end
    
    local tooManyDroppedMoves = self.connectionProblemsDetector:GetNumberOfTokens() < 6
    local connectionProblems = Client.GetConnectionProblems()
    local connectionProblemsDetected = tooManyDroppedMoves or connectionProblems
    
    self.connectionProblemsIcon:SetIsVisible(connectionProblemsDetected)
    if connectionProblemsDetected then
    
        local alpha = 0.5 + (((math.cos(Shared.GetTime() * 10) + 1) / 2) * 0.5)
        local useColor = Color(0, 0, 0, alpha)
        if tooManyDroppedMoves and connectionProblems then
            useColor.g = 1
        elseif tooManyDroppedMoves then
        
            useColor.r = 1
            useColor.g = 1
            
        elseif connectionProblems then
            useColor.r = 1
        end
        
        self.connectionProblemsIcon:SetColor(useColor)
        
    end
    
end

SetUpValues( New_GUIScoreboard_Update, GetUpValues( GUIScoreboard.Update ) );
GUIScoreboard.Update = New_GUIScoreboard_Update;
