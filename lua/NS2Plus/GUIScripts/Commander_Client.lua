if not Client then return end --Don't run inside Predict VM

local gameTime
function GetGUIGameTime()
    return gameTime
end

local originalCommanderOnInit = Commander.OnInitLocalClient
function Commander:OnInitLocalClient()
    originalCommanderOnInit(self)

    self.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")

    local minimapScript = GetGUIMinimap and GetGUIMinimap()
    if minimapScript then
        minimapScript:UpdateCHUDCommSettings()
    end

    self.gameTime = GUIManager:CreateTextItem()
    self.gameTime:SetFontIsBold(true)
    self.gameTime:SetLayer(kGUILayerPlayerHUDForeground2)
    self.gameTime:SetColor(Color(0.5, 0.5, 0.5, 1))
    self.gameTime:SetPosition(GUIScale(Vector(35, 60, 0)))
    self.gameTime:SetFontName(GUIMarineHUD.kTextFontName)
    self.gameTime:SetScale(GetScaledVector())
    GUIMakeFontScale(self.gameTime)

    gameTime = self.gameTime
end

local originalCommanderOnDestroy = Commander.OnDestroy
function Commander:OnDestroy()
    originalCommanderOnDestroy(self)

    gameTime = nil
    self.gameTime = nil
    GUI.DestroyItem(self.gameTime)

    if self.tooltip then
        self.tooltip:Hide(0)
    end
end

--Todo: Clean this mess of a local function
local tooltipText
local function displayTimeTooltip(tech)
    if GUIItemContainsPoint(tech.Icon, Client.GetCursorPosScreen()) then
        local timeLeft = tech.StartTime + tech.ResearchTime - Shared.GetTime()
        timeLeft = timeLeft < 0 and 0 or timeLeft
        local minutes = math.floor(timeLeft/60)
        local seconds = math.ceil(timeLeft - minutes*60)
        tooltipText = string.format("%01.0f:%02.0f", minutes, seconds)
    end
end

local originalUpdateClientEffects = Commander.UpdateClientEffects
function Commander:UpdateClientEffects(deltaTime, isLocal)
    originalUpdateClientEffects(self, deltaTime, isLocal)

    if CHUDGetOption("researchtimetooltip") and self.production then
        self.production.InProgress:ForEach(displayTimeTooltip)
    end

    if tooltipText and self.tooltip then
        self.tooltip:SetText(tooltipText)
        self.tooltip:Show(0.1)
        tooltipText = nil
    end
end

local originalUpdateMenu = Commander.UpdateMenu
function Commander:UpdateMenu()
	originalUpdateMenu(self)

    if self.gameTime then
        self.gameTime:SetText(CHUDGetGameTimeString())
        self.gameTime:SetIsVisible(CHUDGetOption("gametime"))
    end
end

