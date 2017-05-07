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

local originalSpectatorInit
originalSpectatorInit = Class_ReplaceMethod( "GUISpectator", "Initialize",
	function(self)
		originalSpectatorInit(self)
		
		self.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
		tooltipText = ""
		found = false
		foundTime = -1
	end)
	
local originalSpectatorUninit
originalSpectatorUninit = Class_ReplaceMethod( "GUISpectator", "Uninitialize",
	function(self)
		originalSpectatorUninit(self)
		
		self.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
		tooltipText = ""
		found = false
		
		self.tooltip:Hide(0)
		foundTime = -1
	end)

local originalSpectatorLeft
originalSpectatorLeft = Class_ReplaceMethod( "GUIProduction", "SetSpectatorLeft",
	function(self)
		originalSpectatorLeft(self)
		
		self.Background:SetPosition(Vector(GUIMinimap.kBackgroundWidth,-GUIScale(120),0))
	end)
	
local originalSpectatorRight
originalSpectatorRight = Class_ReplaceMethod( "GUIProduction", "SetSpectatorRight",
	function(self)
		originalSpectatorRight(self)
		
		self.Background:SetPosition(Vector(-GUIScale(280),-GUIScale(120),0))
	end)

local originalSpectatorUpdate
originalSpectatorUpdate = Class_ReplaceMethod( "GUISpectator", "Update",
	function(self, deltaTime)
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
	end)

local originalCommanderOnInit
originalCommanderOnInit = Class_ReplaceMethod( "Commander", "OnInitLocalClient",
	function(self)
		originalCommanderOnInit(self)
		
		self.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
		tooltipText = ""
		found = false
		foundTime = -1
	end)

local originalCommanderOnDestroy
originalCommanderOnDestroy = Class_ReplaceMethod( "Commander", "OnDestroy",
	function(self)
		originalCommanderOnDestroy(self)
		
		self.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
		tooltipText = ""
		found = false
		
		self.tooltip:Hide(0)
		foundTime = -1
	end)

local originalUpdateClientEffects
originalUpdateClientEffects = Class_ReplaceMethod( "Commander", "UpdateClientEffects",
	function(self, deltaTime, isLocal)
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
	end)