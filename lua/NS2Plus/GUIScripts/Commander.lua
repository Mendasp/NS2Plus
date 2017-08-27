local originalCommanderOnInit
originalCommanderOnInit = Commander.OnInitLocalClient
function Commander:OnInitLocalClient()
    originalCommanderOnInit(self)

    self.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
end

local originalCommanderOnDestroy = Commander.OnDestroy
function Commander:OnDestroy()
    originalCommanderOnDestroy(self)

    if self.tooltip then
        self.tooltip:Hide(0)
    end
end

--Todo: Clean this mess of a local function
local tooltipText
local function displayTimeTooltip(tech)
    if GUIItemContainsPoint(tech.Icon, Client.GetCursorPosScreen()) then
        local timeLeft = tech.StartTime + tech.ResearchTime - Shared.GetTime()
        local minutes = math.floor(timeLeft/60)
        local seconds = math.ceil(timeLeft - minutes*60)
        tooltipText = string.format("%01.0f:%02.0f", minutes, seconds)
    end
end

local originalUpdateClientEffects = Commander.UpdateClientEffects
function Commander:UpdateClientEffects(deltaTime, isLocal)
    originalUpdateClientEffects(self, deltaTime, isLocal)

    if CHUDGetOption("researchtimetooltip") then
        self.production.InProgress:ForEach(displayTimeTooltip)
    end

    if tooltipText then
        self.tooltip:SetText(tooltipText)
        self.tooltip:Show(0.1)
        tooltipText = nil
    end
end

