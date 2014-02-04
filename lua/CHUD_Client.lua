Script.Load("lua/CHUD_Utility.lua")
Script.Load("lua/CHUD_MainMenu.lua")
Script.Load("lua/CHUD_Lights.lua")
Script.Load("lua/CHUD_UnitStatus.lua")
Script.Load("lua/CHUD_HUDElements.lua")
Script.Load("lua/CHUD_GUIScripts.lua")
Script.Load("lua/CHUD_Tracers.lua")
Script.Load("lua/CHUD_Particles.lua")
Script.Load("lua/CHUD_ScoreDisplay.lua")

function ApplyCHUDSettings()
	for name, script in pairs(GetGUIManager().scripts) do
		ApplyCHUD(script, script._scriptName)
	end
end

function GetCHUDSettings()
	CHUDSettings = {
		assists = Client.GetOptionBoolean("CHUD_Assists", true),
		av = Client.GetOptionBoolean("CHUD_AV", false),
		banners = Client.GetOptionBoolean("CHUD_Banners", true),
		blur = Client.GetOptionBoolean("CHUD_Blur", true),
		gametime = Client.GetOptionBoolean("CHUD_Gametime", false),
		hpbar = Client.GetOptionBoolean("CHUD_HPBar", true),
		kda = Client.GetOptionBoolean("CHUD_KDA", false),
		mingui = Client.GetOptionBoolean("CHUD_MinGUI", false),
		minimap = Client.GetOptionBoolean("CHUD_Minimap", true),
		minnps = Client.GetOptionBoolean("CHUD_MinNameplates", false),
		minwps = Client.GetOptionBoolean("CHUD_MinWaypoints", false),
		particles = Client.GetOptionBoolean("CHUD_Particles", false),
		rtcount = Client.GetOptionBoolean("CHUD_RTcount", true),
		score = Client.GetOptionBoolean("CHUD_ScorePopup", true),
		showcomm = Client.GetOptionBoolean("CHUD_ShowComm", false),
		smalldmg = Client.GetOptionBoolean("CHUD_SmallDMG", false),
		smallnps = Client.GetOptionBoolean("CHUD_SmallNameplates", false),
		tracers = Client.GetOptionBoolean("CHUD_Tracers", true),
		unlocks = Client.GetOptionBoolean("CHUD_Unlocks", true),
		wps = Client.GetOptionBoolean("CHUD_Waypoints", true),
		dmgcolor_m = Client.GetOptionInteger("CHUD_DMGColorM", bit.lshift(77, 16) + bit.lshift(219, 8) + 255),
		dmgcolor_a = Client.GetOptionInteger("CHUD_DMGColorA", bit.lshift(255, 16) + bit.lshift(202, 8) + 58),
		alienbars = Client.GetOptionBoolean("CHUD_AlienBars", false),
		ambient = Client.GetOptionBoolean("CHUD_Ambient", true),
		nsllights = Client.GetOptionBoolean("lowLights", false)
	}
end

function ApplyCHUD(script, scriptName)
	
		if scriptName == "GUIMarineHUD" then
			if CHUDSettings["showcomm"] and not CHUDSettings["minimap"] then
				GUIPlayerResource.kTeamTextPos = Vector(20, 76, 0)
			else
				GUIPlayerResource.kTeamTextPos = Vector(20, 360, 0)
			end
						
			script:Uninitialize()
			script:Initialize()
				
			if CHUDSettings["mingui"] then
				if CHUDSettings["minimap"] then
					script.minimapBackground:SetColor(Color(1,1,1,0))
					script.minimapScanLines:SetColor(Color(1,1,1,0))
				end
				script.topLeftFrame:SetIsVisible(false)
				script.topRightFrame:SetIsVisible(false)
				script.bottomLeftFrame:SetIsVisible(false)
				script.bottomRightFrame:SetIsVisible(false)
				script.inventoryDisplay:SetIsVisible(false)
				script.resourceDisplay.background:SetColor(Color(1,1,1,0))
			end

			script:SetHUDMapEnabled(CHUDSettings["minimap"])
			script.locationText:SetIsVisible(CHUDSettings["minimap"])

			if CHUDSettings["showcomm"] and not CHUDSettings["minimap"] then
				script.commanderName:SetIsVisible(true)
				script.commanderName:SetPosition(Vector(20, 46, 0))
			end

			// The weapon upgrade icon gets corrupted after reinitializing this script. We reapply this.
			script:ShowNewWeaponLevel(PlayerUI_GetWeaponLevel())
			
		elseif scriptName == "GUIAlienHUD" then
			// Move the team res to a reasonable position instead of the marine default
			GUIPlayerResource.kTeamTextPos = Vector(20, 76, 0)
			
			// Oma's alien bars
			local kTextureNameCHUD
			local OMATextureName = PrecacheAsset("ui/oma_alien_hud_health.dds")
			local kTextureNameOrig = PrecacheAsset("ui/alien_hud_health.dds")
			
			if CHUDSettings["alienbars"] then
				kTextureNameCHUD = OMATextureName
			else
				kTextureNameCHUD = kTextureNameOrig
			end
			
			// Backgrounds of health/energy
			local CHUDSmokeSize
			if CHUDSettings["mingui"] then
				CHUDSmokeSize = 0
			else
				CHUDSmokeSize = 128
			end
			ReplaceLocals(GUIAlienHUD.CreateHealthBall, {kHealthBackgroundTextureX2 = CHUDSmokeSize, kHealthBackgroundTextureY2 = CHUDSmokeSize, kTextureName = kTextureNameCHUD})
			ReplaceLocals(GUIAlienHUD.CreateEnergyBall, {kHealthBackgroundTextureX2 = CHUDSmokeSize, kHealthBackgroundTextureY2 = CHUDSmokeSize, kTextureName = kTextureNameCHUD, kEnergyBackgroundOffset = Vector(-160-94, -62, 0),
				energyBallSettings = {
					BackgroundWidth = GUIScale(160),
					BackgroundHeight = GUIScale(160),
					BackgroundAnchorX = GUIItem.Right,
					BackgroundAnchorY = GUIItem.Bottom,
					BackgroundOffset = Vector(-160 - 45, -50, 0),
					BackgroundTextureName = kTextureNameCHUD,
					BackgroundTextureX1 = 0,
					BackgroundTextureY1 = 0,
					BackgroundTextureX2 = CHUDSmokeSize,
					BackgroundTextureY2 = CHUDSmokeSize,
					ForegroundTextureName = kTextureNameCHUD,
					ForegroundTextureWidth = 128,
					ForegroundTextureHeight = 128,
					ForegroundTextureX1 = 0,
					ForegroundTextureY1 = 128,
					ForegroundTextureX2 = 128,
					ForegroundTextureY2 = 256,
					InheritParentAlpha = true,
					ForegroundTextureX1 = 0,
					ForegroundTextureY1 = 128,
					ForegroundTextureX2 = 128,
					ForegroundTextureY2 = 256
					}
				}
			)
			script:Uninitialize()
			script:Initialize()
			if CHUDSettings["mingui"] then
				script.resourceDisplay.background:SetColor(Color(1,1,1,0))
			else
				script.resourceDisplay.background:SetColor(Color(1,1,1,1))
			end
					
/*			if not CHUDSettings["av"] then
				Client.DestroyScreenEffect(Player.screenEffects.darkVision)
				Player.screenEffects.darkVision = Client.CreateScreenEffect("shaders/DarkVision.screenfx")
			else
				Client.DestroyScreenEffect(Player.screenEffects.darkVision)
				Player.screenEffects.darkVision = Client.CreateScreenEffect("shaders/HuzeOldAV.screenfx")
			end*/
			
		elseif scriptName == "GUIUnitStatus" then
			if CHUDSettings["smallnps"] then
				GUIUnitStatus.kFontScale = GUIScale( Vector(1,1,1) ) * 0.8
				GUIUnitStatus.kActionFontScale = GUIScale( Vector(1,1,1) ) * 0.7
				GUIUnitStatus.kFontScaleProgress = GUIScale( Vector(1,1,1) ) * 0.6
				GUIUnitStatus.kFontScaleSmall = GUIScale( Vector(1,1,1) ) * 0.65
			else
				GUIUnitStatus.kFontScale = GUIScale( Vector(1,1,1) ) * 1.2
				GUIUnitStatus.kActionFontScale = GUIScale( Vector(1,1,1) )
				GUIUnitStatus.kFontScaleProgress = GUIScale( Vector(1,1,1) ) * 0.8
				GUIUnitStatus.kFontScaleSmall = GUIScale( Vector(1,1,1) ) * 0.9
			end
			script:Uninitialize()
			script:Initialize()
		
		elseif scriptName == "GUIScoreboard" then
			Script.Load("lua/CHUD_SBInject.lua")
			script:Uninitialize()
			script:Initialize()			
			
		elseif scriptName == "GUIBioMassDisplay" then
			if CHUDSettings["mingui"] then
				script.smokeyBackground:SetIsVisible(false)
				script.background:SetTexture("ui/blank.dds")
			else
				script.smokeyBackground:SetIsVisible(true)
				script.background:SetTexture("ui/biomass_bar.dds")
			end
		end
		
		if not CHUDSettings["ambient"] then
			OnCommandCHUDStopSound()
		end
			
end

function OnCommandCHUDHelp()
	Shared.Message("-------------------------------------")
	Shared.Message("Custom HUD Commands")
	Shared.Message("-------------------------------------")
	Shared.Message("chud_alienbars: Switches between default health/energy circles or thicker with gradients made by Oma")
	Shared.Message("chud_ambient: Removes map ambient sounds. You can also remove all the ambient sounds during the game by typing \"stopsound\" in console.")
	Shared.Message("chud_assists: Removes assist score popup")
	Shared.Message("chud_banners: Removes the banners in the center of the screen (\"Commander needed\", \"Power node under attack\", \"Evolution lost\", etc.)")
	Shared.Message("chud_blur: Removes the background blur from menus/minimap")
	Shared.Message("chud_dmgcolor_a: Alien damage numbers color. Either RGB or Hex values accepted. For example, you can enter red as 255 0 0 or 0xFF0000.")
	Shared.Message("chud_dmgcolor_m: Marine damage numbers color. Either RGB or Hex values accepted. For example, you can enter red as 255 0 0 or 0xFF0000.")
	Shared.Message("chud_dmgcolor_reset: Reset damage numbers colors to the default on both aliens and marines.")
	Shared.Message("chud_gametime: Adds or removes the game time on the top left (requires having the commander name as marines)")
	Shared.Message("chud_hpbar: Removes the health bars from the marine HUD")
	Shared.Message("chud_kda: Switches the scoreboard from KAD to KDA")
	Shared.Message("chud_lowlights: Changes between the default map low quality lights and the NSL lights")
	Shared.Message("chud_mingui: Removes backgrounds/scanlines from all UI elements")
	Shared.Message("chud_minimap: Removes the entire top left of the screen for the marines (minimap, comm name, team res, comm actions)")
	Shared.Message("chud_minnps: Removes building names and health/armor bars and replaces them with a simple %")
	Shared.Message("chud_minwps: Removes all text/backgrounds and only leaves the waypoint icon")
	Shared.Message("chud_particles: Reduces particle clutter")
	Shared.Message("chud_rtcount: Removes RT count dots at the bottom and replaces them with a number")
	Shared.Message("chud_score: Disables score popup (+5)")
	Shared.Message("chud_showcomm: Forces showing the commander and resources when disabling the minimap")
	Shared.Message("chud_smalldmg: Makes the damage numbers smaller")
	Shared.Message("chud_smallnps: Makes fonts in the nameplates smaller")
	Shared.Message("chud_tracers: Disables weapon tracers")
	Shared.Message("chud_unlocks: Removes the research completed notifications on the right side of the screen")
	Shared.Message("chud_wps: Disables all waypoints except Attack orders (waypoints can still be seen on minimap)")
	Shared.Message("-------------------------------------")
end

function AnnounceCHUD()
	Shared.Message("Custom HUD mod loaded. Type \"chud\" in console for available commands. You can also customize your HUD from your options menu.")
	GetCHUDSettings()
end

function OnCommandCHUDRTcount()
	if Client.GetOptionBoolean("CHUD_RTcount", true) then
		Client.SetOptionBoolean("CHUD_RTcount", false)
		Shared.Message("RT count disabled.")		
	else
		Client.SetOptionBoolean("CHUD_RTcount", true)
		Shared.Message("RT count enabled.")
	end
	CHUDSettings["rtcount"] = Client.GetOptionBoolean("CHUD_RTcount", true)
end

function OnCommandCHUDMinGUI()
	if Client.GetOptionBoolean("CHUD_MinGUI", false) then
		Client.SetOptionBoolean("CHUD_MinGUI", false)
		Shared.Message("Minimal GUI disabled.")
	else
		Client.SetOptionBoolean("CHUD_MinGUI", true)
		Shared.Message("Minimal GUI enabled.")
	end
	CHUDSettings["mingui"] = Client.GetOptionBoolean("CHUD_MinGUI", false)
	ApplyCHUDSettings()
end

function OnCommandCHUDMinimap()
	if Client.GetOptionBoolean("CHUD_Minimap", true) then
		Client.SetOptionBoolean("CHUD_Minimap", false)	
		Shared.Message("Minimap disabled.")		
	else
		Client.SetOptionBoolean("CHUD_Minimap", true)
		Shared.Message("Minimap enabled.")
	end
	CHUDSettings["minimap"] = Client.GetOptionBoolean("CHUD_Minimap", true)
	ApplyCHUDSettings()
end

function OnCommandCHUDShowComm()
	if Client.GetOptionBoolean("CHUD_ShowComm", false) then
		Client.SetOptionBoolean("CHUD_ShowComm", false)	
		Shared.Message("Commander name disabled.")
	else
		Client.SetOptionBoolean("CHUD_ShowComm", true)
		Shared.Message("Commander name enabled.")
	end
	CHUDSettings["showcomm"] = Client.GetOptionBoolean("CHUD_ShowComm", false)
	ApplyCHUDSettings()
end

function OnCommandCHUDUnlocks()
	if Client.GetOptionBoolean("CHUD_Unlocks", true) then
		Client.SetOptionBoolean("CHUD_Unlocks", false)	
		Shared.Message("Research notifications disabled.")		
	else
		Client.SetOptionBoolean("CHUD_Unlocks", true)
		Shared.Message("Research notifications enabled.")
	end
	CHUDSettings["unlocks"] = Client.GetOptionBoolean("CHUD_Unlocks", true)
end

function OnCommandCHUDHPBar()
	if Client.GetOptionBoolean("CHUD_HPBar", true) then
		Client.SetOptionBoolean("CHUD_HPBar", false)	
		Shared.Message("Health bars disabled.")		
	else
		Client.SetOptionBoolean("CHUD_HPBar", true)
		Shared.Message("Health bars enabled.")
	end
	CHUDSettings["hpbar"] = Client.GetOptionBoolean("CHUD_HPBar", true)
	ApplyCHUDSettings()
end

function OnCommandCHUDMinNPs()
	if Client.GetOptionBoolean("CHUD_MinNameplates", false) then
		Client.SetOptionBoolean("CHUD_MinNameplates", false)	
		Shared.Message("Minimal nameplates disabled.")		
	else
		Client.SetOptionBoolean("CHUD_MinNameplates", true)
		Shared.Message("Minimal nameplates enabled.")
	end
	CHUDSettings["minnps"] = Client.GetOptionBoolean("CHUD_MinNameplates", false)
end

function OnCommandCHUDSmallNPs()
	if Client.GetOptionBoolean("CHUD_SmallNameplates", false) then
		Client.SetOptionBoolean("CHUD_SmallNameplates", false)	
		Shared.Message("Smaller font nameplates disabled.")		
	else
		Client.SetOptionBoolean("CHUD_SmallNameplates", true)
		Shared.Message("Smaller font nameplates enabled.")
	end
	CHUDSettings["smallnps"] = Client.GetOptionBoolean("CHUD_SmallNameplates", false)
	ApplyCHUDSettings()
end

function OnCommandCHUDScore()
	if Client.GetOptionBoolean("CHUD_ScorePopup", true) then
		Client.SetOptionBoolean("CHUD_ScorePopup", false)	
		Shared.Message("Score popup disabled.")		
	else
		Client.SetOptionBoolean("CHUD_ScorePopup", true)
		Shared.Message("Score popup enabled.")
	end
	CHUDSettings["score"] = Client.GetOptionBoolean("CHUD_ScorePopup", true)
end

function OnCommandCHUDWPs()
	if Client.GetOptionBoolean("CHUD_Waypoints", true) then
		Client.SetOptionBoolean("CHUD_Waypoints", false)	
		Shared.Message("Waypoints disabled.")		
	else
		Client.SetOptionBoolean("CHUD_Waypoints", true)
		Shared.Message("Waypoints enabled.")
	end
	CHUDSettings["wps"] = Client.GetOptionBoolean("CHUD_Waypoints", true)
end

function OnCommandCHUDMinWPs()
	if Client.GetOptionBoolean("CHUD_MinWaypoints", false) then
		Client.SetOptionBoolean("CHUD_MinWaypoints", false)	
		Shared.Message("Minimal waypoints disabled.")		
	else
		Client.SetOptionBoolean("CHUD_MinWaypoints", true)
		Shared.Message("Minimal waypoints enabled.")
	end
	CHUDSettings["minwps"] = Client.GetOptionBoolean("CHUD_MinWaypoints", false)
end

function OnCommandCHUDBanners()
	if Client.GetOptionBoolean("CHUD_Banners", true) then
		Client.SetOptionBoolean("CHUD_Banners", false)	
		Shared.Message("Banners disabled.")		
	else
		Client.SetOptionBoolean("CHUD_Banners", true)
		Shared.Message("Banners enabled.")
	end
	CHUDSettings["banners"] = Client.GetOptionBoolean("CHUD_Banners", true)
end

function OnCommandCHUDBlur()
	if Client.GetOptionBoolean("CHUD_Blur", true) then
		Client.SetOptionBoolean("CHUD_Blur", false)	
		Shared.Message("Blur disabled.")		
	else
		Client.SetOptionBoolean("CHUD_Blur", true)
		Shared.Message("Blur enabled.")
	end
	CHUDSettings["blur"] = Client.GetOptionBoolean("CHUD_Blur", true)
end

function OnCommandCHUDKDA()
	if Client.GetOptionBoolean("CHUD_KDA", false) then
		Client.SetOptionBoolean("CHUD_KDA", false)	
		Shared.Message("Scoreboard is now Kills/Assists/Deaths (NS2 Default).")
	else
		Client.SetOptionBoolean("CHUD_KDA", true)
		Shared.Message("Scoreboard is now Kills/Deaths/Assists.")
	end
	CHUDSettings["kda"] = Client.GetOptionBoolean("CHUD_KDA", false)
	ApplyCHUDSettings()
end

function OnCommandCHUDTracers()
	if Client.GetOptionBoolean("CHUD_Tracers", true) then
		Client.SetOptionBoolean("CHUD_Tracers", false)	
		Shared.Message("Weapon tracers disabled.")
	else
		Client.SetOptionBoolean("CHUD_Tracers", true)
		Shared.Message("Weapon tracers enabled.")
	end
	CHUDSettings["tracers"] = Client.GetOptionBoolean("CHUD_Tracers", true)
end

function OnCommandCHUDSmallDMG()
	if Client.GetOptionBoolean("CHUD_SmallDMG", false) then
		Client.SetOptionBoolean("CHUD_SmallDMG", false)	
		Shared.Message("Damage numbers are now default size.")
	else
		Client.SetOptionBoolean("CHUD_SmallDMG", true)
		Shared.Message("Small damage numbers enabled.")
	end
	CHUDSettings["smalldmg"] = Client.GetOptionBoolean("CHUD_SmallDMG", false)
end

function OnCommandCHUDParticles()
	if Client.GetOptionBoolean("CHUD_Particles", false) then
		Client.SetOptionBoolean("CHUD_Particles", false)	
		Shared.Message("Enabled default particles.")
	else
		Client.SetOptionBoolean("CHUD_Particles", true)
		Shared.Message("Enabled minimal particles.")
	end
	CHUDSettings["particles"] = Client.GetOptionBoolean("CHUD_Particles", false)
	SetCHUDCinematics()
end

function OnCommandCHUDGametime()
	if Client.GetOptionBoolean("CHUD_Gametime", false) then
		Client.SetOptionBoolean("CHUD_Gametime", false)	
		Shared.Message("Removed gametime.")
	else
		Client.SetOptionBoolean("CHUD_Gametime", true)
		Shared.Message("Added gametime.")
	end
	CHUDSettings["gametime"] = Client.GetOptionBoolean("CHUD_Gametime", false)
end

function OnCommandCHUDAssists()
	if Client.GetOptionBoolean("CHUD_Assists", true) then
		Client.SetOptionBoolean("CHUD_Assists", false)	
		Shared.Message("Disabled assist popups.")
	else
		Client.SetOptionBoolean("CHUD_Assists", true)
		Shared.Message("Enabled assist popups.")
	end
	CHUDSettings["assists"] = Client.GetOptionBoolean("CHUD_Assists", true)
end

function OnCommandCHUDAV()
	if Client.GetOptionBoolean("CHUD_AV", false) then
		Client.SetOptionBoolean("CHUD_AV", false)	
		Shared.Message("Default Alien Vision enabled.")
	else
		Client.SetOptionBoolean("CHUD_AV", true)
		Shared.Message("Huze's Old Alien Vision enabled.")
	end
	CHUDSettings["av"] = Client.GetOptionBoolean("CHUD_AV", false)
	ApplyCHUDSettings()
end

local function IntFromString(str)

	local num = tonumber(str)
	if num and num >1 then
		num = num/255
	end
	return num

end

local function SetCHUDColor(chudsetkey, chudoptkey, r_or_ColorInt, g, b)
	// chudsetkey: The key for the local array with all the current CHUD settings (ie. CHUDSettings["mingui"])
	// chudoptkey: The name that is used in the options file (Client.SetOption...)
	
	if r_or_ColorInt ~= nil and g == nil then
	
		local ColorInt = tonumber(r_or_ColorInt)
		local color = ColorIntToColor(ColorInt)
		if color then
			Client.SetOptionInteger(chudoptkey, tonumber(r_or_ColorInt))
		end
		
	else
	
		local rInt = IntFromString(r_or_ColorInt) or 1
		local gInt = IntFromString(g) or 1
		local bInt = IntFromString(b) or 1

		// I hate myself a bit for doing this
		Client.SetOptionInteger(chudoptkey, bit.lshift(rInt*255, 16) + bit.lshift(gInt*255, 8) + bInt*255)
		
	end

	CHUDSettings[chudsetkey] = Client.GetOptionInteger(chudoptkey, bit.lshift(77, 16) + bit.lshift(219, 8) + 255)
end

function OnCommandCHUDDMGColorM(r_or_ColorInt, g, b)

	SetCHUDColor("dmgcolor_m", "CHUD_DMGColorM", r_or_ColorInt, g, b)
	
end

function OnCommandCHUDDMGColorA(r_or_ColorInt, g, b)

	SetCHUDColor("dmgcolor_a", "CHUD_DMGColorA", r_or_ColorInt, g, b)
end

function OnCommandCHUDDMGColorReset()
	CHUDSettings["dmgcolor_m"] = bit.lshift(77, 16) + bit.lshift(219, 8) + 255
	Client.SetOptionInteger("CHUD_DMGColorM", bit.lshift(77, 16) + bit.lshift(219, 8) + 255)

	CHUDSettings["dmgcolor_a"] = bit.lshift(255, 16) + bit.lshift(202, 8) + 58
	Client.SetOptionInteger("CHUD_DMGColorA", bit.lshift(255, 16) + bit.lshift(202, 8) + 58)
end

function OnCommandCHUDAlienBars()
	if Client.GetOptionBoolean("CHUD_AlienBars", false) then
		Client.SetOptionBoolean("CHUD_AlienBars", false)	
		Shared.Message("Default Alien bars enabled.")
	else
		Client.SetOptionBoolean("CHUD_AlienBars", true)
		Shared.Message("Oma's Alien bars enabled.")
	end
	CHUDSettings["alienbars"] = Client.GetOptionBoolean("CHUD_AlienBars", false)
	ApplyCHUDSettings()
end

function OnCommandCHUDStopSound()
	for a = 1, #Client.ambientSoundList do
		Client.ambientSoundList[a]:OnDestroy()
	end
	Client.ambientSoundList = { }
end

function OnCommandCHUDAmbientSounds()
	if Client.GetOptionBoolean("CHUD_Ambient", true) then
		Client.SetOptionBoolean("CHUD_Ambient", false)	
		Shared.Message("Map ambient sounds disabled.")
		OnCommandCHUDStopSound()
	else
		Client.SetOptionBoolean("CHUD_Ambient", true)
		Shared.Message("Map ambient sounds enabled. You need to rejoin the server to reload the ambient sounds.")
	end
	CHUDSettings["ambient"] = Client.GetOptionBoolean("CHUD_Ambient", true)
	ApplyCHUDSettings()
end

function OnCommandCHUDNSLLights()
	if Client.GetOptionBoolean("lowLights", false) then
		Client.SetOptionBoolean("lowLights", false)	
		Shared.Message("Original low lighting quality.")
		OnCommandCHUDStopSound()
	else
		Client.SetOptionBoolean("lowLights", true)
		Shared.Message("Replaced low lighting quality with NSL lights.")
	end
	CHUDSettings["nsllights"] = Client.GetOptionBoolean("lowLights", false)
	lowLightsSwitched = false
	CHUDLoadLights()
end

Event.Hook("LoadComplete", AnnounceCHUD)
Event.Hook("Console_chud", OnCommandCHUDHelp)
Event.Hook("Console_chud_assists", OnCommandCHUDAssists)
//Event.Hook("Console_chud_av", OnCommandCHUDAV)
Event.Hook("Console_chud_banners", OnCommandCHUDBanners)
Event.Hook("Console_chud_blur", OnCommandCHUDBlur)
Event.Hook("Console_chud_gametime", OnCommandCHUDGametime)
Event.Hook("Console_chud_hpbar", OnCommandCHUDHPBar)
Event.Hook("Console_chud_kda", OnCommandCHUDKDA)
Event.Hook("Console_chud_mingui", OnCommandCHUDMinGUI)
Event.Hook("Console_chud_minimap", OnCommandCHUDMinimap)
Event.Hook("Console_chud_minnps", OnCommandCHUDMinNPs)
Event.Hook("Console_chud_minwps", OnCommandCHUDMinWPs)
Event.Hook("Console_chud_particles", OnCommandCHUDParticles)
Event.Hook("Console_chud_rtcount", OnCommandCHUDRTcount)
Event.Hook("Console_chud_score", OnCommandCHUDScore)
Event.Hook("Console_chud_showcomm", OnCommandCHUDShowComm)
Event.Hook("Console_chud_smalldmg", OnCommandCHUDSmallDMG)
Event.Hook("Console_chud_smallnps", OnCommandCHUDSmallNPs)
Event.Hook("Console_chud_tracers", OnCommandCHUDTracers)
Event.Hook("Console_chud_unlocks", OnCommandCHUDUnlocks)
Event.Hook("Console_chud_wps", OnCommandCHUDWPs)
Event.Hook("Console_chud_dmgcolor_m", OnCommandCHUDDMGColorM)
Event.Hook("Console_chud_dmgcolor_a", OnCommandCHUDDMGColorA)
Event.Hook("Console_chud_dmgcolor_reset", OnCommandCHUDDMGColorReset)
Event.Hook("Console_chud_alienbars", OnCommandCHUDAlienBars)
Event.Hook("Console_chud_ambient", OnCommandCHUDAmbientSounds)
Event.Hook("Console_stopsound", OnCommandCHUDStopSound)
Event.Hook("Console_chud_lowlights", OnCommandCHUDNSLLights)
Event.Hook("LocalPlayerChanged", CHUDLoadLights)
Event.Hook("LocalPlayerChanged", ApplyCHUDSettings)
Event.Hook("LoadComplete", SetCHUDCinematics)