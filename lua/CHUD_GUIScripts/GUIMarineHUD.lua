local originalMarineInit
originalMarineInit = Class_ReplaceMethod( "GUIMarineHUD", "Initialize",
function(self)
	originalMarineInit(self)
	
	// Make the location text non-stupid
	self.locationText:SetIsVisible(false)
	
    self.CHUDLocationText = GUIManager:CreateTextItem()
    self.CHUDLocationText:SetFontName(GUIMarineHUD.kTextFontName)
    self.CHUDLocationText:SetTextAlignmentX(GUIItem.Align_Min)
    self.CHUDLocationText:SetTextAlignmentY(GUIItem.Align_Min)
    self.CHUDLocationText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.CHUDLocationText:SetLayer(kGUILayerPlayerHUDForeground2)
    self.CHUDLocationText:SetColor(kBrightColor)
    self.CHUDLocationText:SetFontIsBold(true)
	self.CHUDLocationText:SetScale(GUIScale(Vector(1,1,0)))
	self.CHUDLocationText:SetPosition(GUIScale(Vector(60, 36, 0)))
    self.background:AddChild(self.CHUDLocationText)
	
	// Initialize location and power so they show up correctly
	self.lastLocationText = ""
	self.lastPowerState = 0
	
	if CHUDGetOption("mingui") then
		self.minimapBackground:SetColor(Color(1,1,1,0))
		self.minimapScanLines:SetColor(Color(1,1,1,0))
		self.resourceDisplay.background:SetColor(Color(1,1,1,0))
		
		// Make minimap square when having Minimal GUI on
		self.minimapStencil:SetTexture("ui/chud_square_minimap_stencil.dds")
	end
	
end)

local originalResetMinimap
originalResetMinimap = Class_ReplaceMethod( "GUIMarineHUD", "ResetMinimap",
function(self)
	originalResetMinimap(self)
	// It's already being scaled in the original script, we just need to adjust the position
	self.minimapPower:SetPosition(Vector(0, -34, 0))
end)

local originalSetHUDMap
originalSetHUDMap = Class_ReplaceMethod( "GUIMarineHUD", "SetHUDMapEnabled",
function(self, enabled)
	originalSetHUDMap(self, CHUDGetOption("minimap"))
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
		// Non-stupid location text!
		local locationName = ConditionalValue(PlayerUI_GetLocationName(), string.upper(PlayerUI_GetLocationName()), "")
			
		if self.lastLocationText ~= locationName and self.CHUDLocationText then
			self.CHUDLocationText:SetText(locationName)
			self.lastLocationText = locationName
		end
		
		originalMarineHUDUpdate(self, deltaTime)
		
		self.inventoryDisplay:SetIsVisible(not CHUDGetOption("mingui"))

		if not CHUDGetOption("rtcount") then
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
		self.commanderName:SetIsVisible(CHUDGetOption("showcomm"))
		
		// In vanilla, the commander name doesn't get updated (or show!) if we use their minimal HUD
		// Make it run again! Let us choose! Power to the people!		
		if Client.GetOptionInteger("hudmode", kHUDMode.Full) ~= kHUDMode.Full then
			// Update commander name
			local commanderName = PlayerUI_GetCommanderName()
			
			if commanderName == nil then
			
				commanderName = Locale.ResolveString("NO_COMMANDER")
				
				if not self.commanderNameIsAnimating then
				
					self.commanderNameIsAnimating = true
					self.commanderName:SetColor(Color(1, 0, 0, 1))
					self.commanderName:FadeOut(1, nil, AnimateLinear, AnimFadeIn)
					
				end
				
			else
			
				commanderName = Locale.ResolveString("COMMANDER") .. commanderName
			
				if self.commanderNameIsAnimating then
				
					self.commanderNameIsAnimating = false
					self.commanderName:DestroyAnimations()
					self.commanderName:SetColor(GUIMarineHUD.kActiveCommanderColor)
					
				end
				
			end
			
			commanderName = string.upper(commanderName)
			if self.lastCommanderName ~= commanderName then
			
				self.commanderName:DestroyAnimation("COMM_TEXT_WRITE")
				self.commanderName:SetText("")
				self.commanderName:SetText(commanderName, 0.5, "COMM_TEXT_WRITE")
				self.lastCommanderName = commanderName
				
			end
		end
	end)