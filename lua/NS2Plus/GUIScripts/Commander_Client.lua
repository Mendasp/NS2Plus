if not Client then return end --Don't run inside Predict VM

local gameTime
function GetGUIGameTime()
	return gameTime
end

local realTime
function GetGUIRealTime()
	return realTime
end

local originalCommanderOnInit = Commander.OnInitLocalClient
function Commander:OnInitLocalClient()
	originalCommanderOnInit(self)

	self.tooltip = GetGUIManager():CreateGUIScript("menu/GUIHoverTooltip")

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

	self.realTime = GUIManager:CreateTextItem()
	self.realTime:SetFontIsBold(true)
	self.realTime:SetLayer(kGUILayerPlayerHUDForeground2)
	self.realTime:SetColor(Color(0.5, 0.5, 0.5, 1))
	self.realTime:SetPosition(GUIScale(Vector(35, 80, 0)))
	self.realTime:SetFontName(GUIMarineHUD.kTextFontName)
	self.realTime:SetScale(GetScaledVector())
	GUIMakeFontScale(self.realTime)
	realTime = self.realTime
end

local originalCommanderOnDestroy = Commander.OnDestroy
function Commander:OnDestroy()
	originalCommanderOnDestroy(self)

	GUI.DestroyItem(self.gameTime)
	gameTime = nil
	self.gameTime = nil

	GUI.DestroyItem(self.realTime)
	realTime = nil
	self.realTime = nil

	if self.tooltip then
		self.tooltip:Hide(0)
	end
end

--Todo: Clean this mess of a local function
local tooltipText
local function displayTimeTooltip(tech)
	local mouseX, mouseY = Client.GetCursorPosScreen()
	if GUIItemContainsPoint(tech.Icon,  mouseX, mouseY) then
		local timeLeft = tech.StartTime + tech.ResearchTime - Shared.GetTime()
		timeLeft = math.max(0, timeLeft)
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

	if self.tooltip then
		if tooltipText then
			self.tooltip:SetText(tooltipText)
			self.tooltip:Show()
			tooltipText = nil
		else
			self.tooltip:Hide()
		end
	end
end

local originalUpdateMenu = Commander.UpdateMenu
function Commander:UpdateMenu()
	originalUpdateMenu(self)

	if self.gameTime then
		self.gameTime:SetText(CHUDGetGameTimeString())
		self.gameTime:SetIsVisible(CHUDGetOption("gametime"))
	end

	if self.realTime then
		self.realTime:SetText(CHUDGetRealTimeString())
		self.realTime:SetIsVisible(CHUDGetOption("realtime"))
	end
end

