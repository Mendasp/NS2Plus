
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIScoreboard.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages the player scoreboard (scores, pings, etc).
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIScoreboard' (GUIScript)

GUIScoreboard.kGameTimeBackgroundSize = Vector(640, GUIScale(32), 0)
GUIScoreboard.kGameTimeTextSize = GUIScale(22)

GUIScoreboard.kClickForMouseBackgroundSize = Vector(GUIScale(200), GUIScale(32), 0)
GUIScoreboard.kClickForMouseTextSize = GUIScale(22)
GUIScoreboard.kClickForMouseText = Locale.ResolveString("SB_CLICK_FOR_MOUSE")

GUIScoreboard.kSlidebarSize = Vector(7.5, 25, 0)
GUIScoreboard.kBgColor = Color(0, 0, 0, 0.5)
GUIScoreboard.kBgMaxYSpace = Client.GetScreenHeight() - ((GUIScoreboard.kClickForMouseBackgroundSize.y + 5) + (GUIScoreboard.kGameTimeBackgroundSize.y + 6) + 20)

local kIconSize = GUIScale(Vector(40, 40, 0))
local kIconOffset = GUIScale(Vector(-15, -10, 0))

-- Shared constants.
GUIScoreboard.kTeamInfoFontName      = Fonts.kArial_15 
GUIScoreboard.kPlayerStatsFontName   = Fonts.kArial_15 
GUIScoreboard.kTeamNameFontName      = Fonts.kArial_17
GUIScoreboard.kGameTimeFontName      = Fonts.kArial_17
GUIScoreboard.kClickForMouseFontName = Fonts.kArial_17

GUIScoreboard.kLowPingThreshold = 100
GUIScoreboard.kLowPingColor = Color(0, 1, 0, 1)
GUIScoreboard.kMedPingThreshold = 249
GUIScoreboard.kMedPingColor = Color(1, 1, 0, 1)
GUIScoreboard.kHighPingThreshold = 499
GUIScoreboard.kHighPingColor = Color(1, 0.5, 0, 1)
GUIScoreboard.kInsanePingColor = Color(1, 0, 0, 1)
GUIScoreboard.kVoiceMuteColor = Color(1, 0, 0, 0.5)
GUIScoreboard.kVoiceDefaultColor = Color(1, 1, 1, 0.5)

-- Team constants.
GUIScoreboard.kTeamBackgroundYOffset = 50
GUIScoreboard.kTeamNameFontSize = 26
GUIScoreboard.kTeamInfoFontSize = 16
GUIScoreboard.kTeamItemWidth = 600
GUIScoreboard.kTeamItemHeight = GUIScoreboard.kTeamNameFontSize + GUIScoreboard.kTeamInfoFontSize + 8
GUIScoreboard.kTeamSpacing = 32
GUIScoreboard.kTeamScoreColumnStartX = 200
GUIScoreboard.kTeamColumnSpacingX = 30

-- Player constants.
GUIScoreboard.kPlayerStatsFontSize = 16
GUIScoreboard.kPlayerItemWidthBuffer = 10
GUIScoreboard.kPlayerItemWidth = 275
GUIScoreboard.kPlayerItemHeight = 32
GUIScoreboard.kPlayerSpacing = 4

local kPlayerItemLeftMargin = 10
local kPlayerNumberWidth = 10
local kPlayerVoiceChatIconSize = 20
local kPlayerBadgeIconSize = 20
local kPlayerBadgeRightPadding = 4

local kSkillBarSize = Vector(48, 15, 0)
local kSkillBarPadding = 4

-- Color constants.
GUIScoreboard.kBlueColor = ColorIntToColor(kMarineTeamColor)
GUIScoreboard.kBlueHighlightColor = Color(0.30, 0.69, 1, 1)
GUIScoreboard.kRedColor = kRedColor--ColorIntToColor(kAlienTeamColor)
GUIScoreboard.kRedHighlightColor = Color(1, 0.79, 0.23, 1)
GUIScoreboard.kSpectatorColor = ColorIntToColor(kNeutralTeamColor)
GUIScoreboard.kSpectatorHighlightColor = Color(0.8, 0.8, 0.8, 1)

GUIScoreboard.kCommanderFontColor = Color(1, 1, 0, 1)
GUIScoreboard.kWhiteColor = Color(1,1,1,1)
local kDeadColor = Color(1,0,0,1)

local kConnectionProblemsIcon = PrecacheAsset("ui/ethernet-connect.dds")

function GUIScoreboard:OnResolutionChanged(oldX, oldY, newX, newY)

    GUIScoreboard.kGameTimeBackgroundSize = Vector(640, GUIScale(32), 0)
    GUIScoreboard.kGameTimeTextSize = GUIScale(22)
    
    GUIScoreboard.kClickForMouseBackgroundSize = Vector(GUIScale(200), GUIScale(32), 0)
    GUIScoreboard.kClickForMouseTextSize = GUIScale(22)
    
    GUIScoreboard.kBgMaxYSpace = Client.GetScreenHeight() - ((GUIScoreboard.kClickForMouseBackgroundSize.y + 5) + (GUIScoreboard.kGameTimeBackgroundSize.y + 6) + 20)
    
    self:Uninitialize()
    self:Initialize()
    
end

-- Make this fixed size to adjust for all resolutions from 640x480 up to 1920x1080
local function GetTeamItemWidth()
    return 608 -- 640 * 0.95
end

local function CreateTeamBackground(self, teamNumber)

    local color = nil
    local teamItem = GUIManager:CreateGraphicItem()
    teamItem:SetStencilFunc(GUIItem.NotEqual)
    
    -- Background
    teamItem:SetSize(Vector(GetTeamItemWidth(), GUIScoreboard.kTeamItemHeight, 0))
    if teamNumber == kTeamReadyRoom then
    
        color = GUIScoreboard.kSpectatorColor
        teamItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        
    elseif teamNumber == kTeam1Index then
    
        color = GUIScoreboard.kBlueColor
        teamItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        
    elseif teamNumber == kTeam2Index then
    
        color = GUIScoreboard.kRedColor
        teamItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        
    end
    
    teamItem:SetColor(Color(0, 0, 0, 0.75))
    teamItem:SetIsVisible(false)
    teamItem:SetLayer(kGUILayerScoreboard)
    
    -- Team name text item.
    local teamNameItem = GUIManager:CreateTextItem()
    teamNameItem:SetFontName(GUIScoreboard.kTeamNameFontName)
    teamNameItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    teamNameItem:SetTextAlignmentX(GUIItem.Align_Min)
    teamNameItem:SetTextAlignmentY(GUIItem.Align_Min)
    teamNameItem:SetPosition(Vector(10, 5, 0))
    teamNameItem:SetColor(color)
    teamNameItem:SetStencilFunc(GUIItem.NotEqual)
    teamItem:AddChild(teamNameItem)
    
    -- Add team info (team resources and number of players).
    local teamInfoItem = GUIManager:CreateTextItem()
    teamInfoItem:SetFontName(GUIScoreboard.kTeamInfoFontName)
    teamInfoItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    teamInfoItem:SetTextAlignmentX(GUIItem.Align_Min)
    teamInfoItem:SetTextAlignmentY(GUIItem.Align_Min)
    teamInfoItem:SetPosition(Vector(12, GUIScoreboard.kTeamNameFontSize + 7, 0))
    teamInfoItem:SetColor(color)
    teamInfoItem:SetStencilFunc(GUIItem.NotEqual)
    teamItem:AddChild(teamInfoItem)
    
    local currentColumnX = GUIScoreboard.kPlayerItemWidth
    local playerDataRowY = 10
    
    -- Status text item.
    local statusItem = GUIManager:CreateTextItem()
    statusItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    statusItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    statusItem:SetTextAlignmentX(GUIItem.Align_Min)
    statusItem:SetTextAlignmentY(GUIItem.Align_Min)
    statusItem:SetPosition(Vector(currentColumnX + 60, playerDataRowY, 0))
    statusItem:SetColor(color)
    statusItem:SetText("")
    statusItem:SetStencilFunc(GUIItem.NotEqual)
    teamItem:AddChild(statusItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX * 2 + 33
    
    -- Score text item.
    local scoreItem = GUIManager:CreateTextItem()
    scoreItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    scoreItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    scoreItem:SetTextAlignmentX(GUIItem.Align_Center)
    scoreItem:SetTextAlignmentY(GUIItem.Align_Min)
    scoreItem:SetPosition(Vector(currentColumnX + 42.5, playerDataRowY, 0))
    scoreItem:SetColor(color)
    scoreItem:SetText(Locale.ResolveString("SB_SCORE"))
    scoreItem:SetStencilFunc(GUIItem.NotEqual)
    teamItem:AddChild(scoreItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX + 40
    
    -- Kill text item.
    local killsItem = GUIManager:CreateTextItem()
    killsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    killsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    killsItem:SetTextAlignmentX(GUIItem.Align_Center)
    killsItem:SetTextAlignmentY(GUIItem.Align_Min)
    killsItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
    killsItem:SetColor(color)
    killsItem:SetText(Locale.ResolveString("SB_KILLS"))
    killsItem:SetStencilFunc(GUIItem.NotEqual)
    teamItem:AddChild(killsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    -- Assist text item.
    local assistsItem = GUIManager:CreateTextItem()
    assistsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    assistsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    assistsItem:SetTextAlignmentX(GUIItem.Align_Center)
    assistsItem:SetTextAlignmentY(GUIItem.Align_Min)
    assistsItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
    assistsItem:SetColor(color)
    assistsItem:SetText(Locale.ResolveString("SB_ASSISTS"))
    assistsItem:SetStencilFunc(GUIItem.NotEqual)
    teamItem:AddChild(assistsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    -- Deaths text item.
    local deathsItem = GUIManager:CreateTextItem()
    deathsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    deathsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    deathsItem:SetTextAlignmentX(GUIItem.Align_Center)
    deathsItem:SetTextAlignmentY(GUIItem.Align_Min)
    deathsItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
    deathsItem:SetColor(color)
    deathsItem:SetText(Locale.ResolveString("SB_DEATHS"))
    deathsItem:SetStencilFunc(GUIItem.NotEqual)
    teamItem:AddChild(deathsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    -- Resources text item.
    local resItem = GUIManager:CreateGraphicItem()
    resItem:SetPosition(Vector(currentColumnX , playerDataRowY, 0) + kIconOffset)
    resItem:SetTexture("ui/buildmenu.dds")
    resItem:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.CollectResources)))
    resItem:SetSize(kIconSize)
    resItem:SetStencilFunc(GUIItem.NotEqual)
    teamItem:AddChild(resItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    -- Ping text item.
    local pingItem = GUIManager:CreateTextItem()
    pingItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    pingItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    pingItem:SetTextAlignmentX(GUIItem.Align_Min)
    pingItem:SetTextAlignmentY(GUIItem.Align_Min)
    pingItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
    pingItem:SetColor(color)
    pingItem:SetText(Locale.ResolveString("SB_PING"))
    pingItem:SetStencilFunc(GUIItem.NotEqual)
    teamItem:AddChild(pingItem)
    
    return { Background = teamItem, TeamName = teamNameItem, TeamInfo = teamInfoItem }
    
end

function GUIScoreboard:Initialize()

    self.visible = false
    
    self.teams = { }
    self.reusePlayerItems = { }
    self.slidePercentage = -1
    self.centerOnPlayer = true -- For modding
    
    self.scoreboardBackground = GUIManager:CreateGraphicItem()
    self.scoreboardBackground:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.scoreboardBackground:SetLayer(kGUILayerScoreboard)
    self.scoreboardBackground:SetColor(GUIScoreboard.kBgColor)
    self.scoreboardBackground:SetIsVisible(false)
    
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetLayer(kGUILayerScoreboard)
    self.background:SetColor(GUIScoreboard.kBgColor)
    self.background:SetIsVisible(true)
    
    self.backgroundStencil = GUIManager:CreateGraphicItem()
    self.backgroundStencil:SetIsStencil(true)
    self.backgroundStencil:SetClearsStencilBuffer(true)
    self.scoreboardBackground:AddChild(self.backgroundStencil)
    
    self.slidebar = GUIManager:CreateGraphicItem()
    self.slidebar:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.slidebar:SetSize(GUIScoreboard.kSlidebarSize)
    self.slidebar:SetLayer(kGUILayerScoreboard)
    self.slidebar:SetColor(Color(1, 1, 1, 1))
    self.slidebar:SetIsVisible(true)
    
    self.slidebarBg = GUIManager:CreateGraphicItem()
    self.slidebarBg:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.slidebarBg:SetSize(Vector(GUIScoreboard.kSlidebarSize.x, GUIScoreboard.kBgMaxYSpace-20, 0))
    self.slidebarBg:SetPosition(Vector(-12.5, 10, 0))
    self.slidebarBg:SetLayer(kGUILayerScoreboard)
    self.slidebarBg:SetColor(Color(0.25, 0.25, 0.25, 1))
    self.slidebarBg:SetIsVisible(false)
    self.slidebarBg:AddChild(self.slidebar)
    self.scoreboardBackground:AddChild(self.slidebarBg)
    
    self.gameTimeBackground = GUIManager:CreateGraphicItem()
    self.gameTimeBackground:SetSize(GUIScoreboard.kGameTimeBackgroundSize)
    self.gameTimeBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.gameTimeBackground:SetPosition( Vector(- GUIScoreboard.kGameTimeBackgroundSize.x / 2, 10, 0) )
    self.gameTimeBackground:SetIsVisible(false)
    self.gameTimeBackground:SetColor(Color(0,0,0,0.5))
    self.gameTimeBackground:SetLayer(kGUILayerScoreboard)
    
    self.gameTime = GUIManager:CreateTextItem()
    self.gameTime:SetFontName(GUIScoreboard.kGameTimeFontName)
    self.gameTime:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.gameTime:SetTextAlignmentX(GUIItem.Align_Center)
    self.gameTime:SetTextAlignmentY(GUIItem.Align_Center)
    self.gameTime:SetColor(Color(1, 1, 1, 1))
    self.gameTime:SetText("")
    self.gameTimeBackground:AddChild(self.gameTime)
    
    -- Teams table format: Team GUIItems, color, player GUIItem list, get scores function.
    -- Spectator team.
    table.insert(self.teams, { GUIs = CreateTeamBackground(self, kTeamReadyRoom), TeamName = ScoreboardUI_GetSpectatorTeamName(),
                               Color = GUIScoreboard.kSpectatorColor, PlayerList = { }, HighlightColor = GUIScoreboard.kSpectatorHighlightColor,
                               GetScores = ScoreboardUI_GetSpectatorScores, TeamNumber = kTeamReadyRoom })
                               
    -- Blue team.
    table.insert(self.teams, { GUIs = CreateTeamBackground(self, kTeam1Index), TeamName = ScoreboardUI_GetBlueTeamName(),
                               Color = GUIScoreboard.kBlueColor, PlayerList = { }, HighlightColor = GUIScoreboard.kBlueHighlightColor,
                               GetScores = ScoreboardUI_GetBlueScores, TeamNumber = kTeam1Index})                              
                       
    -- Red team.
    table.insert(self.teams, { GUIs = CreateTeamBackground(self, kTeam2Index), TeamName = ScoreboardUI_GetRedTeamName(),
                               Color = GUIScoreboard.kRedColor, PlayerList = { }, HighlightColor = GUIScoreboard.kRedHighlightColor,
                               GetScores = ScoreboardUI_GetRedScores, TeamNumber = kTeam2Index })

    self.background:AddChild(self.teams[1].GUIs.Background)
    self.background:AddChild(self.teams[2].GUIs.Background)
    self.background:AddChild(self.teams[3].GUIs.Background)
    
    self.playerHighlightItem = GUIManager:CreateGraphicItem()
    self.playerHighlightItem:SetSize(Vector(GetTeamItemWidth() - (GUIScoreboard.kPlayerItemWidthBuffer * 2), GUIScoreboard.kPlayerItemHeight, 0))
    self.playerHighlightItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.playerHighlightItem:SetColor(Color(1, 1, 1, 1))
    self.playerHighlightItem:SetTexture("ui/hud_elements.dds")
    self.playerHighlightItem:SetTextureCoordinates(0, 0.16, 0.558, 0.32)
    self.playerHighlightItem:SetStencilFunc(GUIItem.NotEqual)
    self.playerHighlightItem:SetIsVisible(false)
    
    self.clickForMouseBackground = GUIManager:CreateGraphicItem()
    self.clickForMouseBackground:SetSize(GUIScoreboard.kClickForMouseBackgroundSize)
    self.clickForMouseBackground:SetPosition(Vector(-GUIScoreboard.kClickForMouseBackgroundSize.x / 2, -GUIScoreboard.kClickForMouseBackgroundSize.y - 5, 0))
    self.clickForMouseBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.clickForMouseBackground:SetIsVisible(false)
    
    self.clickForMouseIndicator = GUIManager:CreateTextItem()
    self.clickForMouseIndicator:SetFontName(GUIScoreboard.kClickForMouseFontName)
    self.clickForMouseIndicator:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.clickForMouseIndicator:SetTextAlignmentX(GUIItem.Align_Center)
    self.clickForMouseIndicator:SetTextAlignmentY(GUIItem.Align_Center)
    self.clickForMouseIndicator:SetColor(Color(0, 0, 0, 1))
    self.clickForMouseIndicator:SetText(GUIScoreboard.kClickForMouseText)
    self.clickForMouseBackground:AddChild(self.clickForMouseIndicator)
    
    self.connectionProblemsIcon = GUIManager:CreateGraphicItem()
    self.connectionProblemsIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.connectionProblemsIcon:SetPosition(Vector(32, 0, 0))
    self.connectionProblemsIcon:SetSize(Vector(64, 64, 0))
    self.connectionProblemsIcon:SetLayer(kGUILayerScoreboard)
    self.connectionProblemsIcon:SetTexture(kConnectionProblemsIcon)
    self.connectionProblemsIcon:SetColor(Color(1, 0, 0, 1))
    self.connectionProblemsIcon:SetIsVisible(false)
    self.connectionProblemsDetector = CreateTokenBucket(8, 20)
    
    self.mousePressed = { LMB = { Down = nil }, RMB = { Down = nil } }
    self.badgeNameTooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
    
end

function GUIScoreboard:Uninitialize()

    for index, team in ipairs(self.teams) do
        GUI.DestroyItem(team["GUIs"]["Background"])
    end
    self.teams = { }
    
    for index, playerItem in ipairs(self.reusePlayerItems) do
        GUI.DestroyItem(playerItem["Background"])
    end
    self.reusePlayerItems = { }
    
    GUI.DestroyItem(self.clickForMouseIndicator)
    self.clickForMouseIndicator = nil
    GUI.DestroyItem(self.clickForMouseBackground)
    self.clickForMouseBackground = nil
    
    GUI.DestroyItem(self.gameTime)
    self.gameTime = nil
    GUI.DestroyItem(self.gameTimeBackground)
    self.gameTimeBackground = nil
    
    GUI.DestroyItem(self.connectionProblemsIcon)
    self.connectionProblemsIcon = nil
    
    GUI.DestroyItem(self.scoreboardBackground)
    self.scoreboardBackground = nil
    
    GUI.DestroyItem(self.background)
    self.background = nil
    
end

local function SetMouseVisible(self, setVisible)

    if self.mouseVisible ~= setVisible then
    
        self.mouseVisible = setVisible
        
        MouseTracker_SetIsVisible(self.mouseVisible, "ui/Cursor_MenuDefault.dds", true)
        if self.mouseVisible then
            self.clickForMouseBackground:SetIsVisible(false)
        end
        
    end
    
end


local function HandleSlidebarClicked(self, mouseX, mouseY)

    if self.slidebarBg:GetIsVisible() and self.isDragging then
        local topPos = (GUIScoreboard.kGameTimeBackgroundSize.y + 6) + 19
        local bottomPos = Client.GetScreenHeight() - (GUIScoreboard.kClickForMouseBackgroundSize.y + 5) - 19
        mouseY = Clamp(mouseY, topPos, bottomPos)
        self.slidePercentage = (mouseY - topPos) / (bottomPos - topPos) * 100
    end
    
end

function GUIScoreboard:Update(deltaTime)

    PROFILE("GUIScoreboard:Update")
    
    if not self.visible then
        SetMouseVisible(self, false)
    end

    if not self.mouseVisible then
    
        -- Click for mouse only visible when not a commander and when the scoreboard is visible.
        local clickForMouseBackgroundVisible = (not PlayerUI_IsACommander()) and self.visible
        self.clickForMouseBackground:SetIsVisible(clickForMouseBackgroundVisible)
        local backgroundColor = PlayerUI_GetTeamColor()
        backgroundColor.a = 0.8
        self.clickForMouseBackground:SetColor(backgroundColor)
        
    end
    
    --First, update teams.
    local teamGUISize = {}
    for index, team in ipairs(self.teams) do
    
        -- Don't draw if no players on team
        local numPlayers = table.count(team["GetScores"]())
        if team.TeamNumber == 0 and numPlayers == 0 and PlayerUI_GetNumConnectingPlayers() > 0 then
            numPlayers = PlayerUI_GetNumConnectingPlayers()
        end
        team["GUIs"]["Background"]:SetIsVisible(self.visible and (numPlayers > 0))
        
        if self.visible then
            self:UpdateTeam(team)
            if numPlayers > 0 then
                if teamGUISize[team.TeamNumber] == nil then
                    teamGUISize[team.TeamNumber] = {}
                end
                teamGUISize[team.TeamNumber] = self.teams[index].GUIs.Background:GetSize().y
            end
        end
        
    end
    
    if self.visible then
    
        local gameTime = PlayerUI_GetGameLengthTime()
        local minutes = math.floor( gameTime / 60 )
        local seconds = math.floor( gameTime - minutes * 60 )

        local serverName = Client.GetServerIsHidden() and "Hidden" or Client.GetConnectedServerName()
        local gameTimeText = serverName .. " | " .. Shared.GetMapName() .. string.format( " - %d:%02d", minutes, seconds)
        
        self.gameTime:SetText(gameTimeText)
        
        -- Get sizes for everything so we can reposition correctly
        local contentYSize = 0
        local contentXSize = 640
        local contentYSpacing = 20
        
        if teamGUISize[1] then
            -- If it doesn't fit horizontally or there is only one team put it below
            if GetTeamItemWidth()*2 > Client.GetScreenWidth() or not teamGUISize[2] then
                self.teams[2].GUIs.Background:SetPosition(Vector(-GetTeamItemWidth() / 2, contentYSize, 0))
                contentYSize = contentYSize + teamGUISize[1] + contentYSpacing
            else
                self.teams[2].GUIs.Background:SetPosition(Vector(-GetTeamItemWidth() - 5, contentYSize, 0))
            end
            
        end
        if teamGUISize[2] then
            -- If it doesn't fit horizontally or there is only one team put it below
            if GetTeamItemWidth()*2 > Client.GetScreenWidth() or not teamGUISize[1] then
                self.teams[3].GUIs.Background:SetPosition(Vector(-GetTeamItemWidth() / 2, contentYSize, 0))
                contentYSize = contentYSize + teamGUISize[2] + contentYSpacing
            else
                self.teams[3].GUIs.Background:SetPosition(Vector(5, contentYSize, 0))
            end
        end
        -- If both teams fit horizontally then take only the biggest size
        if teamGUISize[1] and teamGUISize[2] and GetTeamItemWidth()*2 < Client.GetScreenWidth() then
            contentYSize = math.max(teamGUISize[1], teamGUISize[2]) + contentYSpacing*2
            contentXSize = 1260
        end
        if teamGUISize[0] then
            self.teams[1].GUIs.Background:SetPosition(Vector(-GetTeamItemWidth() / 2, contentYSize, 0))
            contentYSize = contentYSize + teamGUISize[0] + contentYSpacing
        end
        
        local slideOffset = -(self.slidePercentage * contentYSize/100)+(self.slidePercentage * self.slidebarBg:GetSize().y/100)
        local displaySpace = Client.GetScreenHeight() - ((GUIScoreboard.kClickForMouseBackgroundSize.y + 5) + (GUIScoreboard.kGameTimeBackgroundSize.y + 6) + contentYSpacing)
        local showSlidebar = contentYSize > displaySpace
        local ySize = math.min(displaySpace, contentYSize)

        if self.slidePercentage == -1 then
            self.slidePercentage = 0
            local teamNumber = Client.GetLocalPlayer():GetTeamNumber()
            if showSlidebar and teamNumber ~= 3 and self.centerOnPlayer then
                local player = self.playerHighlightItem:GetParent()
                local playerItem = player:GetPosition().y
                local teamItem = player:GetParent():GetPosition().y
                local playerPos = playerItem + teamItem + GUIScoreboard.kPlayerItemHeight
                if playerPos > displaySpace then
                    self.slidePercentage = math.max(0, math.min((playerPos / contentYSize * 100), 100))
                end
            end
        end
        
        local sliderPos = (self.slidePercentage * self.slidebarBg:GetSize().y/100)
        if sliderPos < self.slidebar:GetSize().y/2 then
            sliderPos = 0
        end
        if sliderPos > self.slidebarBg:GetSize().y - self.slidebar:GetSize().y then
            sliderPos = self.slidebarBg:GetSize().y - self.slidebar:GetSize().y
        end
        
        self.background:SetPosition(Vector(0, 10+(-ySize/2+slideOffset), 0))
        self.scoreboardBackground:SetSize(Vector(contentXSize, ySize, 0))
        self.scoreboardBackground:SetPosition(Vector(-contentXSize/2, -ySize/2, 0))
        self.backgroundStencil:SetSize(Vector(contentXSize, ySize-20, 0))
        self.backgroundStencil:SetPosition(Vector(0, 10, 0))
        local gameTimeBgYSize = self.gameTimeBackground:GetSize().y
        local gameTimeBgYPos = self.gameTimeBackground:GetPosition().y
        
        self.gameTimeBackground:SetSize(Vector(contentXSize, gameTimeBgYSize, 0))
        self.gameTimeBackground:SetPosition(Vector(-contentXSize/2, gameTimeBgYPos, 0))
        
        self.slidebar:SetPosition(Vector(0, sliderPos, 0))
        self.slidebarBg:SetIsVisible(showSlidebar)
        self.scoreboardBackground:SetColor(ConditionalValue(showSlidebar, GUIScoreboard.kBgColor, Color(0, 0, 0, 0)))
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if self.mousePressed["LMB"]["Down"] and self.isDragging then
            HandleSlidebarClicked(self, mouseX, mouseY)
        end
    else
        self.slidePercentage = -1
    end
    
    -- Show all the elements after sorting them so it doesn't appear to shift when we open
    self.gameTimeBackground:SetIsVisible(self.visible)
    self.gameTime:SetIsVisible(self.visible)
    self.scoreboardBackground:SetIsVisible(self.visible)
    self.badgeNameTooltip:SetIsVisible(self.visible)
    
    -- Detect connection problems and display the indicator.
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

local function SetPlayerItemBadges( item, badgeTextures )

    assert( #badgeTextures <= #item.BadgeItems )

    local offset = 0

    for i = 1, #item.BadgeItems do

        if badgeTextures[i] ~= nil then
            item.BadgeItems[i]:SetTexture( badgeTextures[i] )
            item.BadgeItems[i]:SetIsVisible( true )
        else
            item.BadgeItems[i]:SetIsVisible( false )
        end

    end

    -- now adjust the position of the player name
    local numBadgesShown = math.min( #badgeTextures, #item.BadgeItems )
    
    offset = numBadgesShown*(kPlayerBadgeIconSize + kPlayerBadgeRightPadding)
                
    return offset            

end

local function HandleBadgeClicked(self)
       
    local mouseX, mouseY = Client.GetCursorPosScreen()    
    for t = 1, #self.teams do   
        local playerList = self.teams[t]["PlayerList"]
        for p = 1, #playerList do
            local playerItem = playerList[p]
            for i = 1, #playerItem.BadgeItems do
                local badgeItem = playerItem.BadgeItems[i]
                if GUIItemContainsPoint(badgeItem, mouseX, mouseY) and badgeItem:GetIsVisible() then
                    local clientIndex = playerItem["ClientIndex"]
                    local _, badgeNames = Badges_GetBadgeTextures(clientIndex, "scoreboard")
                    local badge = ToString(badgeNames[i])
                    self.badgeNameTooltip:SetText(GetBadgeFormalName(badge))
                    self.badgeNameTooltip:Show(1)
                    return
                end
            end
        end        
    end

end

function GUIScoreboard:UpdateTeam(updateTeam)
    
    local teamGUIItem = updateTeam["GUIs"]["Background"]
    local teamNameGUIItem = updateTeam["GUIs"]["TeamName"]
    local teamInfoGUIItem = updateTeam["GUIs"]["TeamInfo"]
    local teamNameText = Locale.ResolveString( string.format("NAME_TEAM_%s", updateTeam["TeamNumber"]))
    local teamColor = updateTeam["Color"]
    local localPlayerHighlightColor = updateTeam["HighlightColor"]
    local playerList = updateTeam["PlayerList"]
    local teamScores = updateTeam["GetScores"]()
    local teamNumber = updateTeam["TeamNumber"]
    
    -- Determines if the local player can see secret information
    -- for this team.
    local isVisibleTeam = false
    local localPlayer = Client.GetLocalPlayer()
    if localPlayer then
    
        local localPlayerTeamNum = localPlayer:GetTeamNumber()
        -- Can see secret information if the player is on the team or is a spectator.
        if teamNumber == kTeamReadyRoom or localPlayerTeamNum == teamNumber or localPlayerTeamNum == kSpectatorIndex then
            isVisibleTeam = true
        end
        
    end
    
    -- How many items per player.
    local numPlayers = table.count(teamScores)
    
    -- Update the team name text.
    local playersOnTeamText = string.format("%d %s", numPlayers, numPlayers == 1 and Locale.ResolveString("SB_PLAYER") or Locale.ResolveString("SB_PLAYERS") )
    local teamHeaderText = nil
    
    if teamNumber == kTeamReadyRoom then
        -- Add number of players connecting
        local numPlayersConnecting = PlayerUI_GetNumConnectingPlayers()
        if numPlayersConnecting > 0 then
            -- It will show RR team if players are connecting even if no players are in the RR
            if numPlayers > 0 then
                teamHeaderText = string.format("%s (%s, %d %s)", teamNameText, playersOnTeamText, numPlayersConnecting, Locale.ResolveString("SB_CONNECTING") )
            else
                teamHeaderText = string.format("%s (%d %s)", teamNameText, numPlayersConnecting, Locale.ResolveString("SB_CONNECTING") )
            end
        end
    end
    
    if not teamHeaderText then
        teamHeaderText = string.format("%s (%s)", teamNameText, playersOnTeamText)
    end
    
    teamNameGUIItem:SetText( teamHeaderText )
    
    -- Update team resource display
    local teamResourcesString = ConditionalValue(isVisibleTeam, string.format(Locale.ResolveString("SB_TEAM_RES"), ScoreboardUI_GetTeamResources(teamNumber)), "")
    teamInfoGUIItem:SetText(string.format("%s", teamResourcesString))
    
    -- Make sure there is enough room for all players on this team GUI.
    teamGUIItem:SetSize(Vector(GetTeamItemWidth(), (GUIScoreboard.kTeamItemHeight) + ((GUIScoreboard.kPlayerItemHeight + GUIScoreboard.kPlayerSpacing) * numPlayers), 0))
    
    -- Resize the player list if it doesn't match.
    if table.count(playerList) ~= numPlayers then
        self:ResizePlayerList(playerList, numPlayers, teamGUIItem)
    end
    
    
    
    local currentY = GUIScoreboard.kTeamNameFontSize + GUIScoreboard.kTeamInfoFontSize + 10
    local currentPlayerIndex = 1
    local deadString = Locale.ResolveString("STATUS_DEAD")
    
    for index, player in pairs(playerList) do
    
        local playerRecord = teamScores[currentPlayerIndex]
        local playerName = playerRecord.Name
        local clientIndex = playerRecord.ClientIndex
        local score = playerRecord.Score
        local kills = playerRecord.Kills
        local assists = playerRecord.Assists
        local deaths = playerRecord.Deaths
        local isCommander = playerRecord.IsCommander and isVisibleTeam == true
        local isRookie = playerRecord.IsRookie
        local resourcesStr = ConditionalValue(isVisibleTeam, tostring(math.floor(playerRecord.Resources * 10) / 10), "-")
        local ping = playerRecord.Ping
        local pingStr = tostring(ping)
        local currentPosition = Vector(player["Background"]:GetPosition())
        local playerStatus = isVisibleTeam and playerRecord.Status or "-"
        local isSpectator = playerRecord.IsSpectator
        local isDead = isVisibleTeam and playerRecord.Status == deadString
        local isSteamFriend = playerRecord.IsSteamFriend
        local playerSkill = playerRecord.Skill
        
        if isVisibleTeam and teamNumber == kTeam1Index then
            local currentTech = GetTechIdsFromBitMask(playerRecord.Tech)
            if table.contains(currentTech, kTechId.Jetpack) then
                if playerStatus ~= "" and playerStatus ~= " " then
                    playerStatus = string.format("%s/%s", playerStatus, Locale.ResolveString("STATUS_JETPACK") )
                else
                    playerStatus = Locale.ResolveString("STATUS_JETPACK")
                end
            end
        end
        
        if isCommander then
            score = "*"
        end
        
        currentPosition.y = currentY
        player["Background"]:SetPosition(currentPosition)
        player["Background"]:SetColor(teamColor)
        
        -- Handle local player highlight
        if ScoreboardUI_IsPlayerLocal(playerName) then
            if self.playerHighlightItem:GetParent() ~= player["Background"] then
                if self.playerHighlightItem:GetParent() ~= nil then
                    self.playerHighlightItem:GetParent():RemoveChild(self.playerHighlightItem)
                end
                player["Background"]:AddChild(self.playerHighlightItem)
                self.playerHighlightItem:SetIsVisible(true)
                self.playerHighlightItem:SetColor(localPlayerHighlightColor)
            end
        end
        
        player["Number"]:SetText(index..".")
        player["Name"]:SetText(playerName)
        
        -- Needed to determine who to (un)mute when voice icon is clicked.
        player["ClientIndex"] = clientIndex
        
        -- Voice icon.
        local playerVoiceColor = GUIScoreboard.kVoiceDefaultColor
        if ChatUI_GetClientMuted(clientIndex) then
            playerVoiceColor = GUIScoreboard.kVoiceMuteColor
        elseif ChatUI_GetIsClientSpeaking(clientIndex) then
            playerVoiceColor = teamColor
        end

        player["Voice"]:SetColor(playerVoiceColor)
        player["Score"]:SetText(tostring(score))
        player["Kills"]:SetText(tostring(kills))
        player["Assists"]:SetText(tostring(assists))
        player["Deaths"]:SetText(tostring(deaths))
        player["Status"]:SetText(playerStatus)
        player["Resources"]:SetText(resourcesStr)
        player["Ping"]:SetText(pingStr)
        
        local white = GUIScoreboard.kWhiteColor
        local commanderColor = GUIScoreboard.kCommanderFontColor
        local baseColor, nameColor, statusColor = white, white, white
        
        if isCommander then  
        
           baseColor, nameColor, statusColor = commanderColor, commanderColor, commanderColor
           
        elseif isDead and isVisibleTeam then
        
            nameColor, statusColor = kDeadColor, kDeadColor 
            
        elseif isSteamFriend then
    
            nameColor, statusColor = kSteamFriendColor, kSteamFriendColor
            
        elseif playerRecord.IsRookie then
            
            nameColor = kNewPlayerColorFloat    
        
        end
        
        player["Score"]:SetColor(baseColor)
        player["Kills"]:SetColor(baseColor)
        player["Assists"]:SetColor(baseColor)
        player["Deaths"]:SetColor(baseColor)
        player["Status"]:SetColor(statusColor)
        player["Resources"]:SetColor(baseColor)   
        player["Name"]:SetColor(nameColor)
            
        if ping < GUIScoreboard.kLowPingThreshold then
            player["Ping"]:SetColor(GUIScoreboard.kLowPingColor)
        elseif ping < GUIScoreboard.kMedPingThreshold then
            player["Ping"]:SetColor(GUIScoreboard.kMedPingColor)
        elseif ping < GUIScoreboard.kHighPingThreshold then
            player["Ping"]:SetColor(GUIScoreboard.kHighPingColor)
        else
            player["Ping"]:SetColor(GUIScoreboard.kInsanePingColor)
        end
        currentY = currentY + GUIScoreboard.kPlayerItemHeight + GUIScoreboard.kPlayerSpacing
        currentPlayerIndex = currentPlayerIndex + 1
        
        local offset = kPlayerItemLeftMargin + kPlayerNumberWidth + kPlayerVoiceChatIconSize
        
        
        -- update badges info
        offset = offset + SetPlayerItemBadges( player, Badges_GetBadgeTextures(clientIndex, "scoreboard") )
        
        player["Name"]:SetPosition( Vector(
            offset,
            0,
            0 ))
        
    end

end

function GUIScoreboard:ResizePlayerList(playerList, numPlayers, teamGUIItem)
    
    while table.count(playerList) > numPlayers do
        teamGUIItem:RemoveChild(playerList[1]["Background"])
        playerList[1]["Background"]:SetIsVisible(false)
        table.insert(self.reusePlayerItems, playerList[1])
        table.remove(playerList, 1)
    end
    
    while table.count(playerList) < numPlayers do
        local newPlayerItem = self:CreatePlayerItem()
        table.insert(playerList, newPlayerItem)
        teamGUIItem:AddChild(newPlayerItem["Background"])
        newPlayerItem["Background"]:SetIsVisible(true)
    end

end

function GUIScoreboard:CreatePlayerItem()
    
    // Reuse an existing player item if there is one.
    if table.count(self.reusePlayerItems) > 0 then
        local returnPlayerItem = self.reusePlayerItems[1]
        table.remove(self.reusePlayerItems, 1)
        return returnPlayerItem
    end
    
    // Create background.
    local playerItem = GUIManager:CreateGraphicItem()
    playerItem:SetSize(Vector(GetTeamItemWidth() - (GUIScoreboard.kPlayerItemWidthBuffer * 2), GUIScoreboard.kPlayerItemHeight, 0))
    playerItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerItem:SetPosition(Vector(GUIScoreboard.kPlayerItemWidthBuffer, GUIScoreboard.kPlayerItemHeight / 2, 0))
    playerItem:SetColor(Color(1, 1, 1, 1))
    playerItem:SetTexture("ui/hud_elements.dds")
    playerItem:SetTextureCoordinates(0, 0, 0.558, 0.16)
    playerItem:SetStencilFunc(GUIItem.NotEqual)

    local playerItemChildX = kPlayerItemLeftMargin

    // Player number item
    local playerNumber = GUIManager:CreateTextItem()
    playerNumber:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    playerNumber:SetAnchor(GUIItem.Left, GUIItem.Center)
    playerNumber:SetTextAlignmentX(GUIItem.Align_Min)
    playerNumber:SetTextAlignmentY(GUIItem.Align_Center)
    playerNumber:SetPosition(Vector(playerItemChildX, 0, 0))
    playerItemChildX = playerItemChildX + kPlayerNumberWidth
    playerNumber:SetColor(Color(0.5, 0.5, 0.5, 1))
    playerNumber:SetStencilFunc(GUIItem.NotEqual)
    playerItem:AddChild(playerNumber)

    // Player voice icon item.
    local playerVoiceIcon = GUIManager:CreateGraphicItem()
    playerVoiceIcon:SetSize(Vector(kPlayerVoiceChatIconSize, kPlayerVoiceChatIconSize, 0))
    playerVoiceIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    playerVoiceIcon:SetPosition(Vector(
                playerItemChildX,
                -kPlayerVoiceChatIconSize/2,
                0))
    playerItemChildX = playerItemChildX + kPlayerVoiceChatIconSize
    playerVoiceIcon:SetTexture("ui/speaker.dds")
    playerVoiceIcon:SetStencilFunc(GUIItem.NotEqual)
    playerItem:AddChild(playerVoiceIcon)
    
    local playerSkillBar
    /*
    if GetGameInfoEntity():GetIsGatherReady() then
    
        playerSkillBar = GUIManager:CreateGraphicItem()
        playerSkillBar:SetAnchor(GUIItem.Left, GUIItem.Center)
        playerItem:AddChild(playerSkillBar)
        
        playerItemChildX = playerItemChildX + kSkillBarSize.x + kSkillBarPadding
    
    end
    */
    
    //----------------------------------------
    //  Badge icons
    //----------------------------------------
    local maxBadges = Badges_GetMaxBadges()
    local badgeItems = {}
    
    // Player badges
    for i = 1,maxBadges do

        local playerBadge = GUIManager:CreateGraphicItem()
        playerBadge:SetSize(Vector(kPlayerBadgeIconSize, kPlayerBadgeIconSize, 0))
        playerBadge:SetAnchor(GUIItem.Left, GUIItem.Center)
        playerBadge:SetPosition(Vector(playerItemChildX, -kPlayerBadgeIconSize/2, 0))
        playerItemChildX = playerItemChildX + kPlayerBadgeIconSize + kPlayerBadgeRightPadding
        playerBadge:SetIsVisible(false)
        playerBadge:SetStencilFunc(GUIItem.NotEqual)
        playerItem:AddChild(playerBadge)
        table.insert( badgeItems, playerBadge )

    end

    // Player name text item.
    local playerNameItem = GUIManager:CreateTextItem()
    playerNameItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    playerNameItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    playerNameItem:SetTextAlignmentX(GUIItem.Align_Min)
    playerNameItem:SetTextAlignmentY(GUIItem.Align_Center)
    playerNameItem:SetPosition(Vector(
                playerItemChildX,
                0, 0))
    playerNameItem:SetColor(Color(1, 1, 1, 1))
    playerNameItem:SetStencilFunc(GUIItem.NotEqual)
    playerItem:AddChild(playerNameItem)

    local currentColumnX = GUIScoreboard.kPlayerItemWidth
    
    // Status text item.
    local statusItem = GUIManager:CreateTextItem()
    statusItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    statusItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    statusItem:SetTextAlignmentX(GUIItem.Align_Min)
    statusItem:SetTextAlignmentY(GUIItem.Align_Center)
    statusItem:SetPosition(Vector(currentColumnX + 30, 0, 0))
    statusItem:SetColor(Color(1, 1, 1, 1))
    statusItem:SetStencilFunc(GUIItem.NotEqual)
    playerItem:AddChild(statusItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX * 2 + 35
    
    // Score text item.
    local scoreItem = GUIManager:CreateTextItem()
    scoreItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    scoreItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    scoreItem:SetTextAlignmentX(GUIItem.Align_Center)
    scoreItem:SetTextAlignmentY(GUIItem.Align_Center)
    scoreItem:SetPosition(Vector(currentColumnX + 30, 0, 0))
    scoreItem:SetColor(Color(1, 1, 1, 1))
    scoreItem:SetStencilFunc(GUIItem.NotEqual)
    playerItem:AddChild(scoreItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX + 30
    
    // Kill text item.
    local killsItem = GUIManager:CreateTextItem()
    killsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    killsItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    killsItem:SetTextAlignmentX(GUIItem.Align_Center)
    killsItem:SetTextAlignmentY(GUIItem.Align_Center)
    killsItem:SetPosition(Vector(currentColumnX, 0, 0))
    killsItem:SetColor(Color(1, 1, 1, 1))
    killsItem:SetStencilFunc(GUIItem.NotEqual)
    playerItem:AddChild(killsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // assists text item.
    local assistsItem = GUIManager:CreateTextItem()
    assistsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    assistsItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    assistsItem:SetTextAlignmentX(GUIItem.Align_Center)
    assistsItem:SetTextAlignmentY(GUIItem.Align_Center)
    assistsItem:SetPosition(Vector(currentColumnX, 0, 0))
    assistsItem:SetColor(Color(1, 1, 1, 1))
    assistsItem:SetStencilFunc(GUIItem.NotEqual)
    playerItem:AddChild(assistsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Deaths text item.
    local deathsItem = GUIManager:CreateTextItem()
    deathsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    deathsItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    deathsItem:SetTextAlignmentX(GUIItem.Align_Center)
    deathsItem:SetTextAlignmentY(GUIItem.Align_Center)
    deathsItem:SetPosition(Vector(currentColumnX, 0, 0))
    deathsItem:SetColor(Color(1, 1, 1, 1))
    deathsItem:SetStencilFunc(GUIItem.NotEqual)
    playerItem:AddChild(deathsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Resources text item.
    local resItem = GUIManager:CreateTextItem()
    resItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    resItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    resItem:SetTextAlignmentX(GUIItem.Align_Center)
    resItem:SetTextAlignmentY(GUIItem.Align_Center)
    resItem:SetPosition(Vector(currentColumnX, 0, 0))
    resItem:SetColor(Color(1, 1, 1, 1))
    resItem:SetStencilFunc(GUIItem.NotEqual)
    playerItem:AddChild(resItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Ping text item.
    local pingItem = GUIManager:CreateTextItem()
    pingItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    pingItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    pingItem:SetTextAlignmentX(GUIItem.Align_Min)
    pingItem:SetTextAlignmentY(GUIItem.Align_Center)
    pingItem:SetPosition(Vector(currentColumnX, 0, 0))
    pingItem:SetColor(Color(1, 1, 1, 1))
    pingItem:SetStencilFunc(GUIItem.NotEqual)
    playerItem:AddChild(pingItem)
    
    return { Background = playerItem, Number = playerNumber, Name = playerNameItem,
        Voice = playerVoiceIcon, Status = statusItem, Score = scoreItem, Kills = killsItem,
        Assists = assistsItem, Deaths = deathsItem, Resources = resItem, Ping = pingItem,
        BadgeItems = badgeItems, SkillBar = playerSkillBar
    }
    
end

local function HandlePlayerVoiceClicked(self)

    local mouseX, mouseY = Client.GetCursorPosScreen()
    for t = 1, #self.teams do
    
        local playerList = self.teams[t]["PlayerList"]
        for p = 1, #playerList do
        
            local playerItem = playerList[p]
            if GUIItemContainsPoint(playerItem["Voice"], mouseX, mouseY) then
            
                local clientIndex = playerItem["ClientIndex"]
                ChatUI_SetClientMuted(clientIndex, not ChatUI_GetClientMuted(clientIndex))
                
            end
            
        end
        
    end
    
end

function GUIScoreboard:SendKeyEvent(key, down)

    if ChatUI_EnteringChatMessage() then
        return false
    end
    
    if GetIsBinding(key, "Scoreboard") then
        self.visible = down
    end
    
    if not self.visible then
        return false
    end
    
    if key == InputKey.MouseButton0 and self.mousePressed["LMB"]["Down"] ~= down then

        self.mousePressed["LMB"]["Down"] = down
        if down then
            local mouseX, mouseY = Client.GetCursorPosScreen()
            self.isDragging = GUIItemContainsPoint(self.slidebarBg, mouseX, mouseY)
            
            if not MouseTracker_GetIsVisible() then
                SetMouseVisible(self, true)
            else
                HandlePlayerVoiceClicked(self)
                HandleBadgeClicked(self)
            end
            
            return true
        end
    end
    
    if self.slidebarBg:GetIsVisible() then
        if key == InputKey.MouseWheelDown then
            self.slidePercentage = math.min(self.slidePercentage + 5, 100)
            return true
        elseif key == InputKey.MouseWheelUp then
            self.slidePercentage = math.max(self.slidePercentage - 5, 0)
            return true
        elseif key == InputKey.PageDown and down then
            self.slidePercentage = math.min(self.slidePercentage + 10, 100)
            return true
        elseif key == InputKey.PageUp and down then
            self.slidePercentage = math.max(self.slidePercentage - 10, 0)
            return true
        elseif key == InputKey.Home then
            self.slidePercentage = 0
            return true
        elseif key == InputKey.End then
            self.slidePercentage = 100
            return true
        end
    end
    
end