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
				local frameTexture = ConditionalValue(mingui, "ui/marine_commander_textures.dds", "ui/blank.dds")
				local buttonsTexture = ConditionalValue(mingui, GUICommanderButtonsMarines:GetBackgroundTextureName(), "ui/blank.dds")
				local selectionTexture = ConditionalValue(mingui, GUISelectionPanel.kSelectionTextureMarines, "ui/blank.dds")
				local logoutTexture = ConditionalValue(mingui, GUICommanderLogout.kLogoutMarineTextureName, "ui/blank.dds")
				local tooltipTexture = ConditionalValue(mingui, GUICommanderTooltip.kMarineBackgroundTexture, "ui/blank.dds")
				
				minimapFrame.minimapFrame:SetTexture(frameTexture)
				minimapFrame.buttonsScript.background:SetTexture(buttonsTexture)
				selectionPanelScript.background:SetTexture(selectionTexture)
				logoutScript.background:SetTexture(logoutTexture)
				commanderTooltip.backgroundTop:SetTexture(tooltipTexture)
				commanderTooltip.backgroundCenter:SetTexture(tooltipTexture)
				commanderTooltip.backgroundBottom:SetTexture(tooltipTexture)
			elseif player:isa("AlienCommander") then
				local buttonsTexture = ConditionalValue(mingui, "ui/alien_commander_smkmask.dds", "ui/blank.dds")
				local selectionTexture = ConditionalValue(mingui, "ui/alien_logout_smkmask.dds", "ui/blank.dds")
				local smokeTexture = ConditionalValue(mingui, "ui/alien_minimap_smkmask.dds", "ui/blank.dds")
				local resourceTexture = ConditionalValue(mingui, "ui/alien_ressources_smkmask.dds", "ui/blank.dds")
				local logoutTexture = ConditionalValue(mingui, "ui/alien_logout_smkmask.dds", "ui/blank.dds")
				local tooltipTexture = ConditionalValue(mingui, "ui/alien_logout_smkmask.dds", "ui/blank.dds")

				minimapFrame.buttonsScript.smokeyBackground:SetTexture(buttonsTexture)
				selectionPanelScript.smokeyBackground:SetTexture(selectionTexture)
				minimapFrame.smokeyBackground:SetTexture(smokeTexture)
				resourceDisplay.smokeyBackground:SetTexture(resourceTexture)
				logoutScript.smokeyBackground:SetTexture(logoutTexture)
				commanderTooltip.smokeyBackground:SetTexture(tooltipTexture)
				
				local biomass = ClientUI.GetScript("GUIBioMassDisplay")
				local biomassTexture = ConditionalValue(mingui, "ui/biomass_bar.dds", "ui/blank.dds")
				
				biomass.smokeyBackground:SetIsVisible(mingui)
				biomass.background:SetTexture(biomassTexture)
			end
		end
	end)

local minimapScript

local kBlipInfo
local originalMinimapInit
originalMinimapInit = Class_ReplaceMethod( "GUIMinimap", "Initialize",
function(self)
	if kBlipInfo ~= nil then
		ReplaceUpValue( originalMinimapInit, "kBlipInfo", kBlipInfo )
	end
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

local GetNamePool
local updateStaticBlips, oldDrawMinimapNames = LocateUpValue( GUIMinimap.Update, "DrawMinimapNames", { LocateRecurse = true } )
local function NewDrawMinimapNames(self, shouldShowPlayerNames, clientIndex, spectating, blipTeam, xPos, yPos, isParasited)

	oldDrawMinimapNames( self, shouldShowPlayerNames, clientIndex, spectating, blipTeam, xPos, yPos, isParasited )
	
	if clientIndex > 0 and shouldShowPlayerNames and not isParasited and not spectating then				
		local record = Scoreboard_GetPlayerRecord( clientIndex )			
		if record.IsRookie then
			local nameItem = GetNamePool(self, clientIndex)		
			nameItem:SetColor( Color( 0, 1, 0 ) )
		end
	end
	
end		
ReplaceUpValue( updateStaticBlips, "DrawMinimapNames", NewDrawMinimapNames, { CopyUpValues = true } )