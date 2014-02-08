MarineHUDOverride = false
MarineBuyMenuOverride = false
AlienHUDOverride = false
WorldTextOverride = false
ExoHUDOverride = false
WPOverride = false
UnitStatusOverride = false
GameEndOverride = false

originalGUIScript = Class_ReplaceMethod( "GUIManager", "CreateGUIScript",
	function(self, scriptName)
		local script = originalGUIScript(self, scriptName)
		if (scriptName == "Hud/Marine/GUIMarineHUD") then
			if not MarineHUDOverride then
				originalSetHUDMap = Class_ReplaceMethod( "GUIMarineHUD", "SetHUDMapEnabled",
				function(self, enabled)
					originalSetHUDMap(self, CHUDSettings["minimap"])
				end)
			end

			if not MarineHUDOverride then
				MarineHUDOverride = true
				originalMarineHUDUpdate = Class_ReplaceMethod( "GUIMarineHUD", "Update",
					function(self, deltaTime)
						originalMarineHUDUpdate(self, deltaTime)
						local fullMode = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
						
						self.resourceDisplay.teamText:SetIsVisible(CHUDSettings["minimap"] or (CHUDSettings["showcomm"] and not CHUDSettings["minimap"]))
						if not CHUDSettings["minimap"] and not CHUDSettings["showcomm"] then
							self.resourceDisplay.teamText:SetText("")
						end
						
						if CHUDSettings["mingui"] then
							self.inventoryDisplay:SetIsVisible(false)
						end
												
						if CHUDSettings["gametime"] and (CHUDSettings["showcomm"] or CHUDSettings["minimap"]) then
							local gameTime = PlayerUI_GetGameStartTime()
							
							if gameTime ~= 0 then
								gameTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
							end
							
							local minutes = math.floor(gameTime / 60)
							local seconds = gameTime - minutes * 60
							local gameTimeText = string.format(" - %d:%02d", minutes, seconds)
							
							self.resourceDisplay.teamText:SetText(string.format(Locale.ResolveString("TEAM_RES") .. "\n%d:%02d", math.floor(PlayerUI_GetTeamResources()), minutes, seconds))
						end
						
						local s_rts
						
						if not CHUDSettings["rtcount"] then
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
						if (CHUDSettings["minimap"] or (CHUDSettings["showcomm"] and not CHUDSettings["minimap"])) then
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
					if CHUDSettings["mingui"] then
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
							self.innerRing:SetIsVisible(not CHUDSettings["mingui"])
							self.outerRing:SetIsVisible(not CHUDSettings["mingui"])
							self.leftInfoBar:SetIsVisible(not CHUDSettings["mingui"])
							self.rightInfoBar:SetIsVisible(not CHUDSettings["mingui"])
							self.staticRing:SetIsVisible(not CHUDSettings["mingui"])
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
						
						if not CHUDSettings["rtcount"] then
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
						
						if CHUDSettings["gametime"] then
							local gameTime = PlayerUI_GetGameStartTime()
							
							if gameTime ~= 0 then
								gameTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
							end
							
							local minutes = math.floor(gameTime / 60)
							local seconds = gameTime - minutes * 60
							local gameTimeText = string.format(" - %d:%02d", minutes, seconds)
							
							self.resourceDisplay.teamText:SetText(string.format(Locale.ResolveString("TEAM_RES") .. "\n%d:%02d", math.floor(PlayerUI_GetTeamResources()), minutes, seconds))
						end
						
						self.resourceDisplay.teamText:SetIsVisible(CHUDSettings["showcomm"] or CHUDSettings["minimap"])
				end)
			end
		
		elseif (scriptName == "GUIProgressBar") then
			script:Uninitialize()
			if CHUDSettings["mingui"] then
				ReplaceLocals(GUIProgressBar.Initialize, {kBackgroundPixelCoords = { 0, 0, 0, 0 }})
				ReplaceLocals(GUIProgressBar.InitCircleMask, {kBackgroundPixelCoords = { 0, 0, 0, 0 }})
			else
				ReplaceLocals(GUIProgressBar.Initialize, {kBackgroundPixelCoords = { 0, 0, 230, 50 }})
				ReplaceLocals(GUIProgressBar.InitCircleMask, {kBackgroundPixelCoords = { 0, 0, 230, 50 }})	
			end
			script:Initialize()
			if PlayerUI_GetTeamType() == kAlienTeamType then
				script.smokeyBackground:SetIsVisible(not CHUDSettings["mingui"])
			end
			
		elseif (scriptName == "GUIAlienBuyMenu") then
			if CHUDSettings["mingui"] then
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
			if CHUDSettings["mingui"] then
				script.kSmokeSmallTextureCoordinates = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}
				ReplaceLocals(GUIGorgeBuildMenu.CreateButton, {kSmokeyBackgroundSize = Vector(0, 0, 0)})
			else
				script.kSmokeSmallTextureCoordinates = { { 916, 4, 1020, 108 }, { 916, 15, 1020, 219 }, { 916, 227, 1020, 332 }, { 916, 332, 1020, 436 } }
				ReplaceLocals(GUIGorgeBuildMenu.CreateButton, {kSmokeyBackgroundSize = GUIScale(Vector(220, 400, 0))})
			end
			script:Initialize()
			
		elseif (scriptName == "GUIMarineBuyMenu") then
			if CHUDSettings["mingui"] then
				script.background:SetColor(Color(1, 1, 1, 0))
				script.repeatingBGTexture:SetTexturePixelCoordinates(0, 0, 0, 0)
				script.content:SetTexturePixelCoordinates(0, 0, 0, 0)
				script.scanLine:SetIsVisible(false)
				script.resourceDisplayBackground:SetTexturePixelCoordinates(0, 0, 0, 0)
			end
			if not MarineBuyMenuOverride then
				MarineBuyMenuOverride = true
				originalMarineBuyMenu = Class_ReplaceMethod( "GUIMarineBuyMenu", "SetHostStructure",
					function(self, hostStructure)
						originalMarineBuyMenu(self, hostStructure)
						if CHUDSettings["mingui"] then
							self.menu:SetTexturePixelCoordinates(0, 0, 0, 0)
							self.menuHeader:SetTexturePixelCoordinates(0, 0, 0, 0)
						end
					end)
			end
				
		elseif (scriptName == "GUIWorldText") and not WorldTextOverride then
			WorldTextOverride = true
			originalWorldTextUpdate = Class_ReplaceMethod( "GUIWorldText", "UpdateDamageMessage",
				function(self, message, messageItem, useColor, deltaTime)
					originalWorldTextUpdate(self, message, messageItem, useColor, deltaTime)
					local oldalpha = useColor.a
					if CHUDSettings["smalldmg"] then
						messageItem:SetScale(messageItem:GetScale()*0.5)
					end
					useColorCHUD = ConditionalValue(PlayerUI_IsOnMarineTeam(), ColorIntToColor(CHUDSettings["dmgcolor_m"]), ColorIntToColor(CHUDSettings["dmgcolor_a"]))
					messageItem:SetColor(Color(useColorCHUD.r, useColorCHUD.g, useColorCHUD.b, oldalpha))
				end)
		
		elseif (scriptName == "GUIScoreboard") then
			originalScoreboardUpdateTeam = Class_ReplaceMethod( "GUIScoreboard", "UpdateTeam",
				function(self, updateTeam)
					originalScoreboardUpdateTeam(self, updateTeam)
					local playerList = updateTeam["PlayerList"]
					for index, player in pairs(playerList) do
						if CHUDSettings["kda"] and player["Assists"]:GetPosition().x < player["Deaths"]:GetPosition().x then
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
					local showWayPoint = not PlayerUI_GetIsConstructing() and not PlayerUI_GetIsRepairing() and (CHUDSettings["wps"] or Client.GetLocalPlayer():isa("Commander"))
					local fullHUD = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
					self.animatedCircle:SetIsVisible(showWayPoint and fullHUD and not CHUDSettings["minwps"])
					self.finalWaypoint:SetIsVisible(showWayPoint)
					self.finalDistanceText:SetIsVisible(fullHUD and not CHUDSettings["minwps"])
					self.finalNameText:SetIsVisible(fullHUD and not CHUDSettings["minwps"])
					if CHUDSettings["minwps"] then
						self.finalWaypoint:SetTexture(kTransparentTexture)
					else
						self.finalWaypoint:SetTexture(self.usedTexture)
					end
					
					// If we have disabled waypoints, we still want to see Attack waypoints
					if finalWaypointData and not CHUDSettings["wps"] then
						self.finalWaypoint:SetIsVisible(finalWaypointData.type == kTechId.Attack)
					end
					
					// Hide the arrows in any of the modes
					for a = 1, #self.worldArrows do
						self.worldArrows[a].model:SetIsVisible(not (CHUDSettings["minwps"] or not CHUDSettings["wps"]))
						self.worldArrows[a].light:SetIsVisible(not (CHUDSettings["minwps"] or not CHUDSettings["wps"]))
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

						if CHUDSettings["minnps"] then
							updateBlip.statusBg:SetTexture(kTransparentTexture)
							if blipData ~= nil then
								updateBlip.HintText:SetText(blipData.Hint)
							end
						end
						if blipData ~= nil then
							updateBlip.NameText:SetIsVisible(self.fullHUD or blipData.IsPlayer or CHUDSettings["minnps"])
						end
										
						if CHUDSettings["mingui"] and self.fullHUD then
							updateBlip.Border:SetSize(Vector(0,0,0))
						end
						
						if updateBlip.smokeyBackground then
							if blipData ~= nil then
								updateBlip.smokeyBackground:SetIsVisible(blipData.HealthFraction ~= 0 and not CHUDSettings["mingui"])
							end
						end
						
					end
				end)
		
		end
				
	return script
	end
)