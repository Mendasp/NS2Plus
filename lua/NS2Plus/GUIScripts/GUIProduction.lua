local tooltipText
local function displayNameTooltip(tech)
	local mouseX, mouseY = Client.GetCursorPosScreen()
	if GUIItemContainsPoint(tech.Icon, mouseX, mouseY) then
		tooltipText = GetDisplayNameForTechId(tech.Id)
	end
end

local function displayNameTimeTooltip(tech)
	local mouseX, mouseY = Client.GetCursorPosScreen()
	if GUIItemContainsPoint(tech.Icon,mouseX, mouseY) then
		local text = GetDisplayNameForTechId(tech.Id)
		
		local timeLeft = tech.StartTime + tech.ResearchTime - Shared.GetTime()
		timeLeft = timeLeft < 0 and 0 or timeLeft
		local minutes = math.floor(timeLeft/60)
		local seconds = math.ceil(timeLeft - minutes*60)
		tooltipText = string.format("%s - %01.0f:%02.0f", text, minutes, seconds)
	end
end

local originalSpectatorInit = GUISpectator.Initialize
function GUISpectator:Initialize()
	originalSpectatorInit(self)

	self.tooltip = GetGUIManager():CreateGUIScript("menu/GUIHoverTooltip")
end
	
local originalSpectatorUninit = GUISpectator.Uninitialize
function GUISpectator:Uninitialize()
	originalSpectatorUninit(self)

	if self.tooltip then
		self.tooltip:Hide(0)
	end
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

	self.guiMarineProduction.InProgress:ForEach(displayNameTimeTooltip)
	self.guiMarineProduction.Complete:ForEach(displayNameTooltip)
	self.guiAlienProduction.InProgress:ForEach(displayNameTimeTooltip)
	self.guiAlienProduction.Complete:ForEach(displayNameTooltip)

	if tooltipText then
		self.tooltip:SetText(tooltipText)
		self.tooltip:Show()
		tooltipText = nil
	else
		self.tooltip:Hide()
	end
end

-- Todo: Refactor all Commander class modifications into one lua file