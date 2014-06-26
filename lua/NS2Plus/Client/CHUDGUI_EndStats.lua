Script.Load("lua/GUIAnimatedScript.lua")

class 'CHUDGUI_EndStats' (GUIAnimatedScript)

local gStatsUI
local lastStatsMsg = 0
local shownTime = 0
local kStatsAppendTime = 15
local accuracyString = ""

local kTitleFontName = "fonts/AgencyFB_medium.fnt"
local kStatsFontName = "fonts/AgencyFB_small.fnt"
local kTopOffset = GUIScale(32)
local kFontScale = GUIScale(Vector(1, 1, 0))
local kTitleBackgroundTexture = "ui/objective_banner_marine.dds"
local kTitleBackgroundSize = GUIScale(Vector(210, 45, 0))

function CHUDGUI_EndStats:Initialize()

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
	self.titleShadow:SetText("Last round stats")
	self.titleShadow:SetColor(Color(0, 0, 0, 1))
	self.titleShadow:SetScale(kFontScale)
	self.titleShadow:SetInheritsParentAlpha(true)
	self.titleBackground:AddChild(self.titleShadow)
	
	self.titleText = GetGUIManager():CreateTextItem()
	self.titleText:SetFontName(kTitleFontName)
	self.titleText:SetTextAlignmentX(GUIItem.Align_Center)
	self.titleText:SetTextAlignmentY(GUIItem.Align_Center)
	self.titleText:SetPosition(GUIScale(Vector(-2, -2, 0)))
	self.titleText:SetText("Last round stats")
	self.titleText:SetScale(kFontScale)
	self.titleText:SetInheritsParentAlpha(true)
	self.titleShadow:AddChild(self.titleText)
	
	self.statsText = GetGUIManager():CreateTextItem()
	self.statsText:SetFontName(kStatsFontName)
	self.statsText:SetAnchor(GUIItem.Center, GUIItem.Top)
	self.statsText:SetTextAlignmentX(GUIItem.Align_Center)
	self.statsText:SetPosition(GUIScale(Vector(10, 45, 0)))
	self.statsText:SetScale(kFontScale)
	self.statsText:SetInheritsParentAlpha(true)
	self.statsText:SetText("")
	self.titleBackground:AddChild(self.statsText)
	
	self.overallText = GetGUIManager():CreateTextItem()
	self.overallText:SetFontName(kStatsFontName)
	self.overallText:SetAnchor(GUIItem.Center, GUIItem.Bottom)
	self.overallText:SetTextAlignmentX(GUIItem.Align_Center)
	self.overallText:SetScale(kFontScale)
	self.overallText:SetInheritsParentAlpha(true)
	self.overallText:SetText("")
	self.statsText:AddChild(self.overallText)
	
	self.actionIconGUI = GetGUIManager():CreateGUIScript("GUIActionIcon")
	self.actionIconGUI:SetColor(kWhite)
	self.actionIconGUI.pickupIcon:SetLayer(kGUILayerPlayerHUD)
	
	self.showing = false
	self.fading = false
	
	self.requestVisible = false
	
	gStatsUI = self
end

function CHUDGUI_EndStats:Reset()

	GUIAnimatedScript.Reset(self)

end

function CHUDGUI_EndStats:Update(deltaTime)

	GUIAnimatedScript.Update(self, deltaTime)

	local displayTime = 8
	
	if Client.GetLocalPlayer():GetTeamNumber() == kTeamReadyRoom and self.statsText:GetText() ~= "" and self.showing == false and CHUDGetOption("deathstats") > 1 then
		self.showing = true
		shownTime = Shared.GetTime()
		self.titleBackground:FadeIn(2, "CHUD_ENDSTATS")
		self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("RequestMenu"), nil, "Last round stats", nil)
		self.fading = false
	elseif Shared.GetTime() - shownTime > displayTime and not self.fading then
		self.fading = true
		self.actionIconGUI:Hide()
		self.titleBackground:FadeOut(2, "CHUD_ENDSTATS")
	end

end

function CHUDGUI_EndStats:SendKeyEvent(key, down)

	// Force show when request menu is open
	if GetIsBinding(key, "RequestMenu") and CHUDGetOption("deathstats") > 0 and Client.GetLocalPlayer():GetTeamNumber() == kTeamReadyRoom then
		self.titleBackground:SetIsVisible(down)
		self.requestVisible = down
		self.titleBackground:SetColor(Color(1, 1, 1, ConditionalValue(down and self.statsText:GetText() ~= "", 1, 0)))
	end
	
end

function CHUDGUI_EndStats:Uninitialize()

	GUIAnimatedScript.Uninitialize(self)

	GUI.DestroyItem(self.titleBackground)
	self.titleBackground = nil
	
	GetGUIManager():DestroyGUIScript(self.actionIconGUI)
	self.actionIconGUI = nil
	
end

local function CHUDSetAccuracyString(message)
	
	local weaponName
	
	local wTechId = message.wTechId

	if message.wTechId > 1 then
		local techdataName = LookupTechData(wTechId, kTechDataMapName) or string.lower(LookupTechData(wTechId, kTechDataDisplayName))
		weaponName = techdataName:gsub("^%l", string.upper)
	else
		weaponName = "Others"
	end
	
	// Lerk's bite is called "Bite", just like the skulk bite, so clarify this
	if wTechId == kTechId.LerkBite then
		weaponName = "Lerk Bite"
	// This shows up as "Swipe Blink", just "Swipe"
	elseif wTechId == kTechId.Swipe then
		weaponName = "Swipe"
	// Use spaces!
	elseif rawget( kTechId, "HeavyMachineGun" ) and wTechId == kTechId.HeavyMachineGun then
		weaponName = "Heavy Machine Gun"
	end

	accuracyString = ConditionalValue(
		lastStatsMsg + kStatsAppendTime > Shared.GetTime(),
		accuracyString, "") .. string.format("%s accuracy: %.2f%%", weaponName, message.accuracy)
	
	if message.accuracyOnos > -1 then
		accuracyString = accuracyString .. string.format(" / Without Onos hits: %.2f%%", message.accuracyOnos)
	end
	
	accuracyString = accuracyString .. "\n"

	gStatsUI.statsText:SetText(accuracyString)
	gStatsUI.overallText:SetPosition(Vector(-gStatsUI.statsText:GetTextWidth(accuracyString)/2, GUIScale(10), 0))
	lastStatsMsg = Shared.GetTime()
end

local function CHUDSetOverallString(message)
	
	local finalStatsString = string.format("Overall accuracy: %.2f%%", message.accuracy)
	
	if message.accuracyOnos > -1 then
		finalStatsString = finalStatsString .. string.format("\nWithout Onos hits: %.2f%%", message.accuracyOnos)
	end
	
	finalStatsString = finalStatsString .. string.format("\nPlayer damage: %.2f\nStructure damage: %.2f", message.pdmg, message.sdmg)

	gStatsUI.overallText:SetText(finalStatsString)
	gStatsUI.showing = false
end

Client.HookNetworkMessage("CHUDEndStatsWeapon", CHUDSetAccuracyString)
Client.HookNetworkMessage("CHUDEndStatsOverall", CHUDSetOverallString)