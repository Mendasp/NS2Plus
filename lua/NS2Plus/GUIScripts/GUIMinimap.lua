local kBlipColorType 	= GetUpValue( GUIMinimap.Initialize,   "kBlipColorType", 		{ LocateRecurse = true } )
local kStaticBlipsLayer = GetUpValue( GUIMinimap.Initialize,   "kStaticBlipsLayer", 	{ LocateRecurse = true } )
local kBlipSize 		= GetUpValue( GUIMinimap.SetBlipScale, "kBlipSize", 			{ LocateRecurse = true } )
local kBlipSizeType 	= GetUpValue( GUIMinimap.Initialize,   "kBlipSizeType", 		{ LocateRecurse = true } )
local kBlipInfo 		= GetUpValue( GUIMinimap.Initialize,   "kBlipInfo", 			{ LocateRecurse = true } )

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
			
			-- Move buttons off-screen so we can click through
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
				local biomassSmokeyBackground = ConditionalValue(mingui, "ui/alien_commander_bg_smoke.dds", "ui/transparent.dds")
				local biomassTexture = ConditionalValue(mingui, "ui/biomass_bar.dds", "ui/transparent.dds")
				
				biomass.smokeyBackground:SetAdditionalTexture("noise", biomassSmokeyBackground)
				biomass.background:SetTexture(biomassTexture)
			end
		end
	end)

local minimapScript, gameTime

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
	
	self:InitializeLocationNames()
end)

local originalMinimapOnResChanged
originalMinimapOnResChanged = Class_ReplaceMethod( "GUIMinimap", "OnResolutionChanged",
function(self, oldX, oldY, newX, newY)
	originalMinimapOnResChanged(self, oldX, oldY, newX, newY)
	
	if gameTime then
		gameTime:SetFontName(GUIMarineHUD.kTextFontName)
		gameTime:SetScale(GetScaledVector())
		gameTime:SetPosition(GUIScale(Vector(35, 60, 0)))
		GUIMakeFontScale(gameTime)
	end
end)

local originalCommanderInit
originalCommanderInit = Class_ReplaceMethod( "Commander", "OnInitLocalClient",
function(self)
	originalCommanderInit(self)
	
	minimapScript:UpdateCHUDCommSettings()
	
	self.gameTime = GUIManager:CreateTextItem()
	self.gameTime:SetFontIsBold(true)
	self.gameTime:SetLayer(kGUILayerPlayerHUDForeground2)
	self.gameTime:SetColor(Color(0.5, 0.5, 0.5, 1))
	self.gameTime:SetPosition(GUIScale(Vector(35, 60, 0)))
	self.gameTime:SetFontName(GUIMarineHUD.kTextFontName)
	self.gameTime:SetScale(GetScaledVector())
	GUIMakeFontScale(self.gameTime)
	
	gameTime = self.gameTime
end)

local originalCommanderUpdate
originalCommanderUpdate = Class_ReplaceMethod( "Commander", "UpdateMisc",
function(self, input)
	originalCommanderUpdate(self, input)
	
	if self.gameTime then
		self.gameTime:SetText(CHUDGetGameTimeString())
		self.gameTime:SetIsVisible(CHUDGetOption("gametime"))
	end
end)

local originalCommanderOnDestroy
originalCommanderOnDestroy = Class_ReplaceMethod( "Commander", "OnDestroy",
function(self)
	GUI.DestroyItem(self.gameTime)
	self.gameTime = nil
	gameTime = nil
	originalCommanderOnDestroy(self)
end)


local marinePlayers = set {
	kMinimapBlipType.Marine, kMinimapBlipType.JetpackMarine, kMinimapBlipType.Exo
}
local alienPlayers = set {
	kMinimapBlipType.Skulk, kMinimapBlipType.Gorge, kMinimapBlipType.Lerk, kMinimapBlipType.Fade, kMinimapBlipType.Onos 
}

local mapElements = set {
	kMinimapBlipType.TechPoint, kMinimapBlipType.ResourcePoint
}

local originalMapBlipGetMapBlipColor
originalMapBlipGetMapBlipColor = Class_ReplaceMethod( "MapBlip", "GetMapBlipColor",
function(self, minimap, item)
	local returnColor = originalMapBlipGetMapBlipColor(self, minimap, item)
	
	local player = Client.GetLocalPlayer()
	local highlight = CHUDGetOption("commhighlight")
	local highlightColor = ColorIntToColor(CHUDGetOption("commhighlightcolor"))
	local blipTeam = self:GetMapBlipTeam(minimap)
	local teamVisible = self.OnSameMinimapBlipTeam(minimap.playerTeam, blipTeam) or minimap.spectating
	local isHighlighted = false
	
	if marinePlayers[self.mapBlipType] then
		returnColor = ColorIntToColor(CHUDGetOption("playercolor_m"))
	elseif alienPlayers[self.mapBlipType] and not (teamVisible and self.isHallucination) then
		returnColor = ColorIntToColor(CHUDGetOption("playercolor_a"))
	elseif mapElements[self.mapBlipType] then
		returnColor = ColorIntToColor(CHUDGetOption("mapelementscolor"))
	elseif player and player:GetIsCommander() and highlight and EnumToString(kTechId, player:GetGhostModelTechId()) == EnumToString(kMinimapBlipType, self.mapBlipType) then
		returnColor = highlightColor
		isHighlighted = true
	end
	
	if not self.isHallucination then
		if teamVisible then
			if self.isInCombat then
				if self.MinimapBlipTeamIsActive(blipTeam) then
					if isHighlighted then
						local percentage = (math.cos(Shared.GetTime() * 10) + 1) * 0.5
						returnColor = LerpColor(kRed, highlightColor, percentage)
					else
						returnColor = self.PulseRed(1.0)
					end
				else
					returnColor = self.PulseDarkRed(returnColor)
				end
			end
		end
	end
	
	return returnColor
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

-- Bugfix for UI Scaling breaking sometimes
local originalLocationNameUninit
originalLocationNameUninit = Class_ReplaceMethod( "GUIMinimap", "UninitializeLocationNames",
	function(self)
		originalLocationNameUninit(self)
		
		ReplaceUpValue(originalLocationNameInit, "gLocationItems", self.locationItems, { LocateRecurse = true })
	end)

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

local oldSetPlayerIconColor
oldSetPlayerIconColor = Class_ReplaceMethod( "GUIMinimap", "SetPlayerIconColor",
	function(self, color)
		if CHUDGetOption("minimaparrowcolorcustom") then
			self.playerIconColor = ColorIntToColor(CHUDGetOption("minimaparrowcolor"))
		else
			oldSetPlayerIconColor(self, color)
		end
	end)

local kCHUDMarineIconsFileName = PrecacheAsset("ui/chud_marine_minimap_blip.dds")
local kMarineIconsFileName = PrecacheAsset("ui/marine_minimap_blip.dds")
local oldSetBackgroundMode
oldSetBackgroundMode = Class_ReplaceMethod( "GUIMinimapFrame", "SetBackgroundMode",
	function(self, setMode, forceReset)
		oldSetBackgroundMode(self, setMode, forceReset)
		
		if self.comMode == GUIMinimapFrame.kModeZoom then
			self:SetIconFileName(ConditionalValue(CHUDGetOption("minimaparrowcolorcustom") or CHUDGetOption("playercolor_m") ~= CHUDGetOptionParam("playercolor_m", "defaultValue"), kCHUDMarineIconsFileName, kMarineIconsFileName))
		else
			self:SetIconFileName(nil)
		end
	end)