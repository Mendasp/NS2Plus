local kBlipColorType 	= GetUpValue( GUIMinimap.Initialize,   "kBlipColorType", 		{ LocateRecurse = true } )
local kStaticBlipsLayer = GetUpValue( GUIMinimap.Initialize,   "kStaticBlipsLayer", 	{ LocateRecurse = true } )
local kBlipSize 		= GetUpValue( GUIMinimap.SetBlipScale, "kBlipSize", 			{ LocateRecurse = true } )
local kBlipSizeType 	= GetUpValue( GUIMinimap.Initialize,   "kBlipSizeType", 		{ LocateRecurse = true } )
local kBlipInfo 		= GetUpValue( GUIMinimap.Initialize,   "kBlipInfo", 			{ LocateRecurse = true } )

AppendToEnum( kBlipSizeType, "UnpoweredPowerPoint" )
kBlipInfo[kMinimapBlipType.UnsocketedPowerPoint] = { kBlipColorType.FullColor, kBlipSizeType.UnpoweredPowerPoint, kStaticBlipsLayer, "UnsocketedPowerPoint" }
kBlipInfo[kMinimapBlipType.BlueprintPowerPoint] = { kBlipColorType.Team, kBlipSizeType.UnpoweredPowerPoint, kStaticBlipsLayer, "UnsocketedPowerPoint" }


Class_AddMethod("GUIMinimap", "UpdateCHUDCommSettings",
	function(self)
		local player = Client.GetLocalPlayer()
		if player:isa("Commander") then
			local mingui = not CHUDGetOption("mingui")
		
			local selectionPanelScript = GetGUIManager():GetGUIScriptSingle("GUISelectionPanel")
			local minimapButtons = GetGUIManager():GetGUIScriptSingle("GUIMinimapButtons")
			local resourceDisplay = GetGUIManager():GetGUIScriptSingle("GUIResourceDisplay")
			local logoutScript = GetGUIManager():GetGUIScriptSingle("GUICommanderLogout")
			local commanderTooltip = GetGUIManager():GetGUIScriptSingle("GUICommanderTooltip")
			local minimapFrame = ClientUI.GetScript("GUIMinimapFrame")
			
			// Move buttons off-screen so we can click through
			local buttonPos = ConditionalValue(mingui, 0, -9999)
			minimapButtons.background:SetIsVisible(mingui)
			minimapButtons.pingButton:SetPosition(Vector(buttonPos,0,0))
			minimapButtons.techMapButton:SetPosition(Vector(buttonPos,0,0))
			
			if player:isa("MarineCommander") then
				local frameTexture = ConditionalValue(mingui, "ui/marine_commander_textures.dds", "ui/transparent.dds")
				local buttonsTexture = ConditionalValue(mingui, GUICommanderButtonsMarines:GetBackgroundTextureName(), "ui/transparent.dds")
				local selectionTexture = ConditionalValue(mingui, GUISelectionPanel.kSelectionTextureMarines, "ui/transparent.dds")
				local logoutTexture = ConditionalValue(mingui, GUICommanderLogout.kLogoutMarineTextureName, "ui/transparent.dds")
				local tooltipTexture = ConditionalValue(mingui, GUICommanderTooltip.kMarineBackgroundTexture, "ui/transparent.dds")
				
				minimapFrame.minimapFrame:SetTexture(frameTexture)
				minimapFrame.buttonsScript.background:SetTexture(buttonsTexture)
				selectionPanelScript.background:SetTexture(selectionTexture)
				logoutScript.background:SetTexture(logoutTexture)
				commanderTooltip.backgroundTop:SetTexture(tooltipTexture)
				commanderTooltip.backgroundCenter:SetTexture(tooltipTexture)
				commanderTooltip.backgroundBottom:SetTexture(tooltipTexture)
			elseif player:isa("AlienCommander") then
				local buttonsTexture = ConditionalValue(mingui, "ui/alien_commander_smkmask.dds", "ui/transparent.dds")
				local selectionTexture = ConditionalValue(mingui, "ui/alien_logout_smkmask.dds", "ui/transparent.dds")
				local smokeTexture = ConditionalValue(mingui, "ui/alien_minimap_smkmask.dds", "ui/transparent.dds")
				local resourceTexture = ConditionalValue(mingui, "ui/alien_ressources_smkmask.dds", "ui/transparent.dds")
				local logoutTexture = ConditionalValue(mingui, "ui/alien_logout_smkmask.dds", "ui/transparent.dds")
				local tooltipTexture = ConditionalValue(mingui, "ui/alien_logout_smkmask.dds", "ui/transparent.dds")

				minimapFrame.buttonsScript.smokeyBackground:SetTexture(buttonsTexture)
				selectionPanelScript.smokeyBackground:SetTexture(selectionTexture)
				minimapFrame.smokeyBackground:SetTexture(smokeTexture)
				resourceDisplay.smokeyBackground:SetTexture(resourceTexture)
				logoutScript.smokeyBackground:SetTexture(logoutTexture)
				commanderTooltip.smokeyBackground:SetTexture(tooltipTexture)
				
				local biomass = ClientUI.GetScript("GUIBioMassDisplay")
				local biomassTexture = ConditionalValue(mingui, "ui/biomass_bar.dds", "ui/transparent.dds")
				
				biomass.smokeyBackground:SetIsVisible(mingui)
				biomass.background:SetTexture(biomassTexture)
			end
		end
	end)

local minimapScript

local originalMinimapInit
originalMinimapInit = Class_ReplaceMethod( "GUIMinimap", "Initialize",
function(self)
	originalMinimapInit(self)
	
	self.minimap:SetColor(Color(1,1,1,CHUDGetOption("minimapalpha")))
	self.lastMinGUI = CHUDGetOption("mingui")
	
	local friends = CHUDGetOption("friends")
	ReplaceLocals(PlayerUI_GetStaticMapBlips, { kMinimapBlipTeamFriendAlien =
		ConditionalValue(friends, kMinimapBlipTeam.FriendAlien, kMinimapBlipTeam.Alien) } )
	ReplaceLocals(PlayerUI_GetStaticMapBlips, { kMinimapBlipTeamFriendMarine =
		ConditionalValue(friends, kMinimapBlipTeam.FriendMarine, kMinimapBlipTeam.Marine) } )
	
	minimapScript = self
end)
	
	
local originalCommanderInit
originalCommanderInit = Class_ReplaceMethod( "Commander", "OnInitLocalClient",
function(self)
	originalCommanderInit(self)
	
	minimapScript:UpdateCHUDCommSettings()
	
	self.gameTime = GUIManager:CreateTextItem()
	self.gameTime:SetFontName(GUIMarineHUD.kTextFontName)
	self.gameTime:SetFontIsBold(true)
	self.gameTime:SetLayer(kGUILayerPlayerHUDForeground2)
	self.gameTime:SetColor(Color(0.5, 0.5, 0.5, 1))
	self.gameTime:SetPosition(Vector(35, 60, 0))
end)

local originalCommanderUpdate
originalCommanderUpdate = Class_ReplaceMethod( "Commander", "UpdateMisc",
function(self, input)
	originalCommanderUpdate(self, input)
	
	if self.gameTime then
		self.gameTime:SetText(CHUDGetGameTime())
		self.gameTime:SetIsVisible(CHUDGetOption("gametime"))
	end
end)

local originalCommanderOnDestroy
originalCommanderOnDestroy = Class_ReplaceMethod( "Commander", "OnDestroy",
function(self)
	GUI.DestroyItem(self.gameTime)
	self.gameTime = nil
	originalCommanderOnDestroy(self)
end)

local originalMinimapUpdate
originalMinimapUpdate = Class_ReplaceMethod( "GUIMinimap", "Update",
function(self, deltaTime)
	originalMinimapUpdate(self, deltaTime)
	
	local mingui = CHUDGetOption("mingui")
	if self.lastMinGUI ~= mingui then
		self:UpdateCHUDCommSettings()
		self.lastMinGUI = mingui
	end

end)

local originalLocationNameInit
originalLocationNameInit = Class_ReplaceMethod( "GUIMinimap", "InitializeLocationNames",
	function(self)
		originalLocationNameInit(self)
		if self.locationItems ~= nil then
			for _, locationItem in ipairs(self.locationItems) do
				locationItem.text:SetColor( Color(1, 1, 1, CHUDGetOption("locationalpha")) )
			end

		end
	end)


local UpdateMinimapNames, kScanAnimDuration, PlotToMap, blipPos, blipRotation, OnSameMinimapBlipTeam, DrawMinimapNames, kHallucinationColor, MinimapBlipTeamIsActive, PulseRed, PulseDarkRed
local function NewUpdateStaticBlips(self, deltaTime)
	
	PROFILE("GUIMinimap:UpdateStaticBlips")
	
	local marinePlayers = set {
		kMinimapBlipType.Marine, kMinimapBlipType.JetpackMarine, kMinimapBlipType.Exo
	}
	local alienPlayers = set {
		kMinimapBlipType.Skulk, kMinimapBlipType.Gorge, kMinimapBlipType.Lerk, kMinimapBlipType.Fade, kMinimapBlipType.Onos, 
	}
	local powerPoints = set {
		kMinimapBlipType.BlueprintPowerPoint, kMinimapBlipType.UnsocketedPowerPoint, kMinimapBlipType.PowerPoint, kMinimapBlipType.DestroyedPowerPoint
	}
	
	local staticBlips = PlayerUI_GetStaticMapBlips()
	local blipItemCount = 10
	local numBlips = table.count(staticBlips) / blipItemCount
	
	local staticBlipItems = self.staticBlips
	// Hide unused static blip items.
	for i = numBlips + 1, self.inUseStaticBlipCount do
		staticBlipItems[i]:SetIsVisible(false)
	end
	
	// Create all of the blips we'll need.
	for i = #staticBlipItems, numBlips do
	
		local addedBlip = GUIManager:CreateGraphicItem()
		addedBlip:SetAnchor(GUIItem.Center, GUIItem.Middle)
		addedBlip:SetLayer(kStaticBlipsLayer)
		addedBlip:SetStencilFunc(self.stencilFunc)
		addedBlip:SetTexture(self.iconFileName)
		self.minimap:AddChild(addedBlip)
		table.insert(staticBlipItems, addedBlip)
		
	end
	
	// Make sure all blips we'll need are visible.
	for i = self.inUseStaticBlipCount + 1, numBlips do
		staticBlipItems[i]:SetIsVisible(true)
	end
	
	// Build Player Name Text elements	
	largeMapIsVisible, shouldShowPlayerNames = UpdateMinimapNames(self)
	local blipSize = self.blipSizeTable[kBlipSizeType.Normal]
	
	// Update scan blip size and color.    
	do 
		local scanAnimFraction = (Shared.GetTime() % kScanAnimDuration) / kScanAnimDuration        
		local scanBlipScale = 1.0 + scanAnimFraction * 9.0 // size goes from 1.0 to 10.0
		local scanAnimAlpha = 1 - scanAnimFraction
		scanAnimAlpha = scanAnimAlpha * scanAnimAlpha
		
		self.scanColor.a = scanAnimAlpha
		self.scanSize.x = blipSize.x * scanBlipScale // do not change blipSizeTable reference
		self.scanSize.y = blipSize.y * scanBlipScale // do not change blipSizeTable reference
	end
	
	local highlightPos, highlightTime = GetHighlightPosition()
	if highlightTime then
	
		local createAnimFraction = 1 - Clamp((Shared.GetTime() - highlightTime) / 1.5, 0, 1)
		local sizeAnim = (1 + math.sin(Shared.GetTime() * 6)) * 0.25 + 2
	
		local blipScale = createAnimFraction * 15 + sizeAnim

		self.highlightWorldSize.x = blipSize.x * blipScale
		self.highlightWorldSize.y = blipSize.y * blipScale
		
		self.highlightWorldColor.a = 0.7 + 0.2 * math.sin(Shared.GetTime() * 5) + createAnimFraction
	
	end
	
	local etherealGateAnimFraction = 0.25 + (1 + math.sin(Shared.GetTime() * 10)) * 0.5 * 0.75
	self.etherealGateColor.a = etherealGateAnimFraction
	
	// spectating?
	local spectating = Client.GetLocalPlayer():GetTeamNumber() == kSpectatorIndex
	local playerTeam = Client.GetLocalPlayer():GetTeamNumber()
	
	if playerTeam == kMarineTeamType then
		playerTeam = kMinimapBlipTeam.Marine
	elseif playerTeam == kAlienTeamType then
		playerTeam = kMinimapBlipTeam.Alien
	end
	
	// Update each blip.
	local blipInfoTable, blipSizeTable, blipColorTable = self.blipInfoTable, self.blipSizeTable, self.blipColorTable
	local currentIndex = 1
	local GUIItemSetLayer = GUIItem.SetLayer
	local GUIItemSetTexturePixelCoordinates = GUIItem.SetTexturePixelCoordinates
	local GUIItemSetSize = GUIItem.SetSize
	local GUIItemSetPosition = GUIItem.SetPosition
	local GUIItemSetRotation = GUIItem.SetRotation
	local GUIItemSetColor = GUIItem.SetColor
	
	local xPos, yPos, rotation, clientIndex, isParasited, blipType, blipTeam, underAttack, isSteamFriend, isHallucination, blip, blipInfo, blipSize, blipColor
	for i = 1, numBlips do

		xPos, yPos = PlotToMap(self, staticBlips[currentIndex], staticBlips[currentIndex + 1])
		rotation = staticBlips[currentIndex + 2]
		clientIndex = staticBlips[currentIndex + 3]
		isParasited = staticBlips[currentIndex + 4]
		blipType = staticBlips[currentIndex + 5]
		blipTeam = staticBlips[currentIndex + 6]
		underAttack = staticBlips[currentIndex + 7]
		isSteamFriend = staticBlips[currentIndex + 8]
		isHallucination = staticBlips[currentIndex + 9]

		blip = staticBlipItems[i]
		blipInfo = blipInfoTable[blipType]
		blipSize = blipSizeTable[blipInfo[3]]
		
		blipColor = blipColorTable[blipTeam][blipInfo[2]]
		
		blipPos.x = xPos - blipSize.x * 0.5
		blipPos.y = yPos - blipSize.y * 0.5
		blipRotation.z = rotation
		
		GUIItemSetLayer(blip, blipInfo[4])
		GUIItemSetTexturePixelCoordinates(blip, blipInfo[1]())
		GUIItemSetSize(blip, blipSize)
		GUIItemSetPosition(blip, blipPos)
		
		GUIItemSetRotation(blip, ConditionalValue(powerPoints[blipType], Vector(0, 0, 0), blipRotation))
		
		if CHUDGetOption("playercolor_m") > 0 and marinePlayers[blipType] then
			blipColor = ColorIntToColor(CHUDGetOptionAssocVal("playercolor_m"))
		end
		
		if CHUDGetOption("playercolor_a") > 0 and alienPlayers[blipType] then
			blipColor = ColorIntToColor(CHUDGetOptionAssocVal("playercolor_a"))
		end
		
		if OnSameMinimapBlipTeam(playerTeam, blipTeam) or spectating then

			DrawMinimapNames(self, shouldShowPlayerNames, clientIndex, spectating, blipTeam, xPos, blipPos.y, isParasited)

			if isHallucination then
				blipColor = kHallucinationColor
			elseif underAttack then
				if MinimapBlipTeamIsActive(blipTeam) then
					blipColor = PulseRed(1.0)
				else
					blipColor = PulseDarkRed(blipColor)
				end
			end  

		end
		
		GUIItemSetColor(blip, blipColor)
		
		currentIndex = currentIndex + blipItemCount
		
	end
	self.inUseStaticBlipCount = numBlips
	
end
ReplaceUpValue( GUIMinimap.Update, "UpdateStaticBlips", NewUpdateStaticBlips, { LocateRecurse = true; CopyUpValues = true; } )


local originalMinimapSendKeyEvent
originalMinimapSendKeyEvent = Class_ReplaceMethod( "GUIMinimap", "SendKeyEvent",
	function(self, key, down)
	
		local player = Client.GetLocalPlayer()
		
		if GetIsBinding(key, "ShowMap") and not ChatUI_EnteringChatMessage() and not player:isa("Commander") and CHUDGetOption("minimaptoggle") == 1 then
		
			if not down then
		
				local showMap = not self.background:GetIsVisible()
				self:ShowMap(showMap)
				self:SetBackgroundMode(GUIMinimapFrame.kModeBig)
			
			end
			
			return true
			
		else
			originalMinimapSendKeyEvent(self, key, down)
		end
	end)

local oldSetBlipScale 
oldSetBlipScale = Class_ReplaceMethod( "GUIMinimap", "SetBlipScale",
	function( self, blipScale )
		if blipScale ~= self.blipScale then
			local blipSize = Vector(kBlipSize, kBlipSize, 0)
			self.blipSizeTable[kBlipSizeType.UnpoweredPowerPoint] = blipSize * 0.45 * blipScale 
		end
		oldSetBlipScale( self, blipScale )
	end)

local oldSetPlayerIconColor
oldSetPlayerIconColor = Class_ReplaceMethod( "GUIMinimap", "SetPlayerIconColor",
	function(self, color)
		if CHUDGetOption("minimaparrowcolor") > 0 then
			self.playerIconColor = ColorIntToColor(CHUDGetOptionAssocVal("minimaparrowcolor"))
		else
			oldSetPlayerIconColor(self, color)
		end
	end)