local tooltipText = ""
local found = false
local foundTime = -1
local function displayNameTooltip(tech)
	if GUIItemContainsPoint(tech.Icon, Client.GetCursorPosScreen()) then
		found = true
		foundTime = Shared.GetTime(true)
		tooltipText = GetDisplayNameForTechId(tech.Id)
	end
end

local function displayNameTimeTooltip(tech)
	if GUIItemContainsPoint(tech.Icon, Client.GetCursorPosScreen()) then
		found = true
		foundTime = Shared.GetTime(true)
		tooltipText = GetDisplayNameForTechId(tech.Id)
		
		local timeLeft = tech.StartTime + tech.ResearchTime - Shared.GetTime()
		local minutes = math.floor(timeLeft/60)
		local seconds = math.ceil(timeLeft - minutes*60)
		tooltipText = string.format("%s - %01.0f:%02.0f", tooltipText, minutes, seconds)
	end
end

local function displayTimeTooltip(tech)
	if GUIItemContainsPoint(tech.Icon, Client.GetCursorPosScreen()) then
		found = true
		foundTime = Shared.GetTime(true)
		
		local timeLeft = tech.StartTime + tech.ResearchTime - Shared.GetTime()
		local minutes = math.floor(timeLeft/60)
		local seconds = math.ceil(timeLeft - minutes*60)
		tooltipText = string.format("%01.0f:%02.0f", minutes, seconds)
	end
end

local originalSpectatorInit = GUISpectator.Initialize
function GUISpectator:Initialize()
	originalSpectatorInit(self)

	self.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
	tooltipText = ""
	found = false
	foundTime = -1
end
	
local originalSpectatorUninit = GUISpectator.Uninitialize
function GUISpectator:Uninitialize()
	originalSpectatorUninit(self)

	self.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
	tooltipText = ""
	found = false

	self.tooltip:Hide(0)
	foundTime = -1
end

local originalSpectatorLeft = GUIProduction.SetSpectatorLeft
function GUIProduction:SetSpectatorLeft()
	originalSpectatorLeft(self)

	self.Background:SetPosition(Vector(GUIMinimap.kBackgroundWidth,-GUIScale(120),0))
end
	
local originalSpectatorRight = GUIProduction.SetSpectatorRight
function GUIProduction:SetSpectatorRight()
	originalSpectatorRight(self)

	self.Background:SetPosition(Vector(-GUIScale(280),-GUIScale(120),0))
end

local originalSpectatorUpdate = GUISpectator.Update
function GUISpectator:Update(deltaTime)
	originalSpectatorUpdate(self, deltaTime)

	found = false
	self.guiMarineProduction.InProgress:ForEach(displayNameTimeTooltip)
	self.guiMarineProduction.Complete:ForEach(displayNameTooltip)
	self.guiAlienProduction.InProgress:ForEach(displayNameTimeTooltip)
	self.guiAlienProduction.Complete:ForEach(displayNameTooltip)

	if found then
		self.tooltip:SetText(tooltipText)
		self.tooltip:Show()
	elseif foundTime > -1 and foundTime + 0.1 < Shared.GetTime(true) then
		self.tooltip:Hide()
		foundTime = -1
	end
end

-- Todo: Refactor all Commander class modifications into one lua file
local originalCommanderOnInit
originalCommanderOnInit = Commander.OnInitLocalClient
function Commander:OnInitLocalClient()
	originalCommanderOnInit(self)

	self.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
	tooltipText = ""
	found = false
	foundTime = -1
end

local originalCommanderOnDestroy = Commander.OnDestroy
function Commander:OnDestroy()
	originalCommanderOnDestroy(self)

	self.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
	tooltipText = ""
	found = false

	self.tooltip:Hide(0)
	foundTime = -1
end

local originalUpdateClientEffects = Commander.UpdateClientEffects
function Commander:UpdateClientEffects(deltaTime, isLocal)
	originalUpdateClientEffects(self, deltaTime, isLocal)

	found = false

	if CHUDGetOption("researchtimetooltip") then
		self.production.InProgress:ForEach(displayTimeTooltip)
	end

	if found then
		self.tooltip:SetText(tooltipText)
		self.tooltip:Show()
	elseif foundTime > -1 and foundTime + 0.1 < Shared.GetTime(true) then
		self.tooltip:Hide()
		foundTime = -1
	end
end