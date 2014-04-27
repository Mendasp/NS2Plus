Class_AddMethod( "GUIAlienHUD", "CHUDRepositionGUI",
	function(self)
		local mingui = not CHUDGetOption("mingui")
		local showcomm = CHUDGetOption("showcomm")
		local gametime = CHUDGetOption("gametime")
		local biomass = ClientUI.GetScript("GUIBioMassDisplay")
		local location = ClientUI.GetScript("GUINotifications")
		
		// Avoids overlap in lower resolutions
		location.locationText:SetPosition(GUIScale(Vector(20, 10, 0)))
		
		// Position of toggleable elements
		local y = 76
		
		if showcomm then
			self.resourceDisplay.teamText:SetUniformScale(self.scale)
			self.resourceDisplay.teamText:SetPosition(Vector(20, y, 0))
			y = y + 30
		end
		
		if gametime and self.gameTime then
			self.gameTime:SetUniformScale(self.scale)
			self.gameTime:SetScale(GetScaledVector()*1.15)
			self.gameTime:SetPosition(Vector(20, y, 0))
			y = y + 30
		end
		
		y = y - 20
		biomass.background:SetPosition(GUIScale(Vector(20, y, 0)))
		biomass.smokeyBackground:SetPosition(GUIScale(Vector(-100, y-75, 0)))
		
		local biomassTexture = ConditionalValue(mingui, "ui/biomass_bar.dds", "ui/blank.dds")
		
		biomass.smokeyBackground:SetIsVisible(mingui)
		biomass.background:SetTexture(biomassTexture)
	end)

Class_AddMethod( "GUIAlienHUD", "OnLocalPlayerChanged",
	function(self, newPlayer)
	
		if Client.GetIsControllingPlayer() then
			Client.GetLocalPlayer():SetDarkVision(CHUDGetOption("avstate"))
		end
	
	end)

local originalAlienInit
originalAlienInit = Class_ReplaceMethod( "GUIAlienHUD", "Initialize",
	function(self)
		local mingui = not CHUDGetOption("mingui")
		local alienbars = CHUDGetOption("alienbars")
	
		if alienbars == 2 then
			ReplaceLocals( GUIAlienHUD.CreateEnergyBall, { kEnergyTextureX1 = 128, kEnergyTextureX2 = 256 } )
		else
			ReplaceLocals( GUIAlienHUD.CreateEnergyBall, { kEnergyTextureX1 = 0, kEnergyTextureX2 = 128 } )
		end
	
		originalAlienInit(self)
		
		self.gameTime = self:CreateAnimatedTextItem()
		self.gameTime:SetFontName(GUIMarineHUD.kTextFontName)
		self.gameTime:SetFontIsBold(true)
		self.gameTime:SetLayer(kGUILayerPlayerHUDForeground2)
		self.gameTime:SetColor(kAlienTeamColorFloat)
		
		local kTextureNameCHUD = CHUDGetOptionAssocVal("alienbars")
		local kBackgroundCHUD = ConditionalValue(mingui, PrecacheAsset("ui/alien_commander_bg_smoke.dds"), PrecacheAsset("ui/blank.dds"))
		
		// Backgrounds of health/energy
		self.healthBall.dialBackground:SetAdditionalTexture("noise", kBackgroundCHUD)
		self.energyBall.dialBackground:SetAdditionalTexture("noise", kBackgroundCHUD)
		self.secondaryAbilityBackground:SetAdditionalTexture("noise", kBackgroundCHUD)
		
		// Alien bars		
		self.healthBall:SetForegroundTexture(kTextureNameCHUD)
		self.armorBall:SetForegroundTexture(kTextureNameCHUD)
		self.energyBall:SetForegroundTexture(kTextureNameCHUD)
		self.adrenalineEnergy:SetForegroundTexture(kTextureNameCHUD)
		
		local healthColor = ConditionalValue(alienbars == 2, Color(1, 1, 1, 1), Color(230/255, 171/255, 46/255, 1))
		local armorColor = ConditionalValue(alienbars == 2, Color(1, 1, 1, 1), Color(1, 121/255, 12/255, 1))
		local energyColor = ConditionalValue(alienbars == 2, Color(1, 1, 1, 1), Color(230/255, 171/255, 46/255, 1))
		local adrenalineColor = ConditionalValue(alienbars == 2, Color(1, 1, 1, 1), Color(1, 121/255, 12/255, 1))
		
		self.healthBall:GetLeftSide():SetColor(healthColor)
		self.healthBall:GetRightSide():SetColor(healthColor)
		
		self.armorBall:GetLeftSide():SetColor(armorColor)
		self.armorBall:GetRightSide():SetColor(armorColor)
		
		self.energyBall:GetLeftSide():SetColor(energyColor)
		self.energyBall:GetRightSide():SetColor(energyColor)
		
		self.adrenalineEnergy:GetLeftSide():SetColor(adrenalineColor)
		self.adrenalineEnergy:GetRightSide():SetColor(adrenalineColor)

		if CHUDGetOption("mingui") then
			self.resourceDisplay.background:SetColor(Color(1,1,1,0))
		else
			self.resourceDisplay.background:SetColor(Color(1,1,1,1))
		end
				
		Client.DestroyScreenEffect(Player.screenEffects.darkVision)
		Client.DestroyScreenEffect(HiveVision_screenEffect)
		Client.DestroyScreenEffect(HiveVisionExtra_screenEffect)
		HiveVision_screenEffect = Client.CreateScreenEffect("shaders/HiveVision.screenfx")
		HiveVisionExtra_screenEffect = Client.CreateScreenEffect("shaders/HiveVisionExtra.screenfx")
		Player.screenEffects.darkVision = Client.CreateScreenEffect(CHUDGetOptionAssocVal("av"))
		
		self:CHUDRepositionGUI()
	end)

local originalAlienUpdate
originalAlienUpdate = Class_ReplaceMethod( "GUIAlienHUD", "Update",
	function(self, deltaTime)
		originalAlienUpdate(self, deltaTime)
		
		local mingui = not CHUDGetOption("mingui")
		local rtcount = CHUDGetOption("rtcount")
		local gametime = CHUDGetOption("gametime")
		local showcomm = CHUDGetOption("showcomm")
			
		if not rtcount then
			self.resourceDisplay.rtCount:SetIsVisible(false)
			self.resourceDisplay.pResDescription:SetText(string.format("%s (%d %s)",
				Locale.ResolveString("RESOURCES"),
				CommanderUI_GetTeamHarvesterCount(),
				ConditionalValue(CommanderUI_GetTeamHarvesterCount() == 1, "RT", "RTs")))
		else
			self.resourceDisplay.rtCount:SetIsVisible(CommanderUI_GetTeamHarvesterCount() > 0)
			self.resourceDisplay.pResDescription:SetText(Locale.ResolveString("RESOURCES"))
		end
		
		if self.gameTime then
			self.gameTime:SetText(CHUDGetGameTime())
			self.gameTime:SetIsVisible(gametime)
		end
		
		self.resourceDisplay.teamText:SetIsVisible(showcomm)
	end)
	
local originalAlienReset
originalAlienReset = Class_ReplaceMethod( "GUIAlienHUD", "Reset",
function(self)
	originalAlienReset(self)

	self:CHUDRepositionGUI()
end)

local originalAlienUninit
originalAlienUninit = Class_ReplaceMethod( "GUIAlienHUD", "Uninitialize",
function(self)
	originalAlienUninit(self)

	GUI.DestroyItem(self.gameTime)
	self.gameTime = nil
end)
	
Script.Load("lua/GUIAlienTeamMessage.lua")
local originalAlienMessage
originalAlienMessage = Class_ReplaceMethod( "GUIAlienTeamMessage", "SetTeamMessage",
	function(self, message)
		originalAlienMessage(self, message)
		if not CHUDGetOption("banners") then
			self.background:SetIsVisible(false)
		end
		if CHUDGetOption("mingui") then
			self.background:DestroyAnimations()
		end
	end)