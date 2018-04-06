function GUIMinimap:UpdateCHUDCommSettings()
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
end

local minimapScript
function GetGUIMinimap()
	return minimapScript
end

local originalMinimapInit = GUIMinimap.Initialize
function GUIMinimap:Initialize()
	originalMinimapInit(self)
	
	self.minimap:SetColor(Color(1,1,1,CHUDGetOption("minimapalpha")))
	self.lastMinGUI = CHUDGetOption("mingui")
	
	minimapScript = self
	
	self:InitializeLocationNames()
end

local originalMinimapOnResChanged = GUIMinimap.OnResolutionChanged
function GUIMinimap:OnResolutionChanged(oldX, oldY, newX, newY)
	originalMinimapOnResChanged(self, oldX, oldY, newX, newY)

	local gameTime = GetGUIGameTime and GetGUIGameTime()	
	if gameTime then
		gameTime:SetFontName(GUIMarineHUD.kTextFontName)
		gameTime:SetScale(GetScaledVector())
		gameTime:SetPosition(GUIScale(Vector(35, 60, 0)))
		GUIMakeFontScale(gameTime)
	end

	local realTime = GetGUIRealTime and GetGUIRealTime()
	if realTime then
		realTime:SetFontName(GUIMarineHUD.kTextFontName)
		realTime:SetScale(GetScaledVector())
		realTime:SetPosition(GUIScale(Vector(35, 60, 0)))
		GUIMakeFontScale(realTime)
	end
end

local originalMinimapUpdate = GUIMinimap.Update
function GUIMinimap:Update(deltaTime)
	originalMinimapUpdate(self, deltaTime)
	
	local mingui = CHUDGetOption("mingui")
	if self.lastMinGUI ~= mingui then
		self:UpdateCHUDCommSettings()
		self.lastMinGUI = mingui
	end

end

local originalLocationNameInit = GUIMinimap.InitializeLocationNames
function GUIMinimap:InitializeLocationNames()
	originalLocationNameInit(self)
	if self.locationItems ~= nil then
		for _, locationItem in ipairs(self.locationItems) do
			locationItem.text:SetColor( Color(1, 1, 1, CHUDGetOption("locationalpha")) )
		end

	end
end

--Fixed version Todo: Merge into build 323
function OnCommandSetMapLocationColor(r, g, b, a)

	local minimap = ClientUI.GetScript("GUIMinimapFrame")
	if minimap then
		for i = 1, #minimap.locationItems do
			minimap.locationItems[i].text:SetColor( Color(tonumber(r)/255, tonumber(g)/255, tonumber(b)/255, tonumber(a)/255) )
		end
	end

end

local originalMinimapSendKeyEvent = GUIMinimap.SendKeyEvent
function GUIMinimap:SendKeyEvent(key, down)

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
end

local oldSetPlayerIconColor = GUIMinimap.SetPlayerIconColor
function GUIMinimap:SetPlayerIconColor(color)
	if CHUDGetOption("minimaparrowcolorcustom") then
		self.playerIconColor = ColorIntToColor(CHUDGetOption("minimaparrowcolor"))
	else
		oldSetPlayerIconColor(self, color)
	end
end