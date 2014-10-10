Script.Load("lua/GUIAnimatedScript.lua")

class 'CHUDGUI_EndStats' (GUIAnimatedScript)

CHUDEndStatsVisible = false

local gStatsUI
local lastStatsMsg = 0
local appendTime = 2.5
local shownTime = 0
local displayTime = 15
local hasText = false
local loadedLastRound = false
local lastRoundFile = "config://NS2Plus/LastRoundStats.json"

local kTitleFontName = Fonts.kAgencyFB_Medium
local kStatsFontName = Fonts.kAgencyFB_Small
local kTopOffset = GUIScale(32)
local kTitleBackgroundTexture = PrecacheAsset("ui/objective_banner_marine.dds")

local function AddString(self, string, isComm, isVisible)
	
	if Shared.GetTime() > lastStatsMsg + appendTime and isVisible then
		GUI.DestroyItem(self.titleBackground)

		self:Uninitialize()
		self:Initialize()
	end
	
	local stringUI = self:CreateAnimatedTextItem()
	stringUI:SetFontName(kStatsFontName)
	stringUI:SetAnchor(GUIItem.Center, GUIItem.Top)
	stringUI:SetTextAlignmentX(GUIItem.Align_Center)
	stringUI:SetScale(GetScaledVector())
	stringUI:SetInheritsParentAlpha(true)
	stringUI:SetText(string)
	self.titleBackground:AddChild(stringUI)
	
	table.insert(ConditionalValue(isComm, self.commStringsTable, self.stringsTable), stringUI)
	
	// Reposition everything on new strings
	local yCoord = GUIScale(self.titleBackground:GetSize().y) + GUIScale(5)
	if isComm then
		local totalSize = 0
		for _, textItem in pairs(self.commStringsTable) do
			totalSize = totalSize + textItem:GetTextWidth(textItem:GetText())
		end
		
		local pos = 0
		local xSpacing = GUIScale(10)
		totalSize = totalSize + (xSpacing * #self.commStringsTable)
		
		for _, textItem in ipairs(self.commStringsTable) do
			local textItemSize = textItem:GetTextWidth(textItem:GetText())
			local xCoord = -(totalSize/2) + (textItemSize/2) + pos
			pos = pos + textItemSize/2 + xSpacing
			totalSize = totalSize - textItemSize
			textItem:SetPosition(Vector(GUIScale(xCoord), yCoord, 0))
		end
	else
		local biggest = 0
		for _, textItem in pairs(self.commStringsTable) do
			local textItemSize = textItem:GetTextHeight(textItem:GetText())
			if textItemSize > biggest then biggest = textItemSize end
		end
		
		if #self.commStringsTable > 0 then
			yCoord = yCoord + GUIScale(biggest) + GUIScale(5)
		end
		
		for i, textItem in ipairs(self.stringsTable) do
			textItem:SetPosition(Vector(0, yCoord, 0))
			yCoord = yCoord + GUIScale(textItem:GetTextHeight(textItem:GetText()))
		end
	end
	
	lastStatsMsg = Shared.GetTime()
	if isVisible then
		gStatsUI.showing = false
	end
end

function CHUDGUI_EndStats:Initialize()

	GUIAnimatedScript.Initialize(self)

	self.titleBackground = self:CreateAnimatedGraphicItem()
	self.titleBackground:SetTexture(kTitleBackgroundTexture)
	self.titleBackground:SetTexturePixelCoordinates(0, 0, 1024, 64)
	self.titleBackground:SetColor(Color(1, 1, 1, 0))
	self.titleBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
	self.titleBackground:SetScale(GetScaledVector())
	self.titleBackground:SetLayer(kGUILayerPlayerHUD)
	self.titleBackground:SetIsVisible(false)
	
	self.titleShadow = self:CreateAnimatedTextItem()
	self.titleShadow:SetFontName(kTitleFontName)
	self.titleShadow:SetAnchor(GUIItem.Middle, GUIItem.Middle)
	self.titleShadow:SetTextAlignmentX(GUIItem.Align_Center)
	self.titleShadow:SetTextAlignmentY(GUIItem.Align_Center)
	self.titleShadow:SetPosition(GUIScale(Vector(0, 3, 0)))
	self.titleShadow:SetText("Last round stats")
	self.titleShadow:SetColor(Color(0, 0, 0, 1))
	self.titleShadow:SetScale(GetScaledVector())
	self.titleShadow:SetInheritsParentAlpha(true)
	self.titleBackground:AddChild(self.titleShadow)
	
	self.titleText = self:CreateAnimatedTextItem()
	self.titleText:SetFontName(kTitleFontName)
	self.titleText:SetTextAlignmentX(GUIItem.Align_Center)
	self.titleText:SetTextAlignmentY(GUIItem.Align_Center)
	self.titleText:SetPosition(GUIScale(Vector(-2, -2, 0)))
	self.titleText:SetText("Last round stats")
	self.titleText:SetScale(GetScaledVector())
	self.titleText:SetInheritsParentAlpha(true)
	self.titleShadow:AddChild(self.titleText)
	
	self.titleBackground:SetSize(Vector(self.titleText:GetTextWidth(self.titleText:GetText())+40, self.titleText:GetTextHeight(self.titleText:GetText())+10, 0))
	self.titleBackground:SetPosition(Vector(-self.titleBackground:GetSize().x/2, kTopOffset, 0))
	
	self.stringsTable = {}
	self.commStringsTable = {}
	
	self.saved = false
	
	if not loadedLastRound then
		local openedFile = io.open(lastRoundFile, "r")
		if openedFile then
		
			local parsedFile = json.decode(openedFile:read("*all"))
			io.close(openedFile)
			
			if parsedFile then
				for _, string in ipairs(parsedFile.commStringsTable) do
					AddString(self, string, true, false)
				end
				
				for _, string in ipairs(parsedFile.stringsTable) do
					AddString(self, string, false, false)
				end
			end
			
			self.saved = true
			
			loadedLastRound = true
		end
	end
	
	self.actionIconGUI = GetGUIManager():CreateGUIScript("GUIActionIcon")
	self.actionIconGUI:SetColor(kWhite)
	self.actionIconGUI.pickupIcon:SetLayer(kGUILayerPlayerHUD)
	
	self.showing = true
	self.fading = true
	self.prevKeyStatus = false
	
	gStatsUI = self
end

function CHUDGUI_EndStats:Reset()

	GUIAnimatedScript.Reset(self)

end

function CHUDGUI_EndStats:Update(deltaTime)

	GUIAnimatedScript.Update(self, deltaTime)
	
	hasText = #self.stringsTable > 0 or #self.commStringsTable > 0
	
	if PlayerUI_GetHasGameStarted() and Client.GetLocalPlayer():GetTeamNumber() ~= kTeamReadyRoom then
		self.titleBackground:SetIsVisible(false)
		self.actionIconGUI:Hide()
	end
	
	if self.titleBackground:GetColor().a > 0 and hasText then
		CHUDEndStatsVisible = true
	else
		CHUDEndStatsVisible = false
	end
	
	if not PlayerUI_GetHasGameStarted() and hasText and self.showing == false and CHUDGetOption("deathstats") > 1 then
		self.showing = true
		shownTime = Shared.GetTime()
		self.titleBackground:SetIsVisible(true)
		self.titleBackground:FadeIn(2, "CHUD_ENDSTATS")
		self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("RequestMenu"), nil, "Last round stats", nil)
		self.fading = false
	else
		-- Save the stats to a file when we can't append more strings
		if Shared.GetTime() - shownTime > appendTime and not self.saved then
			local statsTable = {}
			statsTable.stringsTable = {}
			statsTable.commStringsTable = {}
			for _, textItem in ipairs(self.commStringsTable) do
				table.insert(statsTable.commStringsTable, textItem:GetText())
			end
			for _, textItem in ipairs(self.stringsTable) do
				table.insert(statsTable.stringsTable, textItem:GetText())
			end
			
			local savedFile = io.open(lastRoundFile, "w+")
			if savedFile then
				savedFile:write(json.encode(statsTable))
				io.close(savedFile)
			end
			self.saved = true
		end
		
		if Shared.GetTime() - shownTime > displayTime and not self.fading then
			self.fading = true
			self.actionIconGUI:Hide()
			self.titleBackground:FadeOut(2, "CHUD_ENDSTATS")
		end
	end

end

function CHUDGUI_EndStats:SendKeyEvent(key, down)

	// Good news! The game seems to correctly block the held down status when console is open but
	// IT STILL REPORTS THE RELEASE OF THE KEY WHICH IS WHAT WE WERE USING:D
	// So let's save the previous state and compare with current so we show only when appropriate

	// Force show when request menu is open
	if GetIsBinding(key, "RequestMenu") and CHUDGetOption("deathstats") > 0 and (not PlayerUI_GetHasGameStarted() or Client.GetLocalPlayer():GetTeamNumber() == kTeamReadyRoom) and not ChatUI_EnteringChatMessage() and not MainMenu_GetIsOpened() and self.prevKeyStatus ~= down then
		
		self.prevKeyStatus = down
		if not down then
			self.titleBackground:SetIsVisible(not self.titleBackground:GetIsVisible())
			self.titleBackground:SetColor(Color(1, 1, 1, ConditionalValue(self.titleBackground:GetIsVisible() and hasText, 1, 0)))
		end
		
	end
	
end

function CHUDGUI_EndStats:Uninitialize()

	GUIAnimatedScript.Uninitialize(self)

	GUI.DestroyItem(self.titleBackground)
	self.titleBackground = nil

	GetGUIManager():DestroyGUIScript(self.actionIconGUI)
	self.actionIconGUI = nil
	
	self.stringsTable = {}
	self.commStringsTable = {}
	
end

local function CHUDSetAccuracyString(message)
	
	local weaponName
	
	local wTechId = message.wTechId

	local kFriendlyWeaponNames = { }
	kFriendlyWeaponNames[kTechId.LerkBite] = "Lerk Bite"
	kFriendlyWeaponNames[kTechId.Swipe] = "Swipe"
	kFriendlyWeaponNames[kTechId.Spit] = "Spit"
	kFriendlyWeaponNames[kTechId.Spray] = "Spray"
	kFriendlyWeaponNames[kTechId.GrenadeLauncher] = "Grenade Launcher"
	if rawget( kTechId, "HeavyMachineGun" ) then
		kFriendlyWeaponNames[kTechId.HeavyMachineGun] = "Heavy Machine Gun"
	end
	
	if message.wTechId > 1 and message.wTechId ~= kTechId.None then
		if kFriendlyWeaponNames[message.wTechId] then
			weaponName = kFriendlyWeaponNames[message.wTechId]
		else
			local techdataName = LookupTechData(wTechId, kTechDataMapName) or Locale.ResolveString(LookupTechData(wTechId, kTechDataDisplayName))
			weaponName = techdataName:gsub("^%l", string.upper)
		end
	else
		weaponName = "Others"
	end

	local accuracyString = string.format("%s - Kills: %d", weaponName, message.kills)
	if message.accuracy > 0 then
		accuracyString = accuracyString .. string.format(" - Accuracy: %.2f%%", message.accuracy)
	end
	
	if message.accuracyOnos > -1 then
		accuracyString = accuracyString .. string.format(" / Without Onos hits: %.2f%%", message.accuracyOnos)
	end

	AddString(gStatsUI, accuracyString, false, true)
end

local function CHUDSetOverallString(message)
	
	if message.medpackAccuracy then
		
		if message.medpackResUsed + message.medpackResExpired > 0 then
			local finalStatsString = string.format("Medpack accuracy: %.2f%%", message.medpackAccuracy)
			finalStatsString = finalStatsString .. string.format("\nAmount healed: %d", message.medpackRefill)
			finalStatsString = finalStatsString .. string.format("\nRes spent on used medpacks: %d", message.medpackResUsed)
			finalStatsString = finalStatsString .. string.format("\nRes spent on expired medpacks: %d", message.medpackResExpired)
			finalStatsString = finalStatsString .. string.format("\nRes efficiency: %.2f%%", message.medpackEfficiency)
			
			AddString(gStatsUI, finalStatsString, true, true)
		end
		
		if message.ammopackResUsed + message.ammopackResExpired > 0 then
			local finalStatsString = string.format("Ammo refilled: %d", message.ammopackRefill)
			finalStatsString = finalStatsString .. string.format("\nRes spent on used ammopacks: %d", message.ammopackResUsed)
			finalStatsString = finalStatsString .. string.format("\nRes spent on expired ammopacks: %d", message.ammopackResExpired)
			finalStatsString = finalStatsString .. string.format("\nRes efficiency: %.2f%%", message.ammopackEfficiency)
			
			AddString(gStatsUI, finalStatsString, true, true)
		end
		
		if message.catpackResUsed + message.catpackResExpired > 0 then
			local finalStatsString = string.format("Res spent on used catpacks: %d", message.catpackResUsed)
			finalStatsString = finalStatsString .. string.format("\nRes spent on expired catpacks: %d", message.catpackResExpired)
			finalStatsString = finalStatsString .. string.format("\nRes efficiency: %.2f%%", message.catpackEfficiency)
			
			AddString(gStatsUI, finalStatsString, true, true)
		end
		
	elseif message.accuracy then
		
		local finalStatsString = string.format("\nOverall accuracy: %.2f%%", message.accuracy)
		
		if message.accuracyOnos > -1 then
			finalStatsString = finalStatsString .. string.format("\nWithout Onos hits: %.2f%%", message.accuracyOnos)
		end
		
		finalStatsString = finalStatsString .. string.format("\nPlayer damage: %.2f\nStructure damage: %.2f", message.pdmg, message.sdmg)
		
		if message.killstreak >= 5 then
			finalStatsString = finalStatsString .. string.format("\nLongest killstreak: %d kills", message.killstreak)
		end
		
		if message.minutesBuilding > 0 then
			local minutes = math.floor(message.minutesBuilding)
			local seconds = (message.minutesBuilding % 1)*60
			finalStatsString = finalStatsString .. string.format("\nTime building: %d:%02d", minutes, seconds)
		end
		
		AddString(gStatsUI, finalStatsString, false, true)

	end

end

local function CHUDPlayerStatsString(message)
	
	if message and CHUDGetOption("deathstats") > 0 then
		local minutes = math.floor(message.minutesBuilding)
		local seconds = (message.minutesBuilding % 1)*60
		
		Shared.Message(string.format("(%s) %s - %d/%d/%d - %.2f - %.2f / %.2f - %d:%02d",
			message.isMarine and "M" or "A", message.playerName, message.kills, message.assists, message.deaths, message.accuracy, message.pdmg, message.sdmg, minutes, seconds))
	end

end

Client.HookNetworkMessage("CHUDEndStatsWeapon", CHUDSetAccuracyString)
Client.HookNetworkMessage("CHUDEndStatsOverall", CHUDSetOverallString)
Client.HookNetworkMessage("CHUDMarineCommStats", CHUDSetOverallString)
Client.HookNetworkMessage("CHUDPlayerStats", CHUDPlayerStatsString)