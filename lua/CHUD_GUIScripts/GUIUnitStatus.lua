local kHealthBarWidth, kHealthBarHeight, GetPixelCoordsForFraction, kArmorBarWidth, kArmorBarHeight
local originalUnitStatusUpdate
originalUnitStatusUpdate = Class_ReplaceMethod( "GUIUnitStatus", "Update",
	function(self, deltaTime)
		// When CHUDHint is false the unit hints return the usual hints
		// When it's true it returns a table with the extra info we need for our stuff
		// Brings tears to my eyes
		CHUDHint = false
		originalUnitStatusUpdate(self,deltaTime)
		
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

		CHUDHint = true
		local activeBlips = PlayerUI_GetUnitStatusInfo()
		CHUDHint = false
		
		for i = 1, #self.activeBlipList do
			local blipData = activeBlips[i]
			local updateBlip = self.activeBlipList[i]
			local CHUDBlipData
																			
			if blipData ~= nil then
				if type(blipData.Hint) == "table" then
					
					CHUDBlipData = blipData.Hint
					
					blipData.Hint = CHUDBlipData.Hint
									
					blipData.IsParasited = CHUDBlipData.IsParasited
					blipData.IsSteamFriend = CHUDBlipData.IsSteamFriend
					if CHUDBlipData.MarineWeapon then
						blipData.MarineWeapon = CHUDBlipData.MarineWeapon
					elseif CHUDBlipData.EvolvePercentage then
						blipData.AbilityFraction = CHUDBlipData.EvolvePercentage
					end
				end
				
				if CHUDGetOption("mingui") then
					updateBlip.statusBg:SetTexture(kTransparentTexture)
				end
				
				local player = Client.GetLocalPlayer()				
				local playerTeamType = PlayerUI_GetTeamType()
								
				local isEnemy = false
				
				if playerTeamType ~= kNeutralTeamType then
					isEnemy = (playerTeamType ~= blipData.TeamType) and (blipData.TeamType ~= kNeutralTeamType)
				end
				
				if CHUDBlipData and CHUDBlipData.IsSpawning and not blipData.IsCrossHairTarget and not isEnemy then
									
					if CHUDGetOption("minnps") and not player:isa("Commander") then		
						
						updateBlip.NameText:SetText(string.format("%s (%d%%)", CHUDBlipData.PlayerName, CHUDBlipData.SpawnFraction*100))
						
						updateBlip.HealthBarBg:SetIsVisible(false)
						updateBlip.ArmorBarBg:SetIsVisible(false)
					
					else
					
						updateBlip.NameText:SetText( CHUDBlipData.PlayerName )
							
						updateBlip.statusBg:SetColor(Color(1,1,1,1))
						
						updateBlip.HealthBarBg:SetIsVisible(true)
						updateBlip.HealthBar:SetSize(Vector(kHealthBarWidth * CHUDBlipData.SpawnFraction, kHealthBarHeight, 0))
						updateBlip.HealthBar:SetTexturePixelCoordinates(GetPixelCoordsForFraction( CHUDBlipData.SpawnFraction ))
							
						updateBlip.ArmorBarBg:SetIsVisible(false)
					
					end
				
				else
					
					if CHUDGetOption("minnps") then
						updateBlip.HintText:SetText(blipData.Hint)
						if CHUDBlipData and not player:isa("Commander") then
							updateBlip.NameText:SetText(CHUDBlipData.Description)
							updateBlip.HealthBarBg:SetIsVisible(false)
							updateBlip.ArmorBarBg:SetIsVisible(false)
						end
					end
					
				end
			
				local alpha = 0
				
				if blipData.IsCrossHairTarget or (CHUDBlipData and (CHUDBlipData.IsSpawning or CHUDBlipData.EvolvePercentage) and not isEnemy) then
					alpha = 1
				else
					alpha = 0
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
				
				if blipData.AbilityFraction > 0 and not updateBlip.AbilityBarBg then
				
					AddAbilityBar(updateBlip)
				
				elseif blipData.AbilityFraction == 0 and updateBlip.AbilityBarBg then
					
					GUI.DestroyItem(updateBlip.AbilityBarBg)
					updateBlip.AbilityBarBg = nil
					updateBlip.AbilityBar = nil
					
				end
				
				if blipData.AbilityFraction > 0 and blipData.MarineWeapon then
					updateBlip.AbilityBar:SetColor(kAmmoColors[blipData.MarineWeapon])
				end
				
				if updateBlip.AbilityBarBg and CHUDBlipData.EvolvePercentage and not isEnemy then

					if not CHUDGetOption("minnps") or player:isa("Commander") then
						local bgColor = Color(0,0,0,alpha)
						updateBlip.AbilityBarBg:SetColor(bgColor)
						
						updateBlip.AbilityBar:SetSize(Vector(kArmorBarWidth * blipData.AbilityFraction, kArmorBarHeight * 2, 0))
						updateBlip.AbilityBar:SetTexturePixelCoordinates(GetPixelCoordsForFraction(blipData.AbilityFraction))
						
						if player:isa("Commander") then
							local origin = blipData.WorldOrigin
							origin.x = origin.x+2
							updateBlip.statusBg:SetPosition(Client.WorldToScreen(origin) - GUIUnitStatus.kStatusBgSize * .5)
						end
					else
						updateBlip.NameText:SetText(string.format("%s (%d%%)", CHUDBlipData.Description, CHUDBlipData.EvolvePercentage*100))
					end
						
				end
				
			end
							
			if CHUDGetOption("mingui") and self.fullHUD then
				updateBlip.Border:SetSize(Vector(0,0,0))
			end
			
		end
	end)


CopyUpValues( GUIUnitStatus.Update, GetUpValue( originalUnitStatusUpdate, "UpdateUnitStatusList" ) )