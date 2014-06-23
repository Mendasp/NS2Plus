// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//
// lua\GUIGameEnd.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

local kEndStates = enum({ 'AlienPlayerWin', 'MarinePlayerWin', 'AlienPlayerLose', 'MarinePlayerLose', 'AlienPlayerDraw', 'MarinePlayerDraw' })

local kEndIconTextures = { [kEndStates.AlienPlayerWin] = "ui/alien_victory.dds",
                           [kEndStates.MarinePlayerWin] = "ui/marine_victory.dds",
                           [kEndStates.AlienPlayerLose] = "ui/alien_defeat.dds",
                           [kEndStates.MarinePlayerLose] = "ui/marine_defeat.dds",
                           [kEndStates.AlienPlayerDraw] = "ui/alien_draw.dds",
                           [kEndStates.MarinePlayerDraw] = "ui/marine_draw.dds", }

local kEndIconWidth = 1024
local kEndIconHeight = 600
local kEndIconPosition = Vector(-kEndIconWidth / 2, -kEndIconHeight / 2, 0)

local kMessageFontName = { marine = "fonts/AgencyFB_huge.fnt", alien = "fonts/Stamp_huge.fnt" }
local kMessageText = { [kEndStates.AlienPlayerWin] = "ALIEN_VICTORY",
                       [kEndStates.MarinePlayerWin] = "MARINE_VICTORY",
                       [kEndStates.AlienPlayerLose] = "ALIEN_DEFEAT",
                       [kEndStates.MarinePlayerLose] = "MARINE_DEFEAT",
                       [kEndStates.AlienPlayerDraw] = "DRAW_GAME",
                       [kEndStates.MarinePlayerDraw] = "DRAW_GAME", }   
local kMessageWinColor = { marine = kMarineFontColor, alien = kAlienFontColor }
local kMessageLoseColor = { marine = Color(0.2, 0, 0, 1), alien = Color(0.2, 0, 0, 1) }
local kMessageDrawColor = { marine = Color(0.75, 0.75, 0.75, 1), alien = Color(0.75, 0.75, 0.75, 1) }
local kMessageOffset = Vector(0, -255, 0)

class 'GUIGameEnd' (GUIAnimatedScript)

function GUIGameEnd:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.endIcon = self:CreateAnimatedGraphicItem()
    self.endIcon:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.endIcon:SetPosition(kEndIconPosition * GUIScale(1))
    self.endIcon:SetSize(Vector(GUIScale(kEndIconWidth), GUIScale(kEndIconHeight), 0))
    self.endIcon:SetBlendTechnique(GUIItem.Add)
    self.endIcon:SetInheritsParentAlpha(true)
    self.endIcon:SetIsVisible(false)
    
    self.messageText = self:CreateAnimatedTextItem()
    self.messageText:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.messageText:SetTextAlignmentX(GUIItem.Align_Center)
    self.messageText:SetTextAlignmentY(GUIItem.Align_Center)
    self.messageText:SetPosition(kMessageOffset * GUIScale(1))
    self.messageText:SetInheritsParentAlpha(true)
    self.endIcon:AddChild(self.messageText)
    
end

function GUIGameEnd:SetGameEnded(playerWon, playerDraw, playerTeamType )

    self.endIcon:DestroyAnimations()

    self.endIcon:SetIsVisible(true)
    self.endIcon:SetPosition(kEndIconPosition * GUIScale(1))
    self.endIcon:SetColor(Color(1, 1, 1, 0))
    local invisibleFunc = function() self.endIcon:SetIsVisible(false) end
    local fadeOutFunc = function() self.endIcon:FadeOut(0.2, nil, AnimateLinear, invisibleFunc) end
    local pauseFunc = function() self.endIcon:Pause(6, nil, nil, fadeOutFunc) end
    self.endIcon:FadeIn(1.0, nil, AnimateLinear, pauseFunc)

    local playerIsMarine = playerTeamType == kMarineTeamType

    local endState
    if playerWon then
        endState = playerIsMarine and kEndStates.MarinePlayerWin or kEndStates.AlienPlayerWin
    elseif playerDraw then
        endState = playerIsMarine and kEndStates.MarinePlayerDraw or kEndStates.AlienPlayerDraw
    else
        endState = playerIsMarine and kEndStates.MarinePlayerLose or kEndStates.AlienPlayerLose
    end


    self.endIcon:SetTexture(kEndIconTextures[endState])

    self.messageText:SetFontName(kMessageFontName[playerIsMarine and "marine" or "alien"])

    if playerWon then
        self.messageText:SetColor(kMessageWinColor[playerIsMarine and "marine" or "alien"])
    elseif playerDraw then
        self.messageText:SetColor(kMessageDrawColor[playerIsMarine and "marine" or "alien"])		
    else
        self.messageText:SetColor(kMessageLoseColor[playerIsMarine and "marine" or "alien"])
    end

    local messageString = Locale.ResolveString(kMessageText[endState])
	if playerDraw then
		messageString = "Draw Game!"
	end
    if PlayerUI_IsASpectator() then
        local winningTeamName = nil
        if endState == kEndStates.MarinePlayerWin then
            winningTeamName = InsightUI_GetTeam1Name()
    Shared.ConsoleCommand("score1 +")
        elseif endState == kEndStates.AlienPlayerWin then
            winningTeamName = InsightUI_GetTeam2Name()
    Shared.ConsoleCommand("score2 +")    
        elseif playerDraw then
    Shared.ConsoleCommand("score1 +")
    Shared.ConsoleCommand("score2 +")
        end
        if winningTeamName then
            messageString = string.format("%s Wins!", winningTeamName)
        end
    end
    self.messageText:SetText(messageString)

    local entityList = Shared.GetEntitiesWithClassname("GameInfo")
    if entityList:GetSize() > 0 then
        local gameInfo = entityList:GetEntityAtIndex(0)		
        gameInfo.prevTimeLength = math.max( 0, math.floor(Shared.GetTime()) - gameInfo:GetStartTime() )
    end

end

local function OnGameEnd(message)

    local localPlayer = Client.GetLocalPlayer()

    if localPlayer then

        local playerTeamType = localPlayer:GetTeamType()		
        if playerTeamType == kNeutralTeamType then playerTeamType = message.win end
        if playerTeamType == kNeutralTeamType then playerTeamType = kMarineTeamType end

        local playerWin = ( message.win == playerTeamType )
        local playerDraw = ( message.win == kNeutralTeamType )

        ClientUI.GetScript("GUIGameEnd"):SetGameEnded( playerWin, playerDraw, playerTeamType )
        if playerWin or playerDraw then
            Client.PlayMusic("sound/NS2.fev/victory")
        else
            Client.PlayMusic("sound/NS2.fev/loss")
        end

    end

    // Automatically end any performance logging when the round is done.
    Shared.ConsoleCommand("p_endlog")

end
Client.HookNetworkMessage("CHUDGameEnd", OnGameEnd)