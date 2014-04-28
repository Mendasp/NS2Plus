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
					
					blipData.Hint = CHUDBlipData
					
					if CHUDBlipData.IsInfantryPortal then
						Shared.Message( "Processing IP blipData" )
						
						if CHUDBlipData.IsSpawning then
							if not blipData.IsCrosshairTarget then
								blipData.Name = CHUDBlipData.PlayerName
								blipData.HealthFraction = CHUDBlipData.SpawnFraction;
								blipData.ArmorFraction = 0;
								Shared.Message( "Overwrote blipData for IP: "..blipData.Name..", "..blipData.HealthFraction )
							else
								Shared.Message( "Not overwriting blipData for IP" )
							end
						end
						
						CHUDBlipData = nil;
					else
						blipData.IsParasited = CHUDBlipData.IsParasited
						blipData.IsSteamFriend = CHUDBlipData.IsSteamFriend
						if CHUDBlipData.MarineWeapon then
							blipData.MarineWeapon = CHUDBlipData.MarineWeapon
						end
					end
				end
				
				if CHUDGetOption("mingui") then
					updateBlip.statusBg:SetTexture(kTransparentTexture)
				end
				
				local player = Client.GetLocalPlayer()
				
				if CHUDGetOption("minnps") then
					updateBlip.HintText:SetText(blipData.Hint)
					if CHUDBlipData and not player:isa("Commander") then
						updateBlip.NameText:SetText(CHUDBlipData.Description)
						updateBlip.HealthBarBg:SetIsVisible(false)
						updateBlip.ArmorBarBg:SetIsVisible(false)
					end
				end
			
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
				
				if blipData.AbilityFraction > 0 and blipData.MarineWeapon and updateBlip.AbilityBar then
					updateBlip.AbilityBar:SetColor(kAmmoColors[blipData.MarineWeapon])
				end
			end
							
			if CHUDGetOption("mingui") and self.fullHUD then
				updateBlip.Border:SetSize(Vector(0,0,0))
			end
			
		end
	end)