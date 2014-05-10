Class_AddMethod( "GUIMarineHUD", "CHUDRepositionGUI",
	function(self)
		local hpbar = CHUDGetOption("hpbar")
		local minimap = CHUDGetOption("minimap")
		local showcomm = CHUDGetOption("showcomm")
		local commactions = CHUDGetOption("commactions")
		local gametime = CHUDGetOption("gametime")
		
		// Position of toggleable elements
		local y = 30
		
		if self.CHUDLocationText then
			self.CHUDLocationText:SetUniformScale(self.scale)
			self.CHUDLocationText:SetScale(GetScaledVector()*1.2)
			self.CHUDLocationText:SetPosition(Vector(75, y+11, 0))
		end
			
		if minimap then
			y = y + 300
		end
		
		if showcomm then
			self.commanderName:SetPosition(Vector(20, y, 0))
			y = y + 30
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
		
		if commactions then
			self.eventDisplay.notificationFrame:SetPosition(Vector(20, y, 0) * self.eventDisplay.scale)
		end
		
		local xpos = ConditionalValue(hpbar, -20, -300)
		self.statusDisplay.healthText:SetPosition(Vector(xpos, 36, 0))
		self.statusDisplay.armorText:SetPosition(Vector(xpos, 96, 0))
		
		local anchor = ConditionalValue(hpbar, GUIItem.Right, GUIItem.Left)
		self.statusDisplay.parasiteState:SetAnchor(anchor, GUIItem.Center)
		self.statusDisplay.scanLinesForeground:SetAnchor(anchor, GUIItem.Top)
	end)

local originalMarineInit
originalMarineInit = Class_ReplaceMethod( "GUIMarineHUD", "Initialize",
function(self)
	originalMarineInit(self)
	
	// Make the location text non-stupid
	self.locationText:SetIsVisible(false)
	
    self.CHUDLocationText = self:CreateAnimatedTextItem()
    self.CHUDLocationText:SetFontName(GUIMarineHUD.kTextFontName)
    self.CHUDLocationText:SetTextAlignmentX(GUIItem.Align_Min)
    self.CHUDLocationText:SetTextAlignmentY(GUIItem.Align_Min)
    self.CHUDLocationText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.CHUDLocationText:SetLayer(kGUILayerPlayerHUDForeground2)
    self.CHUDLocationText:SetColor(kBrightColor)
    self.CHUDLocationText:SetFontIsBold(true)
	self.background:AddChild(self.CHUDLocationText)
	
	self.gameTime = self:CreateAnimatedTextItem()
    self.gameTime:SetFontName(GUIMarineHUD.kTextFontName)
	self.gameTime:SetFontIsBold(true)
    self.gameTime:SetLayer(kGUILayerPlayerHUDForeground2)
    self.gameTime:SetColor(kBrightColor)
	self.background:AddChild(self.gameTime)
	
	// Initialize location and power so they show up correctly
	self.lastLocationText = ""
	self.lastPowerState = 0
	
	// Reversed the setting since when it's enabled it hides stuff...
	// It makes sense to me at least, didn't like seeing so much negativity
	local mingui = not CHUDGetOption("mingui")
	local hpbar = CHUDGetOption("hpbar")
	local minimap = CHUDGetOption("minimap")
	local showcomm = CHUDGetOption("showcomm")
	local commactions = CHUDGetOption("commactions")
	local gametime = CHUDGetOption("gametime")

	local alpha = ConditionalValue(mingui,1,0)
	
	if minimap then
		local stencilTexture = ConditionalValue(mingui, "ui/marine_HUD_minimap.dds", "ui/chud_square_minimap_stencil.dds")
		
		self.minimapBackground:SetColor(Color(1,1,1,alpha))
		self.minimapScanLines:SetColor(Color(1,1,1,alpha))
		self.minimapStencil:SetTexture(stencilTexture)
	end
		
	self:SetFrameVisible(mingui)
	self.resourceDisplay.background:SetColor(Color(1,1,1,alpha))

	self.statusDisplay.statusbackground:SetColor(Color(1,1,1,alpha))
	self.statusDisplay.scanLinesForeground:SetColor(Color(147/255, 206/255, 1,alpha*0.3))
	
	self:ShowNewWeaponLevel(PlayerUI_GetWeaponLevel())
	self:ShowNewArmorLevel(PlayerUI_GetArmorLevel())
		
	self.statusDisplay.healthBar:SetIsVisible(hpbar)
	self.statusDisplay.armorBar:SetIsVisible(hpbar)
	
	local texture = ConditionalValue(hpbar, PrecacheAsset("ui/marine_HUD_status.dds"), PrecacheAsset("ui/blank.dds"))
	self.statusDisplay.statusbackground:SetTexture(texture)
	
	self:CHUDRepositionGUI()
	
	// Fixes marine elements showing up in the Exo HUD when reloading the script
	self:OnLocalPlayerChanged(Client.GetLocalPlayer())
	
end)

local originalResetMinimap
originalResetMinimap = Class_ReplaceMethod( "GUIMarineHUD", "ResetMinimap",
function(self)
	originalResetMinimap(self)

	self.minimapPower:SetPosition(Vector(0, -34, 0))
	
	local setting = not CHUDGetOption("mingui")
	
	self.minimapBackground:SetColor(Color(1,1,1,ConditionalValue((setting),1,0)))
	self.minimapScanLines:SetColor(Color(1,1,1,ConditionalValue((setting),1,0)))
	
	local stencilTexture = ConditionalValue(setting, "ui/marine_HUD_minimap.dds", "ui/chud_square_minimap_stencil.dds")
	self.minimapStencil:SetTexture(stencilTexture)

end)

local originalSetHUDMap
originalSetHUDMap = Class_ReplaceMethod( "GUIMarineHUD", "SetHUDMapEnabled",
function(self, enabled)
	local minimap = CHUDGetOption("minimap")
	originalSetHUDMap(self, minimap)
	if self.CHUDLocationText then
		self.CHUDLocationText:SetIsVisible(minimap)
	end
end)

local originalShowNewArmorLevel		
originalShowNewArmorLevel = Class_ReplaceMethod( "GUIMarineHUD", "ShowNewArmorLevel",
function(self, armorLevel)
	local uplvl = CHUDGetOption("uplvl")
	if uplvl == 0 then
		self.armorLevel:SetTexture("ui/blank.dds")
	elseif uplvl == 1 then
		originalShowNewArmorLevel(self, armorLevel)
		self.armorLevel:SetTexture(GUIMarineHUD.kUpgradesTexture)
	elseif uplvl == 2 then
		self.armorLevel:SetTexture("ui/chud_upgradeicons.dds")
		local x1 = armorLevel * 80 - 80
		local x2 = x1 + 80
		local textureCoords = { x1, 0, x2, 80 }
		self.armorLevel:SetTexturePixelCoordinates(unpack(textureCoords))
	end
end)
			
local originalShowNewWeaponLevel
originalShowNewWeaponLevel = Class_ReplaceMethod( "GUIMarineHUD", "ShowNewWeaponLevel",
function(self, weaponLevel)
	local uplvl = CHUDGetOption("uplvl")
	if uplvl == 0 then
		self.weaponLevel:SetTexture("ui/blank.dds")
	elseif uplvl == 1 then
		originalShowNewWeaponLevel(self, weaponLevel)
		self.weaponLevel:SetTexture(GUIMarineHUD.kUpgradesTexture)
	elseif uplvl == 2 then
		self.weaponLevel:SetTexture("ui/chud_upgradeicons.dds")
		local x1 = 160 + weaponLevel * 80
		local x2 = x1 + 80
		local textureCoords = { x1, 0, x2, 80 }
		self.weaponLevel:SetTexturePixelCoordinates(unpack(textureCoords))
	end
end)

local originalMarineChanged
originalMarineChanged = Class_ReplaceMethod( "GUIMarineHUD", "OnLocalPlayerChanged",
	function(self, newPlayer)

		originalMarineChanged(self, newPlayer)
	
		if not newPlayer:isa("Exo") then
			self:SetFrameVisible(not CHUDGetOption("mingui"))
		end
	end)
	
local originalTriggerInit
originalTriggerInit = Class_ReplaceMethod( "GUIMarineHUD", "TriggerInitAnimations",
	function(self)

		if not CHUDGetOption("mingui") then
			originalTriggerInit(self)
		end
	
	end)

local originalMarineHUDUpdate
originalMarineHUDUpdate = Class_ReplaceMethod( "GUIMarineHUD", "Update",
	function(self, deltaTime)
		local mingui = not CHUDGetOption("mingui")
		local showcomm = CHUDGetOption("showcomm")
		local rtcount = CHUDGetOption("rtcount")
		local commactions = CHUDGetOption("commactions")
		local gametime = CHUDGetOption("gametime")
		local hpbar = CHUDGetOption("hpbar")

		// Non-stupid location text!
		local locationName = ConditionalValue(PlayerUI_GetLocationName(), string.upper(PlayerUI_GetLocationName()), "")
			
		if self.lastLocationText ~= locationName and self.CHUDLocationText then
			self.CHUDLocationText:SetText(locationName)
			self.lastLocationText = locationName
		end
		
		originalMarineHUDUpdate(self, deltaTime)
		
		if self.gameTime then
			self.gameTime:SetText(CHUDGetGameTime())
			self.gameTime:SetIsVisible(gametime)
		end
		
		// Minimal HUD pls go home, you're drunk
		// Run this again so WE choose if we want to toggle it or not
        if Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Minimal then
			local notification = PlayerUI_GetRecentNotification()
			
			self.eventDisplay:Update(Client.GetTime() - self.lastNotificationUpdate, { notification, PlayerUI_GetRecentPurchaseable() } )
			self.lastNotificationUpdate = Client.GetTime()
		end
		
		self.inventoryDisplay:SetIsVisible(mingui)

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
		
		// Commander name / TRes
		self.commanderName:SetIsVisible(showcomm)
		self.resourceDisplay.teamText:SetIsVisible(showcomm)

		self.eventDisplay.notificationFrame:SetIsVisible(commactions)
		
		// Disable that rotating border around the HP Bars if we have MinGUI or disabled bars
		if not mingui or not hpbar then
			self.statusDisplay.healthBorderMask:SetColor(Color(1,1,1,0))
			self.statusDisplay.armorBorderMask:SetColor(Color(1,1,1,0))
		end
		
		// In vanilla, the commander name doesn't get updated (or show!) if we use their minimal HUD
		// Make it run again! Let us choose! Power to the people!
		// Update commander name
		local commanderName = PlayerUI_GetCommanderName()
		
		if Client.GetOptionInteger("hudmode", kHUDMode.Full) ~= kHUDMode.Full then
			
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
	end)
	
local originalMarineUninit
originalMarineUninit = Class_ReplaceMethod( "GUIMarineHUD", "Uninitialize",
function(self)
	originalMarineUninit(self)
	
	GUI.DestroyItem(self.CHUDLocationText)
	GUI.DestroyItem(self.gameTime)
	self.CHUDLocationText = nil
	self.gameTime = nil
	self.commanderNameIsAnimating = nil
	self.lastCommanderName = nil
	
end)

local originalMarineReset
originalMarineReset = Class_ReplaceMethod( "GUIMarineHUD", "Reset",
function(self)
	originalMarineReset(self)
	
	self:CHUDRepositionGUI()
end)

if not GUIMarineTeamMessage then
	Script.Load("lua/GUIMarineTeamMessage.lua")
end
local originalMarineMessage
originalMarineMessage = Class_ReplaceMethod( "GUIMarineTeamMessage", "SetTeamMessage",
	function(self, message)
		originalMarineMessage(self, message)
		if not CHUDGetOption("banners") then
			self.background:SetIsVisible(false)
		end
		if CHUDGetOption("mingui") then
			self.background:DestroyAnimations()
		end
	end
)