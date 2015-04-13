local tooltipText = ""
local found = false
local foundTime = -1
local function displayTooltip(tech)
	if GUIItemContainsPoint(tech.Icon, Client.GetCursorPosScreen()) then
		found = true
		foundTime = Shared.GetTime(true)
		tooltipText = GetDisplayNameForTechId(tech.Id)
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
		self.guiMarineProduction.InProgress:ForEach(displayTooltip)
		self.guiMarineProduction.Complete:ForEach(displayTooltip)
		self.guiAlienProduction.InProgress:ForEach(displayTooltip)
		self.guiAlienProduction.Complete:ForEach(displayTooltip)
			
		if found then
			self.tooltip:SetText(tooltipText)
			self.tooltip:Show()
		elseif foundTime > -1 and foundTime + 0.1 < Shared.GetTime(true) then
			self.tooltip:Hide()
			foundTime = -1
		end
	end)