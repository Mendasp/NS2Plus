MarineHUDOverride = false
MarineBuyMenuOverride = false
AlienHUDOverride = false
WorldTextOverride = false
ExoHUDOverride = false
WPOverride = false
UnitStatusOverride = false
GameEndOverride = false
MinimapLocationInitOverride = false
CommManagerOverride = false
AlienSpecOverride = false
BalanceOverride = false

originalGUIScript = Class_ReplaceMethod( "GUIManager", "CreateGUIScript",
	function(self, scriptName)
		local script = originalGUIScript(self, scriptName)
		if (scriptName == "Hud/Marine/GUIMarineHUD") then
			if not MarineHUDOverride then
				originalSetHUDMap = Class_ReplaceMethod( "GUIMarineHUD", "SetHUDMapEnabled",
				function(self, enabled)
					originalSetHUDMap(self, CHUDGetOption("minimap"))
				end)
				
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
				
			end

			if not MarineHUDOverride then
				MarineHUDOverride = true
				originalMarineHUDUpdate = Class_ReplaceMethod( "GUIMarineHUD", "Update",
					function(self, deltaTime)
						originalMarineHUDUpdate(self, deltaTime)
						local fullMode = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
						
						self.resourceDisplay.teamText:SetIsVisible(CHUDGetOption("minimap") or (CHUDGetOption("showcomm") and not CHUDGetOption("minimap")))
						if not CHUDGetOption("minimap") and not CHUDGetOption("showcomm") then
							self.resourceDisplay.teamText:SetText("")
						end
						
						if CHUDGetOption("mingui") then
							self.inventoryDisplay:SetIsVisible(false)
						end
												
						if CHUDGetOption("gametime") and (CHUDGetOption("showcomm") or CHUDGetOption("minimap")) then
							local gameTime = PlayerUI_GetGameStartTime()
							
							if gameTime ~= 0 then
								gameTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
							end
							
							local minutes = math.floor(gameTime / 60)
							local seconds = gameTime - minutes * 60
							
							self.resourceDisplay.teamText:SetText(string.format(Locale.ResolveString("TEAM_RES") .. "\n%d:%02d", math.floor(PlayerUI_GetTeamResources()), minutes, math.floor(seconds)))
						end
						
						local s_rts
						
						if not CHUDGetOption("rtcount") then
							self.resourceDisplay.rtCount:SetIsVisible(false)
							if CommanderUI_GetTeamHarvesterCount() ~= 1 then
								s_rts = "RTs"
							else
								s_rts = "RT"
							end
							self.resourceDisplay.pResDescription:SetText(Locale.ResolveString("RESOURCES") .. " (" .. ToString(CommanderUI_GetTeamHarvesterCount()) .. " " .. s_rts ..")")
						else
							self.resourceDisplay.rtCount:SetIsVisible(CommanderUI_GetTeamHarvesterCount() > 0)
							self.resourceDisplay.pResDescription:SetText(Locale.ResolveString("RESOURCES"))
						end
											
						self.commanderName:SetIsVisible(false)
						if (CHUDGetOption("minimap") or (CHUDGetOption("showcomm") and not CHUDGetOption("minimap"))) then
							// Update commander name
							local commanderName = PlayerUI_GetCommanderName()
						
							self.commanderName:SetIsVisible(true)
						
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
				end
			
			Class_ReplaceMethod( "GUIMarineHUD", "OnLocalPlayerChanged",
				function(self, newPlayer)
					if CHUDGetOption("mingui") then
						self.topLeftFrame:SetIsVisible(false)
						self.topRightFrame:SetIsVisible(false)
						self.bottomLeftFrame:SetIsVisible(false)
						self.bottomRightFrame:SetIsVisible(false)
					end
				end
			)
			
		elseif (scriptName == "Hud/Marine/GUIExoHUD") then
			if not ExoHUDOverride then
				ExoHUDOverride = true
				originalExoHUDUpdate = Class_ReplaceMethod( "GUIExoHUD", "Update",
					function(self, deltaTime)
						originalExoHUDUpdate(self, deltaTime)
						
						local fullMode = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full

						if fullMode then
							self.innerRing:SetIsVisible(not CHUDGetOption("mingui"))
							self.outerRing:SetIsVisible(not CHUDGetOption("mingui"))
							self.leftInfoBar:SetIsVisible(not CHUDGetOption("mingui"))
							self.rightInfoBar:SetIsVisible(not CHUDGetOption("mingui"))
							self.staticRing:SetIsVisible(not CHUDGetOption("mingui"))
						end
					end)
			end
				
		elseif (scriptName == "GUIAlienHUD") then
			if not AlienHUDOverride then
				AlienHUDOverride = true
				originalAlienHUDUpdate = Class_ReplaceMethod( "GUIAlienHUD", "Update",
					function(self, deltaTime)
						originalAlienHUDUpdate(self, deltaTime)
						
						local s_rts
						
						if not CHUDGetOption("rtcount") then
							self.resourceDisplay.rtCount:SetIsVisible(false)
							if CommanderUI_GetTeamHarvesterCount() ~= 1 then
								s_rts = "RTs"
							else
								s_rts = "RT"
							end
							self.resourceDisplay.pResDescription:SetText(Locale.ResolveString("RESOURCES") .. " (" .. ToString(CommanderUI_GetTeamHarvesterCount()) .. " " .. s_rts ..")")
						else
							self.resourceDisplay.rtCount:SetIsVisible(CommanderUI_GetTeamHarvesterCount() > 0)
							self.resourceDisplay.pResDescription:SetText(Locale.ResolveString("RESOURCES"))
						end
						
						if CHUDGetOption("gametime") then
							local gameTime = PlayerUI_GetGameStartTime()
							
							if gameTime ~= 0 then
								gameTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
							end
							
							local minutes = math.floor(gameTime / 60)
							local seconds = gameTime - minutes * 60
							
							self.resourceDisplay.teamText:SetText(string.format(Locale.ResolveString("TEAM_RES") .. "\n%d:%02d", math.floor(PlayerUI_GetTeamResources()), minutes, math.floor(seconds)))
						end
						
						self.resourceDisplay.teamText:SetIsVisible(CHUDGetOption("showcomm") or CHUDGetOption("minimap"))
				end)
			end
			
		elseif (scriptName == "GUICommanderManager") and not CommManagerOverride then
			// One day I'll do stuff like this properly, but not now!
			// And I don't mean just the part where I use the same code 3 times in 3 places!
			// HACKSSSSSSSS
			CommManagerOverride = true
			originalCommManager = Class_ReplaceMethod( "GUICommanderManager", "Update",
				function(self, deltaTime)
					originalCommManager(self, deltaTime)
					
					if CHUDGetOption("gametime") then
						local currentLocationText = self.locationText:GetText()
						local gameTime = PlayerUI_GetGameStartTime()
						
						if gameTime ~= 0 then
							gameTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
						end
						
						local minutes = math.floor(gameTime / 60)
						local seconds = gameTime - minutes * 60
						
						self.locationText:SetText(string.format(currentLocationText .. "\n%d:%02d", minutes, math.floor(seconds)))
					end
				end)
		
		elseif (scriptName == "GUIProgressBar") then
			script:Uninitialize()
			if CHUDGetOption("mingui") then
				ReplaceLocals(GUIProgressBar.Initialize, {kBackgroundPixelCoords = { 0, 0, 0, 0 }})
				ReplaceLocals(GUIProgressBar.InitCircleMask, {kBackgroundPixelCoords = { 0, 0, 0, 0 }})
			else
				ReplaceLocals(GUIProgressBar.Initialize, {kBackgroundPixelCoords = { 0, 0, 230, 50 }})
				ReplaceLocals(GUIProgressBar.InitCircleMask, {kBackgroundPixelCoords = { 0, 0, 230, 50 }})	
			end
			script:Initialize()
			if PlayerUI_GetTeamType() == kAlienTeamType then
				script.smokeyBackground:SetIsVisible(not CHUDGetOption("mingui"))
			end
			
		elseif (scriptName == "GUIAlienBuyMenu") then
			if CHUDGetOption("mingui") then
				script.backgroundCircle:SetIsVisible(false)
				script.glowieParticles:Uninitialize()
				script.smokeParticles:Uninitialize()
				for cornerName, cornerItem in pairs(script.corners) do
					GUI.DestroyItem(cornerItem)
				end
				script.corners = { }
				
				script.cornerTweeners = { }
			end
			
		elseif (scriptName == "GUIGorgeBuildMenu") then
			script:Uninitialize()
			if CHUDGetOption("mingui") then
				script.kSmokeSmallTextureCoordinates = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}
				ReplaceLocals(GUIGorgeBuildMenu.CreateButton, {kSmokeyBackgroundSize = Vector(0, 0, 0)})
			else
				script.kSmokeSmallTextureCoordinates = { { 916, 4, 1020, 108 }, { 916, 15, 1020, 219 }, { 916, 227, 1020, 332 }, { 916, 332, 1020, 436 } }
				ReplaceLocals(GUIGorgeBuildMenu.CreateButton, {kSmokeyBackgroundSize = GUIScale(Vector(220, 400, 0))})
			end
			script:Initialize()
			
		elseif (scriptName == "GUIMarineBuyMenu") then
			if CHUDGetOption("mingui") then
				script.content:SetTexture("ui/blank.dds")
				script.repeatingBGTexture:SetTexture("ui/blank.dds")
				script.scanLine:SetIsVisible(false)
				script.resourceDisplayBackground:SetTexture("ui/blank.dds")
				script.background:SetColor(Color(1, 1, 1, 0))
			end
			if not MarineBuyMenuOverride then
				MarineBuyMenuOverride = true
				originalMarineBuyMenu = Class_ReplaceMethod( "GUIMarineBuyMenu", "SetHostStructure",
					function(self, hostStructure)
						originalMarineBuyMenu(self, hostStructure)
						if CHUDGetOption("mingui") then
							self.menu:SetTexture("ui/blank.dds")
							self.menuHeader:SetTexture("ui/blank.dds")
						end
					end)
			end
				
		elseif (scriptName == "GUIWorldText") and not WorldTextOverride then
			WorldTextOverride = true
			originalWorldTextUpdate = Class_ReplaceMethod( "GUIWorldText", "UpdateDamageMessage",
				function(self, message, messageItem, useColor, deltaTime)
					originalWorldTextUpdate(self, message, messageItem, useColor, deltaTime)
					local oldalpha = useColor.a
					if CHUDGetOption("smalldmg") then
						messageItem:SetScale(messageItem:GetScale()*0.5)
					end
					local dmgcolor_m = 0x4DDBFF
					local dmgcolor_a = 0xFFCA3A
					local dmgoption_m = CHUDGetOption("dmgcolor_m")
					local dmgoption_a = CHUDGetOption("dmgcolor_a")
					local colorValues = { 0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0xFF00FF, 0x00FFFF, 0xFFA500, 0x000000, 0xFFFFFF }
					
					if dmgoption_m > 0 then
						dmgcolor_m = colorValues[dmgoption_m]
					end
					if dmgoption_a > 0 then
						dmgcolor_a = colorValues[dmgoption_a]
					end
					
					useColorCHUD = ConditionalValue(PlayerUI_IsOnMarineTeam(), ColorIntToColor(dmgcolor_m), ColorIntToColor(dmgcolor_a))
					messageItem:SetColor(Color(useColorCHUD.r, useColorCHUD.g, useColorCHUD.b, oldalpha))
				end)
		
		elseif (scriptName == "GUIScoreboard") then
			originalScoreboardUpdateTeam = Class_ReplaceMethod( "GUIScoreboard", "UpdateTeam",
				function(self, updateTeam)
					originalScoreboardUpdateTeam(self, updateTeam)
					local playerList = updateTeam["PlayerList"]
					for index, player in pairs(playerList) do
						if CHUDGetOption("kda") and player["Assists"]:GetPosition().x < player["Deaths"]:GetPosition().x then
							local temp = player["Assists"]:GetPosition()
							player["Assists"]:SetPosition(player["Deaths"]:GetPosition())
							player["Deaths"]:SetPosition(temp)
						end
					end
				end)
		
		elseif (scriptName == "GUIWaypoints") and not WPOverride then
			WPOverride = true
			originalWPUpdate = Class_ReplaceMethod( "GUIWaypoints", "Update",
				function(self, deltaTime)
					originalWPUpdate(self, deltaTime)
					local finalWaypointData = PlayerUI_GetFinalWaypointInScreenspace()
					local showWayPoint = not PlayerUI_GetIsConstructing() and not PlayerUI_GetIsRepairing() and (CHUDGetOption("wps") or Client.GetLocalPlayer():isa("Commander"))
					local fullHUD = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
					self.animatedCircle:SetIsVisible(showWayPoint and fullHUD and not CHUDGetOption("minwps"))
					self.finalWaypoint:SetIsVisible(showWayPoint)
					self.finalDistanceText:SetIsVisible(fullHUD and not CHUDGetOption("minwps"))
					self.finalNameText:SetIsVisible(fullHUD and not CHUDGetOption("minwps"))
					if CHUDGetOption("minwps") then
						self.finalWaypoint:SetTexture(kTransparentTexture)
					else
						self.finalWaypoint:SetTexture(self.usedTexture)
					end
					
					// If we have disabled waypoints, we still want to see Attack waypoints
					if finalWaypointData and not CHUDGetOption("wps") then
						self.finalWaypoint:SetIsVisible(finalWaypointData.type == kTechId.Attack)
					end
					
					// Disabled auto waypoints only
					if finalWaypointData and not CHUDGetOption("autowps") and CHUDGetOption("wps") then
						if finalWaypointData.type == kTechId.AutoConstruct or finalWaypointData.type == kTechId.AutoWeld then
							self.finalWaypoint:SetIsVisible(false)
						end
					end
					
					// Hide the arrows in any of the modes
					for a = 1, #self.worldArrows do
						self.worldArrows[a].model:SetIsVisible(not (CHUDGetOption("minwps") or not CHUDGetOption("wps")))
						self.worldArrows[a].light:SetIsVisible(not (CHUDGetOption("minwps") or not CHUDGetOption("wps")))
					end
					
					if not finalWaypointData then
						self.finalWaypoint:SetColor(Color(1, 1, 1, 0))
						self.finalDistanceText:SetIsVisible(false)
						self.finalNameText:SetIsVisible(false)
						self.waypointDirection:SetIsVisible(false)
					end
					
				end)
		
		elseif (scriptName == "GUIUnitStatus") and not UnitStatusOverride then
			UnitStatusOverride = true
			originalUnitStatusUpdate = Class_ReplaceMethod( "GUIUnitStatus", "Update",
				function(self, deltaTime)
					originalUnitStatusUpdate(self,deltaTime)
					
					local activeBlips = PlayerUI_GetUnitStatusInfo()
				
					for i = 1, #script.activeBlipList do
						local blipData = activeBlips[i]
						local updateBlip = self.activeBlipList[i]	

						if CHUDGetOption("minnps") then
							updateBlip.statusBg:SetTexture(kTransparentTexture)
							if blipData ~= nil then
								updateBlip.HintText:SetText(blipData.Hint)
							end
						end
											
						if blipData ~= nil then
						
							local alpha = 0
							
							if blipData.IsCrossHairTarget then        
								alpha = 1
							else
								alpha = 0
							end
						
							local playerTeamType = PlayerUI_GetTeamType()
							local isEnemy = false
							
							if playerTeamType ~= kNeutralTeamType then
								isEnemy = (playerTeamType ~= blipData.TeamType) and (blipData.TeamType ~= kNeutralTeamType)
							end
							
							local textColor = Color(kNameTagFontColors[blipData.TeamType])
							if isEnemy then
								textColor = GUIUnitStatus.kEnemyColor
							elseif blipData.IsParasited and blipData.IsFriend then
								textColor = Color(kCommanderColorFloat)
							elseif blipData.IsSteamFriend then
								textColor = Color(kSteamFriendColor)
							end
						
							if not blipData.ForceName then
								textColor.a = alpha
							end
							
							updateBlip.NameText:SetColor(textColor)
							updateBlip.ActionText:SetColor(textColor)
							if updateBlip.HintText then
								updateBlip.HintText:SetColor(textColor)
							end
						
							updateBlip.NameText:SetIsVisible(self.fullHUD or blipData.IsPlayer or CHUDGetOption("minnps"))

							if updateBlip.smokeyBackground then
								updateBlip.smokeyBackground:SetIsVisible(blipData.HealthFraction ~= 0 and not CHUDGetOption("mingui"))
							end
							
							local kAmmoColors = {
								["rifle"] = Color(0,1,1,1), // teal
								["shotgun"] = Color(0,1,0,1), // green
								["flamethrower"] = Color(1,1,0,1), // yellow
								["grenadelauncher"] = Color(1,0,1,1), // magenta
							}
							
							if blipData.AbilityFraction > 0 and blipData.MarineWeapon then
								updateBlip.AbilityBar:SetColor(kAmmoColors[blipData.MarineWeapon])
							end
						end
										
						if CHUDGetOption("mingui") and self.fullHUD then
							updateBlip.Border:SetSize(Vector(0,0,0))
						end
						
					end
				end)
				
		elseif (scriptName == "GUIMinimapFrame") and not MinimapLocationInitOverride then
			MinimapLocationInitOverride = true
			originalLocationNameInit = Class_ReplaceMethod( "GUIMinimap", "InitializeLocationNames",
				function(self)
					originalLocationNameInit(self)
					if script.locationItems ~= nil then
						for _, locationItem in ipairs(script.locationItems) do
							locationItem.text:SetColor( Color(1, 1, 1, CHUDGetOption("locationalpha")) )
						end

					end
				end)
				
		elseif (scriptName == "GUIAlienSpectatorHUD") and not AlienSpecOverride then
			AlienSpecOverride = true
			originalAlienSpecUpdate = Class_ReplaceMethod( "GUIAlienSpectatorHUD", "Update",
				function(self, deltaTime)
					originalAlienSpecUpdate(self, deltaTime)
					self.eggIcon:SetIsVisible(self.eggIcon:GetIsVisible() and not CHUDStatsVisible)
				end)
				
		elseif (scriptName == "GUIWaitingForAutoTeamBalance") then
			originalBalanceUpdate = Class_ReplaceMethod( "GUIWaitingForAutoTeamBalance", "Update",
				function(self, deltaTime)
					script.waitingText:SetIsVisible(PlayerUI_GetIsWaitingForTeamBalance() and not CHUDStatsVisible)
				end)
		
		end
				
	return script
	end
)