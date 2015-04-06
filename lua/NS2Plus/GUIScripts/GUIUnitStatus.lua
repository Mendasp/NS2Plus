local isEnabled = Client.GetOptionBoolean("CHUD_SpectatorHPUnitStatus", true)
local parent, OldUpdateUnitStatusBlip = LocateUpValue( GUIUnitStatus.Update, "UpdateUnitStatusBlip", { LocateRecurse = true } )

function NewUpdateUnitStatusBlip( self, blipData, updateBlip, localPlayerIsCommander, baseResearchRot, showHints, playerTeamType )
	
	local CHUDBlipData
	if type(blipData.Hint) == "table" then
		CHUDBlipData = blipData.Hint
		blipData.Hint = CHUDBlipData.Hint
		if CHUDBlipData.IsVisible == false then
			blipData.IsCrossHairTarget = false
			blipData.HealthFraction = 0
		end
		if CHUDBlipData.HasWelder then
			blipData.HasWelder = CHUDBlipData.HasWelder
		end
	end
	
	local isEnemy = (playerTeamType ~= blipData.TeamType) and (blipData.TeamType ~= kNeutralTeamType)
	local isCrosshairTarget = blipData.IsCrossHairTarget
	local player = Client.GetLocalPlayer()
	
	local nameplates = not localPlayerIsCommander and CHUDGetOption("nameplates") or 0
	
	local showHints = showHints
	
	if nameplates == 1 then
		showHints = false
	elseif PlayerUI_GetIsSpecating() and isEnabled and blipData.IsPlayer then
		blipData.IsCrossHairTarget = true
	end
	
	OldUpdateUnitStatusBlip( self, blipData, updateBlip, localPlayerIsCommander, baseResearchRot, showHints, playerTeamType )
	
	if CHUDGetOption("wrenchicon") == 1 then
		if playerTeamType == kTeam1Index and (blipData.Status == kUnitStatus.Unrepaired or blipData.Status == kUnitStatus.Damaged) then
			local percentage = blipData.IsPlayer and blipData.ArmorFraction or (blipData.HealthFraction + blipData.ArmorFraction)/2
			local alpha = updateBlip.GraphicsItem:GetColor().a
			local color = (percentage < 0.5 and LerpColor(kRed, kYellow, percentage*2)) or (percentage >= 0.5 and LerpColor(kYellow, kWhite, (percentage-0.5)*2))
			color.a = alpha
			
			local x1, y1, x2, y2 = updateBlip.GraphicsItem:GetTexturePixelCoordinates()
			
			updateBlip.GraphicsItem:SetTexturePixelCoordinates(x1 + 512, y1, x2 + 512, y2)
			updateBlip.OverLayGraphic:SetTexturePixelCoordinates(x1 + 512, y1, x2 + 512, y2)
			updateBlip.GraphicsItem:SetColor(color)
			updateBlip.OverLayGraphic:SetColor(color)
		end
	end
	
	-- Hide Background
	if CHUDGetOption("mingui") or nameplates > 0 then
		updateBlip.statusBg:SetTexture(kTransparentTexture)
		if updateBlip.BorderMask then
			updateBlip.BorderMask:SetIsVisible(false)
		end
		if updateBlip.smokeyBackground then
			updateBlip.smokeyBackground:SetIsVisible(false)
		end
	end

	if blipData.IsWorldWeapon and updateBlip.AbilityBar then
		if CHUDGetOption("pickupexpire") == 0 then
			updateBlip.AbilityBarBg:SetIsVisible(false)
		end
		if CHUDGetOption("pickupexpirecolor") > 0 then
			if blipData.AbilityFraction >= 0.5 and blipData.AbilityFraction < 0.75 then
				updateBlip.AbilityBar:SetColor(Color(1, 1, 0, 1))
			elseif blipData.AbilityFraction >= 0.25 and blipData.AbilityFraction < 0.5 then
				updateBlip.AbilityBar:SetColor(Color(1, 0.5, 0, 1))
			elseif blipData.AbilityFraction < 0.25 then
				updateBlip.AbilityBar:SetColor(Color(1, 0, 0, 1))
			end
		end
	end
	
	-- Percentages Nameplates
	if nameplates == 1 then
		if CHUDBlipData and updateBlip.NameText:GetIsVisible() then
			
			if CHUDBlipData.Percentage then
				updateBlip.NameText:SetText(CHUDBlipData.Percentage)
			end
			
			if CHUDBlipData.Status then
				updateBlip.HintText:SetText(CHUDBlipData.Status)
			end
			
			updateBlip.HintText:SetIsVisible(true)
			updateBlip.HintText:SetColor(updateBlip.NameText:GetColor())
			
			updateBlip.HealthBarBg:SetIsVisible(false)
			updateBlip.ArmorBarBg:SetIsVisible(false)
			if updateBlip.AbilityBarBg then
				updateBlip.AbilityBarBg:SetIsVisible(false)
			end
			
			if blipData.SpawnFraction ~= nil and not isEnemy and not blipData.IsCrossHairTarget then
				updateBlip.NameText:SetText(string.format("%s (%d%%)", blipData.SpawnerName, blipData.SpawnFraction*100))
				updateBlip.HintText:SetIsVisible(false)
			elseif blipData.EvolvePercentage ~= nil and not isEnemy and ( blipData.IsPlayer or blipData.IsCrossHairTarget ) then
				updateBlip.NameText:SetText(string.format("%s (%d%%)", blipData.Name, blipData.EvolvePercentage*100))
				if blipData.EvolveClass ~= nil then
					updateBlip.HintText:SetText(string.format("%s (%s)", CHUDBlipData.Status, blipData.EvolveClass))
				end
			elseif blipData.Destination ~= nil and not isEnemy then
				if blipData.IsCrossHairTarget then
					updateBlip.NameText:SetText(string.format("%s (%s)", blipData.Destination, CHUDBlipData.Percentage))
				else
					updateBlip.NameText:SetText(blipData.Destination)
					updateBlip.HintText:SetIsVisible(false)
				end
			end
			
		end
	elseif nameplates == 2 and not blipData.IsPlayer then
		updateBlip.NameText:SetIsVisible(false)
		updateBlip.HintText:SetIsVisible(false)
	end
	
end

ReplaceUpValue( parent, "UpdateUnitStatusBlip", NewUpdateUnitStatusBlip, { LocateRecurse = true } )

local oldUnitStatusUpdate
oldUnitStatusUpdate = Class_ReplaceMethod( "GUIUnitStatus", "Update",
	function(self, deltaTime)
		CHUDHint = true
		ReplaceUpValue(PlayerUI_GetUnitStatusInfo, "kUnitStatusDisplayRange", ConditionalValue(PlayerUI_GetIsSpecating(), 30, 13), { LocateRecurse = true })
		oldUnitStatusUpdate( self, deltaTime )
		CHUDHint = false
		
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

	end)
	
local originalUnitStatusSKE
originalUnitStatusSKE = Class_ReplaceMethod("GUIUnitStatus", "SendKeyEvent",
	function(self, key, down)
		local ret = originalUnitStatusSKE(self, key, down)
		if not ret and PlayerUI_GetIsSpecating() and GetIsBinding(key, "Use") and down and not ChatUI_EnteringChatMessage() and not MainMenu_GetIsOpened() then
			isEnabled = not isEnabled
			Client.SetOptionBoolean("CHUD_SpectatorHPUnitStatus", isEnabled)
			return true
		end
		
		return ret
	end)