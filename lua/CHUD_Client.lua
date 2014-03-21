function ApplyCHUDSettings()
	for name, script in pairs(GetGUIManager().scripts) do
		ApplyCHUD(script, script._scriptName)
	end
end

function OnCommandCHUDNSLLights()
	lowLightsSwitched = false
	CHUDLoadLights()
end

function OnCommandCHUDHitIndicator()
	Player.kShowGiveDamageTime = CHUDGetOption("hitindicator")
end

function OnCommandCHUDLocationAlpha()
	OnCommandSetMapLocationColor("255", "255", "255", tostring(tonumber(CHUDGetOption("locationalpha"))*255))
end

function OnCommandCHUDMinimapAlpha()
	local minimapScript = ClientUI.GetScript("GUIMinimapFrame")
	minimapScript:GetMinimapItem():SetColor(Color(1,1,1,CHUDGetOption("minimapalpha")))
end

Script.Load("lua/CHUD_Shared.lua")
Script.Load("lua/CHUD_Utility.lua")
Script.Load("lua/CHUD_Particles.lua")
Script.Load("lua/CHUD_MainMenu.lua")
Script.Load("lua/CHUD_Settings.lua")
Script.Load("lua/CHUD_Options.lua")
Script.Load("lua/CHUD_Lights.lua")
Script.Load("lua/CHUD_UnitStatus.lua")
Script.Load("lua/CHUD_HUDElements.lua")
Script.Load("lua/CHUD_GUIScripts.lua")
Script.Load("lua/CHUD_Tracers.lua")
Script.Load("lua/CHUD_ScoreDisplay.lua")
Script.Load("lua/CHUD_Stats.lua")
Script.Load("lua/CHUD_ServerBrowser.lua")

function ApplyCHUD(script, scriptName)
	
		if scriptName == "GUIMarineHUD" then
			if CHUDGetOption("showcomm") and not CHUDGetOption("minimap") then
				GUIPlayerResource.kTeamTextPos = Vector(20, 76, 0)
			else
				GUIPlayerResource.kTeamTextPos = Vector(20, 360, 0)
			end
						
			script:Uninitialize()
			script:Initialize()
				
			if CHUDGetOption("mingui") then
				if CHUDGetOption("minimap") then
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

			script:SetHUDMapEnabled(CHUDGetOption("minimap"))
			script.locationText:SetIsVisible(CHUDGetOption("minimap"))

			if CHUDGetOption("showcomm") and not CHUDGetOption("minimap") then
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
			
			if CHUDGetOption("alienbars") then
				kTextureNameCHUD = OMATextureName
			else
				kTextureNameCHUD = kTextureNameOrig
			end
			
			// Backgrounds of health/energy
			local CHUDSmokeSize
			if CHUDGetOption("mingui") then
				CHUDSmokeSize = 0
			else
				CHUDSmokeSize = 128
			end
			ReplaceLocals(GUIAlienHUD.CreateHealthBall, {kHealthBackgroundTextureX2 = CHUDSmokeSize, kHealthBackgroundTextureY2 = CHUDSmokeSize, kTextureName = kTextureNameCHUD})
			ReplaceLocals(GUIAlienHUD.CreateEnergyBall, {kHealthBackgroundTextureX2 = CHUDSmokeSize, kHealthBackgroundTextureY2 = CHUDSmokeSize, kTextureName = kTextureNameCHUD,
				energyBallSettings = {
					BackgroundWidth = GUIScale(160),
					BackgroundHeight = GUIScale(160),
					BackgroundAnchorX = GUIItem.Right,
					BackgroundAnchorY = GUIItem.Bottom,
					BackgroundOffset = Vector(-160 - 45, -50, 0) * GUIScale(1),
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
			if CHUDGetOption("mingui") then
				script.resourceDisplay.background:SetColor(Color(1,1,1,0))
			else
				script.resourceDisplay.background:SetColor(Color(1,1,1,1))
			end
					
			if CHUDGetOption("av") == 1 then
				Client.DestroyScreenEffect(Player.screenEffects.darkVision)
				Client.DestroyScreenEffect(HiveVision_screenEffect)
				HiveVision_screenEffect = Client.CreateScreenEffect("shaders/HiveVision.screenfx")
				Player.screenEffects.darkVision = Client.CreateScreenEffect("shaders/HuzeOldAV.screenfx")
			elseif CHUDGetOption("av") == 2 then
				Client.DestroyScreenEffect(Player.screenEffects.darkVision)
				Client.DestroyScreenEffect(HiveVision_screenEffect)
				HiveVision_screenEffect = Client.CreateScreenEffect("shaders/HiveVision.screenfx")
				Player.screenEffects.darkVision = Client.CreateScreenEffect("shaders/HuzeMinAV.screenfx")
			else
				Client.DestroyScreenEffect(Player.screenEffects.darkVision)
				Client.DestroyScreenEffect(HiveVision_screenEffect)
				HiveVision_screenEffect = Client.CreateScreenEffect("shaders/HiveVision.screenfx")
				Player.screenEffects.darkVision = Client.CreateScreenEffect("shaders/DarkVision.screenfx")
			end
			
			if Client.GetIsControllingPlayer() then
				Client.GetLocalPlayer():SetDarkVision(CHUDGetOption("avstate"))
			end
			
		elseif scriptName == "GUIUnitStatus" then
			if CHUDGetOption("smallnps") then
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
			if CHUDGetOption("mingui") then
				script.smokeyBackground:SetIsVisible(false)
				script.background:SetTexture("ui/blank.dds")
			else
				script.smokeyBackground:SetIsVisible(true)
				script.background:SetTexture("ui/biomass_bar.dds")
			end
			
			if not Client.GetLocalPlayer():isa("Commander") then
				// Move this down a bit, since we moved the team res stuff up
				script.background:SetPosition(GUIScale(Vector(20, 100, 0)))
				script.smokeyBackground:SetPosition(GUIScale(Vector(-100, 10, 0)))
			else
				script.background:SetPosition(GUIScale(Vector(20, 70, 0)))
				script.smokeyBackground:SetPosition(GUIScale(Vector(-100, -20, 0)))
			end

		// Touching this script releases demons and black magic for reasons unknown to science
		/*elseif scriptName == "GUIFeedback" then
			script.buildText:SetIsVisible(not CHUDGetOption("mingui"))*/
			
		elseif scriptName == "GUIMinimapFrame" then
			
			script:GetMinimapItem():SetColor(Color(1,1,1,CHUDGetOption("minimapalpha")))
						
			if Client.GetLocalPlayer():isa("Marine") then
				if CHUDGetOption("mingui") then
					script.minimapFrame:SetTexture("ui/blank.dds")
				else
					script.minimapFrame:SetTexture("ui/marine_commander_textures.dds")
				end
			end
			
			if script.buttonsScript then
				local selectionPanelScript = GetGUIManager():GetGUIScriptSingle("GUISelectionPanel")
				local minimapButtons = GetGUIManager():GetGUIScriptSingle("GUIMinimapButtons")
				local resourceDisplay = GetGUIManager():GetGUIScriptSingle("GUIResourceDisplay")
				local logoutScript = GetGUIManager():GetGUIScriptSingle("GUICommanderLogout")
				local commanderTooltip = GetGUIManager():GetGUIScriptSingle("GUICommanderTooltip")
				
				if CHUDGetOption("mingui") then
					if minimapButtons then
						minimapButtons.background:SetIsVisible(false)
						// Move them off-screen so we can click through
						minimapButtons.pingButton:SetPosition(Vector(-9999,0,0))
						minimapButtons.techMapButton:SetPosition(Vector(-9999,0,0))
					end
					if Client.GetLocalPlayer():isa("MarineCommander") then
						script.minimapFrame:SetTexture("ui/blank.dds")
						script.buttonsScript.background:SetTexture("ui/blank.dds")
						selectionPanelScript.background:SetTexture("ui/blank.dds")
						logoutScript.background:SetTexture("ui/blank.dds")
						commanderTooltip.backgroundTop:SetTexture("ui/blank.dds")
						commanderTooltip.backgroundCenter:SetTexture("ui/blank.dds")
						commanderTooltip.backgroundBottom:SetTexture("ui/blank.dds")
					elseif Client.GetLocalPlayer():isa("AlienCommander") then
						script.buttonsScript.smokeyBackground:SetTexture("ui/blank.dds")
						selectionPanelScript.smokeyBackground:SetTexture("ui/blank.dds")
						script.smokeyBackground:SetTexture("ui/blank.dds")
						resourceDisplay.smokeyBackground:SetTexture("ui/blank.dds")
						logoutScript.smokeyBackground:SetTexture("ui/blank.dds")
						commanderTooltip.smokeyBackground:SetTexture("ui/blank.dds")
					end
				else
					if minimapButtons then
						minimapButtons.background:SetIsVisible(true)
						minimapButtons.pingButton:SetPosition(Vector(0,0,0))
						minimapButtons.techMapButton:SetPosition(Vector(0,0,0))
					end
					if Client.GetLocalPlayer():isa("MarineCommander") then
						script.minimapFrame:SetTexture("ui/marine_commander_textures.dds")
						script.buttonsScript.background:SetTexture(GUICommanderButtonsMarines:GetBackgroundTextureName())
						selectionPanelScript.background:SetTexture(GUISelectionPanel.kSelectionTextureMarines)
						logoutScript.background:SetTexture(GUICommanderLogout.kLogoutMarineTextureName)
						commanderTooltip.backgroundTop:SetTexture(GUICommanderTooltip.kMarineBackgroundTexture)
						commanderTooltip.backgroundCenter:SetTexture(GUICommanderTooltip.kMarineBackgroundTexture)
						commanderTooltip.backgroundBottom:SetTexture(GUICommanderTooltip.kMarineBackgroundTexture)
					elseif Client.GetLocalPlayer():isa("AlienCommander") then
						script.buttonsScript.smokeyBackground:SetTexture("ui/alien_commander_smkmask.dds")
						selectionPanelScript.smokeyBackground:SetTexture("ui/alien_logout_smkmask.dds")
						script.smokeyBackground:SetTexture("ui/alien_minimap_smkmask.dds")
						resourceDisplay.smokeyBackground:SetTexture("ui/alien_ressources_smkmask.dds")
						logoutScript.smokeyBackground:SetTexture("ui/alien_logout_smkmask.dds")
						commanderTooltip.smokeyBackground:SetTexture("ui/alien_logout_smkmask.dds")
					end
				end					
			end
		
		end
		
		if not CHUDGetOption("ambient") then
			OnCommandCHUDStopSound()
		end
			
end

function AnnounceCHUD()
	Shared.Message("Custom HUD mod loaded. Type \"chud\" in console for available commands. You can also customize your HUD from your options menu.")
	GetCHUDSettings()
end

function OnCommandCHUDStopSound()
	for a = 1, #Client.ambientSoundList do
		Client.ambientSoundList[a]:OnDestroy()
	end
	Client.ambientSoundList = { }
end

Event.Hook("LoadComplete", AnnounceCHUD)
Event.Hook("LoadComplete", SetCHUDCinematics)
Event.Hook("Console_stopsound", OnCommandCHUDStopSound)
Event.Hook("LocalPlayerChanged", CHUDLoadLights)
Event.Hook("LocalPlayerChanged", ApplyCHUDSettings)