local mainMenu

local function CHUDHitIndicatorSlider()
	if mainMenu ~= nil and mainMenu.optionElements ~= nil then
		local value = mainMenu.optionElements.CHUDHitIndicator:GetValue()
		Client.SetOptionFloat("CHUD_HitIndicator", value)
		CHUDSettings["hitindicator"] = value
		Player.kShowGiveDamageTime = value
	end
end

local function CHUDSaveMenuSettings()
	if mainMenu ~= nil and mainMenu.optionElements ~= nil then
		Client.SetOptionBoolean("CHUD_ScorePopup", mainMenu.optionElements.CHUDScore:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_Waypoints", mainMenu.optionElements.CHUDWaypoints:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_MinWaypoints", mainMenu.optionElements.CHUDMinWaypoints:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_Blur", mainMenu.optionElements.CHUDBlur:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_Banners", mainMenu.optionElements.CHUDBanners:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_RTcount", mainMenu.optionElements.CHUDRTcount:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_MinGUI", mainMenu.optionElements.CHUDMinGUI:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_Minimap", mainMenu.optionElements.CHUDMinimap:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_ShowComm", mainMenu.optionElements.CHUDShowComm:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_Unlocks", mainMenu.optionElements.CHUDUnlocks:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_HPBar", mainMenu.optionElements.CHUDHPBar:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_MinNameplates", mainMenu.optionElements.CHUDMinNameplates:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_SmallNameplates", mainMenu.optionElements.CHUDSmallNameplates:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_Tracers", mainMenu.optionElements.CHUDTracers:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_KDA", mainMenu.optionElements.CHUDKDA:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_SmallDMG", mainMenu.optionElements.CHUDSmallDMG:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_Particles", mainMenu.optionElements.CHUDParticles:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_Gametime", mainMenu.optionElements.CHUDGametime:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_Assists", mainMenu.optionElements.CHUDAssists:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_Ambient", mainMenu.optionElements.CHUDAmbient:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("lowLights", mainMenu.optionElements.CHUDNSLLights:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_Friends", mainMenu.optionElements.CHUDFriends:GetActiveOptionIndex() > 1)
		Client.SetOptionInteger("CHUD_AV", mainMenu.optionElements.CHUDAV:GetActiveOptionIndex()-1)
		Client.SetOptionBoolean("CHUD_UpLVL", mainMenu.optionElements.CHUDUpLVL:GetActiveOptionIndex() > 1)
		Client.SetOptionBoolean("CHUD_ClassicAmmo", mainMenu.optionElements.CHUDClassicAmmo:GetActiveOptionIndex() > 1)
		Client.SetOptionFloat("CHUD_HitIndicator", mainMenu.optionElements.CHUDHitIndicator:GetValue())
		Client.SetOptionBoolean("CHUD_AutoWPs", mainMenu.optionElements.CHUDAutoWPs:GetActiveOptionIndex() > 1)
		
		GetCHUDSettings()
		ApplyCHUDSettings()
		// Not even going to bother checking if we really changed the light setting, Just Do It(TM)
		lowLightsSwitched = false
		CHUDLoadLights()
		SetCHUDCinematics()
	end
end

local CHUDOptions = {
			{
				name    = "CHUDScore",
				label   = "SCORE POPUP (+5)",
				tooltip = "Disables or enables score popup (+5)",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			
			{
				name    = "CHUDWaypoints",
				label   = "WAYPOINTS",
				tooltip = "Disables or enables all waypoints except Attack orders (waypoints can still be seen on minimap)",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			},   
			
			{
				name    = "CHUDMinWaypoints",
				label   = "MINIMAL WAYPOINTS",
				tooltip = "Removes all text/backgrounds and only leaves the waypoint icon",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			},  
			
			{
				name    = "CHUDBlur",
				label   = "BLUR",
				tooltip = "Removes the background blur from menus/minimap",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			},  
			
			{
				name    = "CHUDBanners",
				label   = "OBJECTIVE BANNERS",
				tooltip = "Removes the banners in the center of the screen (\"Commander needed\", \"Power node under attack\", \"Evolution lost\", etc.)",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			},  
			
			{
				name    = "CHUDRTcount",
				label   = "RT COUNT DOTS",
				tooltip = "Removes RT count dots at the bottom and replaces them with a number",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			},  
			
			{
				name    = "CHUDMinGUI",
				label   = "MINIMAL GUI",
				tooltip = "Removes backgrounds/scanlines from all UI elements",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			},  
			
			{
				name    = "CHUDMinimap",
				label   = "MARINE MINIMAP",
				tooltip = "Removes the entire top left of the screen for the marines (minimap, comm name, team res, comm actions)",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			
			{
				name    = "CHUDShowComm",
				label   = "MARINE COMM NAME",
				tooltip = "Forces showing the commander and resources when disabling the minimap",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			
			{
				name    = "CHUDUnlocks",
				label   = "RESEARCH NOTIFICATIONS",
				tooltip = "Removes the research completed notifications on the right side of the screen",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 

			
			{
				name    = "CHUDHPBar",
				label   = "MARINE HP BARS",
				tooltip = "Removes the health bars from the marine HUD",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
				
			{
				name    = "CHUDMinNameplates",
				label   = "MINIMAL NAMEPLATES",
				tooltip = "Removes building names and health/armor bars and replaces them with a simple %",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 	
			
			{
				name    = "CHUDSmallNameplates",
				label   = "SMALL NAMEPLATES",
				tooltip = "Makes fonts in the nameplates smaller",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			
			{
				name    = "CHUDTracers",
				label   = "WEAPON TRACERS",
				tooltip = "Disables weapon tracers",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			
			{
				name    = "CHUDKDA",
				label   = "KDA/KAD",
				tooltip = "Switches the scoreboard from KAD to KDA",
				type    = "select",
				values  = { "KAD", "KDA" },
				callback = CHUDSaveMenuSettings
			}, 
			
			{
				name    = "CHUDSmallDMG",
				label   = "SMALL DAMAGE NUMBERS",
				tooltip = "Makes the damage numbers smaller",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			{
				name    = "CHUDParticles",
				label   = "MINIMAL PARTICLES",
				tooltip = "Reduces particle clutter",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			{
				name    = "CHUDGametime",
				label   = "GAME TIME",
				tooltip = "Adds or removes the game time on the top left (requires having the commander name as marines)",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			{
				name    = "CHUDAssists",
				label   = "ASSIST SCORE POPUP",
				tooltip = "Removes assist score popup",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			{
				name    = "CHUDAmbient",
				label   = "AMBIENT SOUNDS",
				tooltip = "Removes map ambient sounds. You can also remove all the ambient sounds during the game by typing \"stopsound\" in console.",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			{
				name    = "CHUDNSLLights",
				label   = "NSL LOW LIGHTS",
				tooltip = "Replaces the low quality option lights with the NSL lights.",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			{
				name    = "CHUDFriends",
				label   = "FRIENDS HIGHLIGHTING",
				tooltip = "Enables or disables the friend highlighting in the scoreboard/nameplates.",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			{
				name    = "CHUDAV",
				label   = "ALIEN VISION",
				tooltip = "Lets you choose between different Alien Vision types",
				type    = "select",
				values  = { "DEFAULT", "HUZE'S OLD AV", "HUZE'S MINIMAL AV" },
				callback = CHUDSaveMenuSettings
			}, 
			{
				name    = "CHUDUpLVL",
				label   = "UPGRADE INDICATOR",
				tooltip = "Toggles the weapon/armor level indicator on the right side of the marine HUD.",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			}, 
			{
				name    = "CHUDClassicAmmo",
				label   = "CLASSIC AMMO COUNTER",
				tooltip = "Toggles a classic ammo counter on the bottom right of the HUD.",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
			},
            { 
                name    = "CHUDHitIndicator",
                label   = "HIT INDICATOR FADE TIME",
				tooltip = "Controls the speed of the crosshair hit indicator.",
                type    = "slider",
				sliderCallback = CHUDHitIndicatorSlider,
            },
            { 
                name    = "CHUDAutoWPs",
                label   = "AUTOMATIC WAYPOINTS",
				tooltip = "Enables or disables automatic waypoints (not given by the commander).",
				type    = "select",
				values  = { "OFF", "ON" },
				callback = CHUDSaveMenuSettings
            },
			
		}
		
local function BoolToIndex(value)
	if value then
		return 2
	end
	return 1
end
		
originalMenuCreateOptions = Class_ReplaceMethod( "GUIMainMenu", "CreateOptionsForm",
	function(mainMenu, content, options, optionElements)
		if options[1]["name"] == "NickName" then
			for i, entry in pairs(CHUDOptions) do
				table.insert(options, entry)
			end		
		end
		local form = originalMenuCreateOptions(mainMenu, content, options, optionElements)
		// Set appropriate size without CSS
		form:SetHeight(#options*50)
		return form
	end)
	
originalCreateOptionWindow = Class_ReplaceMethod( "GUIMainMenu", "CreateOptionWindow",
	function(self)
		originalCreateOptionWindow(self)
		
		GetCHUDSettings()
		
		self.optionElements.CHUDScore:SetOptionActive( BoolToIndex(CHUDSettings["score"]) )
		self.optionElements.CHUDWaypoints:SetOptionActive( BoolToIndex(CHUDSettings["waypoints"]) )
		self.optionElements.CHUDMinWaypoints:SetOptionActive( BoolToIndex(CHUDSettings["minwps"]) )
		self.optionElements.CHUDBlur:SetOptionActive( BoolToIndex(CHUDSettings["blur"]) )
		self.optionElements.CHUDBanners:SetOptionActive( BoolToIndex(CHUDSettings["banners"]) )
		self.optionElements.CHUDRTcount:SetOptionActive( BoolToIndex(CHUDSettings["rtcount"]) )
		self.optionElements.CHUDMinGUI:SetOptionActive( BoolToIndex(CHUDSettings["mingui"]) )
		self.optionElements.CHUDMinimap:SetOptionActive( BoolToIndex(CHUDSettings["minimap"]) )
		self.optionElements.CHUDShowComm:SetOptionActive( BoolToIndex(CHUDSettings["showcomm"]) )
		self.optionElements.CHUDUnlocks:SetOptionActive( BoolToIndex(CHUDSettings["unlocks"]) )
		self.optionElements.CHUDHPBar:SetOptionActive( BoolToIndex(CHUDSettings["hpbar"]) )
		self.optionElements.CHUDMinNameplates:SetOptionActive( BoolToIndex(CHUDSettings["minnps"]) )
		self.optionElements.CHUDSmallNameplates:SetOptionActive( BoolToIndex(CHUDSettings["smallnps"]) )
		self.optionElements.CHUDTracers:SetOptionActive( BoolToIndex(CHUDSettings["tracers"]) )
		self.optionElements.CHUDKDA:SetOptionActive( BoolToIndex(CHUDSettings["kda"]) )
		self.optionElements.CHUDSmallDMG:SetOptionActive( BoolToIndex(CHUDSettings["smalldmg"]) )
		self.optionElements.CHUDParticles:SetOptionActive( BoolToIndex(CHUDSettings["particles"]) )
		self.optionElements.CHUDGametime:SetOptionActive( BoolToIndex(CHUDSettings["gametime"]) )
		self.optionElements.CHUDAssists:SetOptionActive( BoolToIndex(CHUDSettings["assists"]) )
		self.optionElements.CHUDAmbient:SetOptionActive( BoolToIndex(CHUDSettings["ambient"]) )
		self.optionElements.CHUDNSLLights:SetOptionActive( BoolToIndex(CHUDSettings["nsllights"]) )
		self.optionElements.CHUDFriends:SetOptionActive( BoolToIndex(CHUDSettings["friends"]) )
		self.optionElements.CHUDAV:SetOptionActive( CHUDSettings["av"]+1 )
		self.optionElements.CHUDUpLVL:SetOptionActive( BoolToIndex(CHUDSettings["uplvl"]) )
		self.optionElements.CHUDClassicAmmo:SetOptionActive( BoolToIndex(CHUDSettings["classicammo"]) )
		self.optionElements.CHUDHitIndicator:SetValue( CHUDSettings["hitindicator"] )
		self.optionElements.CHUDAutoWPs:SetOptionActive( BoolToIndex(CHUDSettings["autowps"]) )
		
		mainMenu = self
	end)