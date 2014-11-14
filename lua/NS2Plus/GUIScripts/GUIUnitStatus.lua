
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
	
	local minnps = CHUDGetOption("minnps") and not localPlayerIsCommander
	
	local showHints = showHints
	
	if minnps then
		showHints = false
	end
	

	OldUpdateUnitStatusBlip( self, blipData, updateBlip, localPlayerIsCommander, baseResearchRot, showHints, playerTeamType )
	
		
	-- Hide Background
	if CHUDGetOption("mingui") or minnps then
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

	
	-- Minimal Nameplates
	if minnps then
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
	end
	
end

ReplaceUpValue( parent, "UpdateUnitStatusBlip", NewUpdateUnitStatusBlip )

local oldUnitStatusUpdate
oldUnitStatusUpdate = Class_ReplaceMethod( "GUIUnitStatus", "Update",
	function(self, deltaTime)
		CHUDHint = true
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