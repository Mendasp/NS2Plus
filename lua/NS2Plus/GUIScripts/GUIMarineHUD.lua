local kCHUDMinimapStencilTexture = PrecacheAsset("ui/chud_square_minimap_stencil.dds")
local kCHUDUpgradeIconsTexture = PrecacheAsset("ui/chud_upgradeicons.dds")

function GUIMarineHUD:CHUDRepositionGUI()
	local hpbar = CHUDGetOption("hpbar")
	local minimap = CHUDGetOption("minimap")
	local showcomm = CHUDGetOption("showcomm")
	local commactions = CHUDGetOption("commactions")
	local gametime = CHUDGetOption("gametime")
	local realtime = CHUDGetOption("realtime")
	
	-- Position of toggleable elements
	local y = 30
	
	if minimap then
		y = y + 300
	end
	
	if showcomm then
		self.commanderName:SetPosition(Vector(20, y, 0))
		y = y + 30
		self.resourceDisplay.teamText:SetPosition(Vector(20, y, 0))
		y = y + 30
	end
	
	if gametime and self.gameTime then
		self.gameTime:SetFontName(GUIMarineHUD.kTextFontName)
		self.gameTime:SetScale(GetScaledVector()*1.15)
		self.gameTime:SetPosition(Vector(20, y, 0))
		GUIMakeFontScale(self.gameTime)
		y = y + 30
	end
	
	if realtime and self.realTime then
		self.realTime:SetFontName(GUIMarineHUD.kTextFontName)
		self.realTime:SetScale(GetScaledVector()*1.15)
		self.realTime:SetPosition(Vector(20, y, 0))
		GUIMakeFontScale(self.realTime)
		y = y + 30
	end
	
	if commactions then
		self.eventDisplay.notificationFrame:SetPosition(Vector(20, y, 0) * self.eventDisplay.scale)
	end
	
	local xpos = ConditionalValue(hpbar, -20, -300)
	if CHUDGetOption("hudbars_m") == 2 then
		xpos = -150
	end
	self.statusDisplay.healthText:SetPosition(Vector(xpos, 36, 0))
	self.statusDisplay.armorText:SetPosition(Vector(xpos, 96, 0))
	
	local anchor = ConditionalValue(hpbar, GUIItem.Right, GUIItem.Left)
	if CHUDGetOption("hudbars_m") == 2 then
		anchor = GUIItem.Middle
	end
	self.statusDisplay.parasiteState:SetAnchor(anchor, GUIItem.Center)
	self.statusDisplay.scanLinesForeground:SetAnchor(anchor, GUIItem.Top)
end

local originalMarineInit = GUIMarineHUD.Initialize
function GUIMarineHUD:Initialize()
	originalMarineInit(self)
	
	self.gameTime = self:CreateAnimatedTextItem()
    self.gameTime:SetFontName(GUIMarineHUD.kTextFontName)
	self.gameTime:SetFontIsBold(true)
    self.gameTime:SetLayer(kGUILayerPlayerHUDForeground2)
    self.gameTime:SetColor(kBrightColor)
	self.background:AddChild(self.gameTime)

	self.realTime = self:CreateAnimatedTextItem()
    self.realTime:SetFontName(GUIMarineHUD.kTextFontName)
	self.realTime:SetFontIsBold(true)
    self.realTime:SetLayer(kGUILayerPlayerHUDForeground2)
    self.realTime:SetColor(kBrightColor)
	self.background:AddChild(self.realTime)
	
	self.welderIcon = GetGUIManager():CreateGraphicItem()
	self.welderIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
	self.welderIcon:SetColor(Color(0.725, 0.921, 0.949, 0.9))
	local uplvl = CHUDGetOption("uplvl")
	if uplvl < 2 then
		self.welderIcon:SetPosition(Vector(GUIMarineHUD.kUpgradePos.x, GUIMarineHUD.kUpgradePos.y + (GUIMarineHUD.kUpgradeSize.y)*2 + 16, 0) * self.scale)
		self.welderIcon:SetSize(GUIMarineHUD.kUpgradeSize * self.scale)
		self.welderIcon:SetTexture("ui/buildmenu.dds")
		self.welderIcon:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.Welder)))
	else
		self.welderIcon:SetPosition(Vector(GUIMarineHUD.kUpgradePos.x * 0.9, GUIMarineHUD.kUpgradePos.y + (GUIMarineHUD.kUpgradeSize.y)*2, 0) * self.scale)
		self.welderIcon:SetSize(Vector(96, 48, 0) * self.scale)
		self.welderIcon:SetTexture(kInventoryIconsTexture)
		self.welderIcon:SetTexturePixelCoordinates(GetTexCoordsForTechId(kTechId.Welder))
	end
	self.welderIcon:SetIsVisible(false)
	self.background:AddChild(self.welderIcon)
	
	-- Reversed the setting since when it's enabled it hides stuff...
	-- It makes sense to me at least, didn't like seeing so much negativity
	local mingui = not CHUDGetOption("mingui")
	local hpbar = CHUDGetOption("hpbar") and CHUDGetOption("hudbars_m") ~= 2
	local minimap = CHUDGetOption("minimap")

	local alpha = ConditionalValue(mingui,1,0)
	
	if minimap then
		local stencilTexture = ConditionalValue(mingui, "ui/marine_HUD_minimap.dds", kCHUDMinimapStencilTexture)
		
		self.minimapBackground:SetColor(Color(1,1,1,alpha))
		self.minimapScanLines:SetColor(Color(1,1,1,alpha))
		self.minimapStencil:SetTexture(stencilTexture)
	end
		
	self:SetFrameVisible(mingui)
	self.resourceDisplay.background:SetColor(Color(1,1,1,alpha))

	self.statusDisplay.statusbackground:SetColor(Color(1,1,1,alpha))
	self.statusDisplay.scanLinesForeground:SetColor(Color(147/255, 206/255, 1,alpha*0.3))
	
	self.statusDisplay.healthBar:SetIsVisible(hpbar)
	self.statusDisplay.armorBar:SetIsVisible(hpbar)
	self.statusDisplay.regenBar:SetIsVisible(hpbar)
	
	local texture = ConditionalValue(hpbar, "ui/marine_HUD_status.dds", "ui/transparent.dds")
	self.statusDisplay.statusbackground:SetTexture(texture)
	
	self:CHUDRepositionGUI()
	
	-- Fixes marine elements showing up in the Exo HUD when reloading the script
	self:OnLocalPlayerChanged(Client.GetLocalPlayer())
	
	if CHUDGetOption("hudbars_m") == 2 then
		self.resourceDisplay.background:SetPosition(Vector(-440, -100, 0))
		
		local pos = self.armorLevel:GetPosition()
		self.armorLevel:SetPosition(Vector(pos.x, pos.y-200, 0))
		pos = self.weaponLevel:GetPosition()
		self.weaponLevel:SetPosition(Vector(pos.x, pos.y-200, 0))
		pos = self.welderIcon:GetPosition()
		self.welderIcon:SetPosition(Vector(pos.x, pos.y-200, 0))
	end
	
end

local originalResetMinimap = GUIMarineHUD.ResetMinimap
function GUIMarineHUD:ResetMinimap()
	originalResetMinimap(self)
	
	local setting = not CHUDGetOption("mingui")
	
	self.minimapBackground:SetColor(Color(1,1,1,ConditionalValue((setting),1,0)))
	self.minimapScanLines:SetColor(Color(1,1,1,ConditionalValue((setting),1,0)))
	
	local stencilTexture = ConditionalValue(setting, "ui/marine_HUD_minimap.dds", kCHUDMinimapStencilTexture)
	self.minimapStencil:SetTexture(stencilTexture)

end

local originalSetHUDMap = GUIMarineHUD.SetHUDMapEnabled
function GUIMarineHUD:SetHUDMapEnabled(enabled)
	local minimap = CHUDGetOption("minimap")
	originalSetHUDMap(self, minimap)
	self.locationText:SetIsVisible(minimap)
end

local originalShowNewArmorLevel = GUIMarineHUD.ShowNewArmorLevel
function GUIMarineHUD:ShowNewArmorLevel(armorLevel)
	local uplvl = CHUDGetOption("uplvl")
	if uplvl == 0 then
		self.armorLevel:SetTexture("ui/transparent.dds")
	elseif uplvl == 1 then
		originalShowNewArmorLevel(self, armorLevel)
		self.armorLevel:SetTexture(GUIMarineHUD.kUpgradesTexture)
	elseif uplvl == 2 then
		self.armorLevel:SetTexture(kCHUDUpgradeIconsTexture)
		local x1 = armorLevel * 80 - 80
		local x2 = x1 + 80
		local textureCoords = { x1, 0, x2, 80 }
		self.armorLevel:SetTexturePixelCoordinates(GUIUnpackCoords(textureCoords))
	end
end
			
local originalShowNewWeaponLevel = GUIMarineHUD.ShowNewWeaponLevel
function GUIMarineHUD:ShowNewWeaponLevel(weaponLevel)
	local uplvl = CHUDGetOption("uplvl")
	if uplvl == 0 then
		self.weaponLevel:SetTexture("ui/transparent.dds")
	elseif uplvl == 1 then
		originalShowNewWeaponLevel(self, weaponLevel)
		self.weaponLevel:SetTexture(GUIMarineHUD.kUpgradesTexture)
	elseif uplvl == 2 then
		self.weaponLevel:SetTexture(kCHUDUpgradeIconsTexture)
		local x1 = 160 + weaponLevel * 80
		local x2 = x1 + 80
		local textureCoords = { x1, 0, x2, 80 }
		self.weaponLevel:SetTexturePixelCoordinates(GUIUnpackCoords(textureCoords))
	end
end

local originalMarineChanged = GUIMarineHUD.OnLocalPlayerChanged
function GUIMarineHUD:OnLocalPlayerChanged(newPlayer)

	originalMarineChanged(self, newPlayer)

	if not newPlayer:isa("Exo") then
		self:SetFrameVisible(not CHUDGetOption("mingui"))
	end
end
	
local originalTriggerInit = GUIMarineHUD.TriggerInitAnimations
function GUIMarineHUD:TriggerInitAnimations()

	if not CHUDGetOption("mingui") then
		originalTriggerInit(self)
	end

end

local originalMarineHUDUpdate = GUIMarineHUD.Update
function GUIMarineHUD:Update(deltaTime)
	local mingui = not CHUDGetOption("mingui")
	local showcomm = CHUDGetOption("showcomm")
	local rtcount = CHUDGetOption("rtcount")
	local commactions = CHUDGetOption("commactions")
	local gametime = CHUDGetOption("gametime")
	local realtime = CHUDGetOption("realtime")
	local hpbar = CHUDGetOption("hpbar") and CHUDGetOption("hudbars_m") ~= 2
	local inventoryMode = CHUDGetOption("inventory")
	local welderUpgrade = CHUDGetOption("welderup")

	-- Minimal HUD pls go home, you're drunk
	-- Run this if WE choose to have it
	if self.lastNotificationUpdate + GUIMarineHUD.kNotificationUpdateIntervall < Client.GetTime() then
		local fullMode = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
		if not fullMode and commactions then
			self.eventDisplay:Update(Client.GetTime() - self.lastNotificationUpdate, { PlayerUI_GetRecentNotification(), PlayerUI_GetRecentPurchaseable() } )
			self.lastNotificationUpdate = Client.GetTime()
		end
		self.eventDisplay.notificationFrame:SetIsVisible(commactions)
	end

	originalMarineHUDUpdate(self, deltaTime)

	local player = Client.GetLocalPlayer()

	if self.gameTime then
		self.gameTime:SetText(CHUDGetGameTimeString())
		self.gameTime:SetIsVisible(gametime)
	end
	
	if self.realTime then
		self.realTime:SetText(CHUDGetRealTimeString())
		self.realTime:SetIsVisible(realtime)
	end

	if self.welderIcon then
		self.welderIcon:SetIsVisible(welderUpgrade and player:GetWeapon(Welder.kMapName) ~= nil)
	end

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

	if CHUDGetOption("hudbars_m") == 2 then
		local pos = self.resourceDisplay.rtCount:GetPosition()
		self.resourceDisplay.rtCount:SetPosition(Vector(pos.x-75, pos.y, 0))
	end

	-- Commander name / TRes
	self.commanderName:SetIsVisible(showcomm)
	self.resourceDisplay.teamText:SetIsVisible(showcomm)

	-- Disable that rotating border around the HP Bars if we have MinGUI or disabled bars
	if not mingui or not hpbar then
		self.statusDisplay.healthBorderMask:SetColor(Color(1,1,1,0))
		self.statusDisplay.armorBorderMask:SetColor(Color(1,1,1,0))
	end

	-- If it's an Exo with hidden viewmodels, display armor in the HUD
	if player and player:isa("Exo") and gCHUDHiddenViewModel then
		self:SetStatusDisplayVisible(true)
		self.statusDisplay.statusbackground:SetColor(Color(1,1,1,0))
		self.statusDisplay.healthBorderMask:SetColor(Color(1,1,1,0))
		self.statusDisplay.scanLinesForeground:SetColor(Color(147/255, 206/255, 1,0))
		self.statusDisplay.healthBar:SetIsVisible(false)
		self.statusDisplay.healthText:SetIsVisible(false)
		self.statusDisplay.armorText:SetIsVisible(true)
	else
		if mingui then
			self.statusDisplay.scanLinesForeground:SetColor(kBrightColorTransparent)
		end
		self.statusDisplay.healthBar:SetIsVisible(hpbar)
		self.statusDisplay.healthText:SetIsVisible(true)

		if self.statusDisplay.lastRegenHealth and self.statusDisplay.lastRegenHealth > 0 and not hpbar then
			self.statusDisplay.regenBar:SetIsVisible(false)
		end
	end

	-- In vanilla, the commander name doesn't get updated (or show!) if we use low detail HUD
	-- Make it run again! Let us choose! Power to the people!
	-- Update commander name
	local commanderName = PlayerUI_GetCommanderName()

	if Client.GetOptionInteger("hudmode", kHUDMode.Full) ~= kHUDMode.Full and showcomm then

		if commanderName == nil then

			commanderName = Locale.ResolveString("NO_COMMANDER")

			if not self.commanderNameIsAnimating then

				self.commanderNameIsAnimating = true
				self.commanderName:FadeOut(1, nil, AnimateLinear, AnimFadeIn)
				self.commanderName:SetColor(Color(1, 0, 0, 1))

			end

		else

			commanderName = Locale.ResolveString("COMMANDER") .. commanderName

			self.commanderName:SetColor(GUIMarineHUD.kActiveCommanderColor)

			if self.commanderNameIsAnimating then

				self.commanderNameIsAnimating = false
				self.commanderName:DestroyAnimations()

			end

		end

		commanderName = string.upper(commanderName)
		if self.lastCommanderName ~= commanderName then

			self.commanderName:DestroyAnimation("COMM_TEXT_WRITE")
			self.commanderName:SetText("")
			self.commanderName:SetText(commanderName, 0.5, "COMM_TEXT_WRITE")
			self.lastCommanderName = commanderName

		end
	else
		if commanderName ~= nil then
			self.commanderName:SetColor(GUIMarineHUD.kActiveCommanderColor)
		end
	end
end
	
local originalMarineUninit = GUIMarineHUD.Uninitialize
function GUIMarineHUD:Uninitialize()
	originalMarineUninit(self)
	
	GUI.DestroyItem(self.gameTime)
	self.gameTime = nil

	GUI.DestroyItem(self.realTime)
	self.realTime = nil

	self.commanderNameIsAnimating = nil
	self.lastCommanderName = nil
	self.welderIcon = nil
	
end

local originalMarineReset = GUIMarineHUD.Reset
function GUIMarineHUD:Reset()
	originalMarineReset(self)
	
	self:CHUDRepositionGUI()
end