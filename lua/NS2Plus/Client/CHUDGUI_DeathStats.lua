Script.Load("lua/GUIAnimatedScript.lua")

class 'CHUDGUI_DeathStats' (GUIAnimatedScript)

CHUDStatsVisible = false

local gStatsUI
local lastStatsMsg = 0

local screenWidth = Client.GetScreenWidth()
local screenHeight = Client.GetScreenHeight()
local aspectRatio = screenWidth/screenHeight

local statsTable = nil

-- To avoid printing 200.00 or things like that
local function printNum(number)
	if number and IsNumber(number) then
		if number == math.floor(number) then
			return string.format("%d", number)
		else
			return string.format("%.2f", number)
		end
	else
		return "NaN"
	end
end

local kTitleFontName = Fonts.kAgencyFB_Medium
local kRowFontName = Fonts.kArial_17
local widthPercentage
local kTitleSize
local scaledVector
local kTopOffset
local kTextShadowOffset

local kHeaderTexture = PrecacheAsset("ui/statsheader.dds")
local kHeaderCoordsLeft = { 0, 0, 15, 64 }
local kHeaderCoordsMiddle = { 16, 0, 112, 64 }
local kHeaderCoordsRight = { 113, 0, 128, 64 }

local kMarineStatsColor = Color(0, 0.75, 0.88, 0.8)
local kAlienStatsColor = Color(0.84, 0.48, 0.17, 0.8)
local kStatsEvenColor = Color(0, 0, 0, 0.9)
local kStatsOddColor = Color(0, 0, 0, 0.8)

local function UpdateSizeOfUI(self, screenWidth, screenHeight)
	kTitleSize = Vector(GUILinearScale(250), GUILinearScale(50), 0)
	scaledVector = GUILinearScale(Vector(1,1,1))
	kTopOffset = GUILinearScale(64)

	kRowSize = Vector(kTitleSize.x*0.9, GUILinearScale(24), 0)
	kTableContainerOffset = GUILinearScale(5)
	kRowBorderSize = GUILinearScale(2)
	kRowPlayerNameOffset = GUILinearScale(10)
	kTextShadowOffset = GUILinearScale(2)
end

function CHUDGUI_DeathStats:OnResolutionChanged(oldX, oldY, newX, newY)
	screenWidth = newX
	screenHeight = newY
	aspectRatio = screenWidth/screenHeight
	
	self:Uninitialize()
	self:Initialize()
end

function CHUDGUI_DeathStats:Initialize()

	GUIAnimatedScript.Initialize(self)
	
	UpdateSizeOfUI(self, screenWidth, screenHeight)
	
	self.titleBackground = self:CreateAnimatedGraphicItem()
	self.titleBackground:SetTexture(kHeaderTexture)
	self.titleBackground:SetIsScaling(false)
	self.titleBackground:SetColor(Color(1, 1, 1, 0))
	self.titleBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
	self.titleBackground:SetPosition(Vector(-kTitleSize.x/2, kTopOffset, 0))
	self.titleBackground:SetSize(kTitleSize)
	self.titleBackground:SetTexturePixelCoordinates(unpack(kHeaderCoordsMiddle))
	self.titleBackground:SetLayer(kGUILayerPlayerHUD)
	
	self.titleBackgroundLeft = GetGUIManager():CreateGraphicItem()
	self.titleBackgroundLeft:SetInheritsParentAlpha(true)
	self.titleBackgroundLeft:SetTexture(kHeaderTexture)
	self.titleBackgroundLeft:SetColor(Color(1, 1, 1, 1))
	self.titleBackgroundLeft:SetAnchor(GUIItem.Left, GUIItem.Top)
	self.titleBackgroundLeft:SetPosition(Vector(-GUILinearScale(16), 0, 0))
	self.titleBackgroundLeft:SetSize(Vector(GUILinearScale(16), kTitleSize.y, 0))
	self.titleBackgroundLeft:SetTexturePixelCoordinates(unpack(kHeaderCoordsLeft))
	self.titleBackgroundLeft:SetLayer(kGUILayerPlayerHUD)
	self.titleBackground:AddChild(self.titleBackgroundLeft)
	
	self.titleBackgroundRight = GetGUIManager():CreateGraphicItem()
	self.titleBackgroundRight:SetInheritsParentAlpha(true)
	self.titleBackgroundRight:SetTexture(kHeaderTexture)
	self.titleBackgroundRight:SetColor(Color(1, 1, 1, 1))
	self.titleBackgroundRight:SetAnchor(GUIItem.Left, GUIItem.Top)
	self.titleBackgroundRight:SetPosition(Vector(kTitleSize.x, 0, 0))
	self.titleBackgroundRight:SetSize(Vector(GUILinearScale(16), kTitleSize.y, 0))
	self.titleBackgroundRight:SetTexturePixelCoordinates(unpack(kHeaderCoordsRight))
	self.titleBackgroundRight:SetLayer(kGUILayerPlayerHUD)
	self.titleBackground:AddChild(self.titleBackgroundRight)
	
	self.titleShadow = GetGUIManager():CreateTextItem()
	self.titleShadow:SetFontName(kTitleFontName)
	self.titleShadow:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.titleShadow:SetTextAlignmentX(GUIItem.Align_Center)
	self.titleShadow:SetTextAlignmentY(GUIItem.Align_Center)
	self.titleShadow:SetText("Last life stats")
	self.titleShadow:SetColor(Color(0, 0, 0, 1))
	self.titleShadow:SetScale(scaledVector)
	self.titleShadow:SetInheritsParentAlpha(true)
	self.titleBackground:AddChild(self.titleShadow)
	
	self.titleText = GetGUIManager():CreateTextItem()
	self.titleText:SetFontName(kTitleFontName)
	self.titleText:SetTextAlignmentX(GUIItem.Align_Center)
	self.titleText:SetTextAlignmentY(GUIItem.Align_Center)
	self.titleText:SetPosition(Vector(-kTextShadowOffset, -kTextShadowOffset, 0))
	self.titleText:SetText("Last life stats")
	self.titleText:SetScale(scaledVector)
	self.titleText:SetInheritsParentAlpha(true)
	self.titleShadow:AddChild(self.titleText)
	
	self.actionIconGUI = GetGUIManager():CreateGUIScript("GUIActionIcon")
	self.actionIconGUI.pickupIcon:SetLayer(kGUILayerPlayerHUD)
	
	self:SetStats()
	
	self.fading = false
	
	self.requestVisible = false
	
	gStatsUI = self
end

function CHUDGUI_DeathStats:AddRow(leftText, rightText, bgColor, textColor)
	local containerSize = self.tableBackground:GetSize()
	self.tableBackground:SetSize(Vector(containerSize.x, containerSize.y + kRowSize.y, 0))
	
	local item = {}
	
	item.background = GUIManager:CreateGraphicItem()
	item.background:SetColor(bgColor)
	item.background:SetInheritsParentAlpha(true)
	item.background:SetAnchor(GUIItem.Left, GUIItem.Top)
	item.background:SetPosition(Vector(kRowBorderSize, containerSize.y - kRowBorderSize, 0))
	item.background:SetLayer(kGUILayerMainMenu)
	item.background:SetSize(kRowSize)
	
	self.tableBackground:AddChild(item.background)
	
	item.leftText = GUIManager:CreateTextItem()
	item.leftText:SetFontName(kRowFontName)
	item.leftText:SetColor(textColor)
	item.leftText:SetInheritsParentAlpha(true)
	item.leftText:SetScale(scaledVector)
	item.leftText:SetAnchor(GUIItem.Left, GUIItem.Center)
	item.leftText:SetTextAlignmentY(GUIItem.Align_Center)
	item.leftText:SetPosition(Vector(GUILinearScale(5), 0, 0))
	item.leftText:SetText(leftText or "")
	item.leftText:SetLayer(kGUILayerMainMenu)
	item.background:AddChild(item.leftText)
	
	item.rightText = GUIManager:CreateTextItem()
	item.rightText:SetFontName(kRowFontName)
	item.rightText:SetColor(textColor)
	item.rightText:SetInheritsParentAlpha(true)
	item.rightText:SetScale(scaledVector)
	item.rightText:SetAnchor(GUIItem.Right, GUIItem.Center)
	item.rightText:SetTextAlignmentX(GUIItem.Align_Max)
	item.rightText:SetTextAlignmentY(GUIItem.Align_Center)
	item.rightText:SetPosition(Vector(-GUILinearScale(5), 0, 0))
	item.rightText:SetText(rightText or "")
	item.rightText:SetLayer(kGUILayerMainMenu)
	item.background:AddChild(item.rightText)
end

function CHUDGUI_DeathStats:Reset()

	GUIAnimatedScript.Reset(self)

end

function CHUDGUI_DeathStats:Update(deltaTime)

	GUIAnimatedScript.Update(self, deltaTime)

	local displayTime = 8
	
	local isDead = PlayerUI_GetIsDead() and Client.GetIsControllingPlayer() and not PlayerUI_GetIsSpecating()
	
	// Hide the stats when you're alive
	// When getting beaconed right after dying you could still see the UI
	// Also makes training with cheats in a private server not horrible
	local visible = (not Client.GetIsControllingPlayer() or PlayerUI_GetIsThirdperson() or isDead)
	self.titleBackground:SetIsVisible((self.requestVisible or visible and CHUDGetOption("deathstats") == 2) and not PlayerUI_IsOverhead())
	local binding = BindingsUI_GetInputValue("RequestMenu")
	// Lazy mode: Engaged
	if not visible or CHUDGetOption("deathstats") < 2 or binding == "None" then
		self.actionIconGUI:Hide()
	end
	
	if Shared.GetTime() - lastStatsMsg > displayTime and visible and not self.fading then
		self.fading = true
		self.actionIconGUI:Hide()
		self.titleBackground:FadeOut(2, "CHUD_DEATHSTATS_FADEOUT")
	end

	if self.titleBackground:GetColor().a > 0 then
		CHUDStatsVisible = true
	else
		CHUDStatsVisible = false
	end
	
	if CHUDEndStatsVisible then
		self.titleBackground:SetIsVisible(false)
		self.actionIconGUI:Hide()
	end

end

function CHUDGUI_DeathStats:SendKeyEvent(key, down)

	// Force show when request menu is open
	if GetIsBinding(key, "RequestMenu") and CHUDGetOption("deathstats") > 0 and not CHUDEndStatsVisible and (Client.GetLocalPlayer():GetTeamNumber() == kTeam1Index or Client.GetLocalPlayer():GetTeamNumber() == kTeam2Index) and not ChatUI_EnteringChatMessage() and not MainMenu_GetIsOpened() and not PlayerUI_IsOverhead() then
		self.titleBackground:SetIsVisible(down)
		self.requestVisible = down
		local color = self.titleBackground:GetColor()
		self.titleBackground:SetColor(Color(color.r, color.g, color.b, ConditionalValue(down and statsTable ~= nil, 0.8, 0)))
	end
	
end

function CHUDGUI_DeathStats:Uninitialize()

	GUIAnimatedScript.Uninitialize(self)
	
	GUI.DestroyItem(self.titleBackground)
	self.titleBackground = nil
	
	GetGUIManager():DestroyGUIScript(self.actionIconGUI)
	self.actionIconGUI = nil
	
end

function CHUDGUI_DeathStats:ResetTableBackground()
	if self.tableBackground then
		GUI.DestroyItem(self.tableBackground)
		self.tableBackground = nil
	end
	
	self.tableBackground = GUIManager:CreateGraphicItem()
	self.tableBackground:SetInheritsParentAlpha(true)
	self.tableBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
	self.tableBackground:SetPosition(Vector(-(kRowSize.x+kRowBorderSize*2)/2, -kTableContainerOffset, 0))
	self.tableBackground:SetLayer(kGUILayerMainMenu)
	self.tableBackground:SetSize(Vector(kRowSize.x + kRowBorderSize*2, kRowBorderSize*2, 0))
	self.titleBackground:AddChild(self.tableBackground)
	
	local parentColor = self.tableBackground:GetParent():GetColor()
	parentColor.a = 1
	
	self.tableBackground:SetColor(parentColor)
end

function CHUDGUI_DeathStats:SetStats()
	
	if statsTable ~= nil then
		self.titleBackground:SetColor(Color(statsTable.color.r, statsTable.color.g, statsTable.color.b, 0))
		local color = self.titleBackground:GetColor()
		color.a = 1
		self.titleBackgroundLeft:SetColor(color)
		self.titleBackgroundRight:SetColor(color)
	end
	
	self:ResetTableBackground()
	
	if statsTable ~= nil then
		self:AddRow("Last life accuracy", printNum(statsTable.lastAcc) .. "%", kStatsOddColor, Color(1,1,1,1))
		self:AddRow("Player damage", printNum(statsTable.pdmg), kStatsEvenColor, Color(1,1,1,1))
		self:AddRow("Structure damage", printNum(statsTable.sdmg), kStatsOddColor, Color(1,1,1,1))
		self:AddRow("", "", Color(0,0,0,0), Color(1,1,1,1))
		self:AddRow("Current accuracy", printNum(statsTable.currentAcc) .. "%", kStatsEvenColor, Color(1,1,1,1))
	end
	
end

local function CHUDGetStatsString(message)

	if message then
		statsTable = message
		statsTable.color = ConditionalValue(Client.GetLocalPlayer():GetTeamNumber() == kTeam1Index, kMarineStatsColor, kAlienStatsColor)
		
		gStatsUI:SetStats()
		
		gStatsUI.titleBackground:SetColor(ConditionalValue(Client.GetLocalPlayer():GetTeamNumber() == kTeam1Index, kMarineStatsColor, kAlienStatsColor), 2, "CHUD_DEATHSTATS")
		gStatsUI.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("RequestMenu"), nil, "Last life stats", nil)
		gStatsUI.actionIconGUI:SetColor(ConditionalValue(Client.GetLocalPlayer():GetTeamNumber() == kTeam1Index, kMarineFontColor, kAlienFontColor))
		gStatsUI.fading = false
	end

	lastStatsMsg = Shared.GetTime()
end

local originalAlienSpecUpdate
originalAlienSpecUpdate = Class_ReplaceMethod( "GUIAlienSpectatorHUD", "Update",
	function(self, deltaTime)
		originalAlienSpecUpdate(self, deltaTime)
		self.eggIcon:SetIsVisible(self.eggIcon:GetIsVisible() and not CHUDStatsVisible)
	end)
		
local originalBalanceUpdate
originalBalanceUpdate = Class_ReplaceMethod( "GUIWaitingForAutoTeamBalance", "Update",
	function(self, deltaTime)
		self.waitingText:SetIsVisible(PlayerUI_GetIsWaitingForTeamBalance() and not CHUDStatsVisible)
	end)

Client.HookNetworkMessage("CHUDDeathStats", CHUDGetStatsString)