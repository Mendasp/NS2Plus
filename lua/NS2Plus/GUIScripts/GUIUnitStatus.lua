
local parent, OldUpdateUnitStatusBlip = LocateUpValue( GUIUnitStatus.Update, "UpdateUnitStatusBlip", { LocateRecurse = true } )

function NewUpdateUnitStatusBlip( self, blipData, updateBlip, localPlayerIsCommander, baseResearchRot, showHints, playerTeamType )
	
	local CHUDBlipData
	if type(blipData.Hint) == "table" then
		CHUDBlipData = blipData.Hint
		blipData.Hint = CHUDBlipData.Hint
	end
	local isEnemy = (playerTeamType ~= blipData.TeamType) and (blipData.TeamType ~= kNeutralTeamType)	
	local isCrosshairTarget = blipData.IsCrossHairTarget 
	local player = Client.GetLocalPlayer()	
	
	local minnps = CHUDGetOption("minnps") and not localPlayerIsCommander
	
	local showHints = showHints
	
	if minnps then
		showHints = false
	elseif CHUDBlipData then
		-- Show evolve class of friendly players
		if CHUDBlipData.EvolveClass ~= nil and not localPlayerIsCommander then
			blipData.Hint = CHUDBlipData.EvolveClass
			showHints = true
		end
		
		-- Show only destination name when not looking at the tunnel
		if CHUDBlipData.Destination and not isCrosshairTarget and not localPlayerIsCommander then
			blipData.Name = CHUDBlipData.Destination
			blipData.ForceName = true 
			blipData.IsPlayer = true
		end
		
		-- Show tunnel owner when looking at it
		if CHUDBlipData.TunnelOwner then
			blipData.Hint = CHUDBlipData.TunnelOwner
			showHints = true
		end
		
		if CHUDBlipData.EnergyFraction and localPlayerIsCommander then
			blipData.AbilityFraction = CHUDBlipData.EnergyFraction
		end
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
	
	// Make the energy bar orange like in Insight
	if CHUDBlipData and CHUDBlipData.EnergyFraction and localPlayerIsCommander then
		updateBlip.AbilityBarBg:SetColor(Color(1,1,0,1))
	end
	
	-- Minimal Nameplates
	if minnps then
		if CHUDBlipData and updateBlip.NameText:GetIsVisible() then	
			
			if blipData.SpawnFraction ~= nil and not isEnemy and not blipData.IsCrossHairTarget then
				updateBlip.NameText:SetText(string.format("%s (%d%%)", blipData.SpawnerName, blipData.SpawnFraction*100))
				updateBlip.HintText:SetIsVisible(false)
			else
				if blipData.EvolvePercentage ~= nil and not isEnemy and ( blipData.IsPlayer or blipData.IsCrossHairTarget ) then
					updateBlip.NameText:SetText(string.format("%s (%d%%)", blipData.Name, blipData.EvolvePercentage*100))
					if CHUDBlipData.EvolveClass ~= nil then
						blipData.Hint = blipData.Hint .. " - " .. CHUDBlipData.EvolveClass
					end
				else
					updateBlip.NameText:SetText(CHUDBlipData.Description)
				end
				updateBlip.HintText:SetIsVisible(true)
				updateBlip.HintText:SetText( blipData.Hint )
				updateBlip.HintText:SetColor(updateBlip.NameText:GetColor())	
			end

			updateBlip.HealthBarBg:SetIsVisible(false)
			updateBlip.ArmorBarBg:SetIsVisible(false)
			if updateBlip.AbilityBarBg then
				updateBlip.AbilityBarBg:SetIsVisible(false)
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