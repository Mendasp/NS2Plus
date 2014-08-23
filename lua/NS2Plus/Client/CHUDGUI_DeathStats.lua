Script.Load("lua/GUIAnimatedScript.lua")

class 'CHUDGUI_DeathStats' (GUIAnimatedScript)

CHUDStatsVisible = false

local gStatsUI
local lastStatsMsg = 0

local kTitleFontName = Fonts.kAgencyFB_Medium
local kStatsFontName = Fonts.kAgencyFB_Small
local kTopOffset = GUIScale(96)
local kFontScale = GUIScale(Vector(1, 1, 0))
local kTitleBackgroundTexture = PrecacheAsset("ui/objective_banner_marine.dds")
local kTitleBackgroundSize = GUIScale(Vector(210, 45, 0))

function CHUDGUI_DeathStats:Initialize()

	GUIAnimatedScript.Initialize(self)

	self.titleBackground = self:CreateAnimatedGraphicItem()
	self.titleBackground:SetTexture(kTitleBackgroundTexture)
	self.titleBackground:SetIsScaling(false)
	self.titleBackground:SetColor(Color(1, 1, 1, 0))
	self.titleBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
	self.titleBackground:SetPosition(Vector(-kTitleBackgroundSize.x/2, kTopOffset, 0))
	self.titleBackground:SetSize(kTitleBackgroundSize)
	self.titleBackground:SetLayer(kGUILayerPlayerHUD)
	
	self.titleShadow = GetGUIManager():CreateTextItem()
	self.titleShadow:SetFontName(kTitleFontName)
	self.titleShadow:SetAnchor(GUIItem.Middle, GUIItem.Middle)
	self.titleShadow:SetTextAlignmentX(GUIItem.Align_Center)
	self.titleShadow:SetTextAlignmentY(GUIItem.Align_Center)
	self.titleShadow:SetPosition(GUIScale(Vector(0, 3, 0)))
	self.titleShadow:SetText("Last life stats")
	self.titleShadow:SetColor(Color(0, 0, 0, 1))
	self.titleShadow:SetScale(kFontScale)
	self.titleShadow:SetInheritsParentAlpha(true)
	self.titleBackground:AddChild(self.titleShadow)
	
	self.titleText = GetGUIManager():CreateTextItem()
	self.titleText:SetFontName(kTitleFontName)
	self.titleText:SetTextAlignmentX(GUIItem.Align_Center)
	self.titleText:SetTextAlignmentY(GUIItem.Align_Center)
	self.titleText:SetPosition(GUIScale(Vector(-2, -2, 0)))
	self.titleText:SetText("Last life stats")
	self.titleText:SetScale(kFontScale)
	self.titleText:SetInheritsParentAlpha(true)
	self.titleShadow:AddChild(self.titleText)
	
	self.statsText = GetGUIManager():CreateTextItem()
	self.statsText:SetFontName(kStatsFontName)
    self.statsText:SetAnchor(GUIItem.Left, GUIItem.Top)
	self.statsText:SetPosition(GUIScale(Vector(10, 45, 0)))
	self.statsText:SetScale(kFontScale)
	self.statsText:SetInheritsParentAlpha(true)
	self.statsText:SetText("")
	self.titleBackground:AddChild(self.statsText)
	
	self.actionIconGUI = GetGUIManager():CreateGUIScript("GUIActionIcon")
	self.actionIconGUI.pickupIcon:SetLayer(kGUILayerPlayerHUD)
	
	self.fading = false
	
	self.requestVisible = false
	
	gStatsUI = self
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
	local visible = not Client.GetIsControllingPlayer() or PlayerUI_GetIsThirdperson() or isDead
	self.titleBackground:SetIsVisible(self.requestVisible or visible and CHUDGetOption("deathstats") == 2)
	local binding = BindingsUI_GetInputValue("RequestMenu")
	// Lazy mode: Engaged
	if not visible or CHUDGetOption("deathstats") < 2 or binding == "None" then
		self.actionIconGUI:Hide()
	end
	
	if Shared.GetTime() - lastStatsMsg > displayTime and visible and not self.fading then
		self.fading = true
		self.actionIconGUI:Hide()
		self.titleBackground:FadeOut(2, "CHUD_DEATHSTATS")
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
		self.titleBackground:SetColor(Color(1, 1, 1, ConditionalValue(down and self.statsText:GetText() ~= "", 1, 0)))
	end
	
end

function CHUDGUI_DeathStats:Uninitialize()

	GUIAnimatedScript.Uninitialize(self)

	GUI.DestroyItem(self.titleBackground)
	self.titleBackground = nil
	
	GetGUIManager():DestroyGUIScript(self.actionIconGUI)
	self.actionIconGUI = nil
	
end

local function CHUDGetStatsString(message)
	local statsString = ""

	if message then
		statsString = statsString .. string.format("Last life accuracy: %.2f%%\n", message.lastAcc)
		statsString = statsString .. string.format("Player damage: %d\nStructure damage: %d\n\n", math.ceil(message.pdmg), math.ceil(message.sdmg))
		statsString = statsString .. string.format("Current accuracy: %.2f%%\n", message.currentAcc)
	end

	gStatsUI.statsText:SetText(statsString)
	gStatsUI.titleBackground:FadeIn(2, "CHUD_DEATHSTATS")
	gStatsUI.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("RequestMenu"), nil, "Last life stats", nil)
	gStatsUI.actionIconGUI:SetColor(ConditionalValue(Client.GetLocalPlayer():GetTeamNumber() == kTeam1Index, kMarineFontColor, kAlienFontColor))
	gStatsUI.fading = false
	lastStatsMsg = Shared.GetTime()
end

local originalAlienSpecUpdate
originalAlienSpecUpdate = Class_ReplaceMethod( "GUIAlienSpectatorHUD", "Update",
	function(self, deltaTime)
		originalAlienSpecUpdate(self, deltaTime)
		self.eggIcon:SetIsVisible(self.eggIcon:GetIsVisible() and not CHUDStatsVisible and not CHUDEndStatsVisible)
	end)
		
local originalBalanceUpdate
originalBalanceUpdate = Class_ReplaceMethod( "GUIWaitingForAutoTeamBalance", "Update",
	function(self, deltaTime)
		self.waitingText:SetIsVisible(PlayerUI_GetIsWaitingForTeamBalance() and not CHUDStatsVisible and not CHUDEndStatsVisible)
	end)

Client.HookNetworkMessage("CHUDDeathStats", CHUDGetStatsString)