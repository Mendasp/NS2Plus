local isEnabled = Client.GetOptionBoolean("CHUD_SpectatorHPUnitStatus", true)
local OldUpdateUnitStatusBlip = GUIUnitStatus.UpdateUnitStatusBlip

function GUIUnitStatus:UpdateUnitStatusBlip(blipIndex, localPlayerIsCommander, baseResearchRot, showHints, playerTeamType )
	
	local blipData = self.activeStatusInfo[blipIndex]
	local updateBlip = self.activeBlipList[blipIndex]
	
	local nameplates = not localPlayerIsCommander and CHUDGetOption("nameplates") or 0
	local CHUDBlipData = blipData.CHUDBlipData

	if not CHUDBlipData and type(blipData.Hint) == "table" then
		CHUDBlipData = blipData.Hint
		blipData.CHUDBlipData = CHUDBlipData --write CHUDBlipData into blipdata cache
		blipData.Hint = CHUDBlipData.Hint --restore vanilla hint entry

		if nameplates == 1 or nameplates == 3 then
			blipData.Hint = CHUDBlipData.Status
		end
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
	
	local hideBg = false
	if nameplates == 1 then
		showHints = false
	elseif nameplates == 3 then
		showHints = true
	elseif PlayerUI_GetIsSpecating() and isEnabled and blipData.IsPlayer and playerTeamType == kNeutralTeamType then
		blipData.IsCrossHairTarget = true
		hideBg = true
	end
	
	OldUpdateUnitStatusBlip( self, blipIndex, localPlayerIsCommander, baseResearchRot, showHints, playerTeamType )		
	
	-- Percentages Nameplates
	if nameplates == 1 or nameplates == 3 then
		if CHUDBlipData and updateBlip.NameText:GetIsVisible() then
			
			if CHUDBlipData.Percentage then
				updateBlip.NameText:SetText(CHUDBlipData.Percentage)
			end
			
			if CHUDBlipData.Status then
				updateBlip.HintText:SetText(CHUDBlipData.Status)
			end
			
			updateBlip.HintText:SetIsVisible(true)
			updateBlip.HintText:SetColor(updateBlip.NameText:GetColor())
			
			local barsVisible = nameplates == 3
			updateBlip.HealthBarBg:SetIsVisible(updateBlip.HealthBarBg:GetIsVisible() and barsVisible)
			updateBlip.ArmorBarBg:SetIsVisible(updateBlip.ArmorBarBg:GetIsVisible() and barsVisible)
			if updateBlip.AbilityBarBg then
				updateBlip.AbilityBarBg:SetIsVisible(updateBlip.AbilityBarBg:GetIsVisible() and barsVisible)
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

local oldUnitStatusInit = GUIUnitStatus.Initialize
function GUIUnitStatus:Initialize()
	oldUnitStatusInit(self)

	if CHUDGetOption("smallnps") then
		GUIUnitStatus.kFontScale = GUIScale( Vector(1,1,1) ) * 0.8
		GUIUnitStatus.kActionFontScale = GUIScale( Vector(1,1,1) ) * 0.7
		GUIUnitStatus.kFontScaleProgress = GUIScale( Vector(1,1,1) ) * 0.6
		GUIUnitStatus.kFontScaleSmall = GUIScale( Vector(1,1,1) ) * 0.65
	end

	GUIUnitStatus.kUseColoredWrench = CHUDGetOption("wrenchicon") == 1

end

local function isValidSpectatorMode()
	local player = Client.GetLocalPlayer()
	
	return player ~= nil and player:isa("Spectator") and player.specMode ~= nil and player.specMode == kSpectatorMode.FreeLook
end

local lastDown = false
local originalUnitStatusSKE = GUIUnitStatus.SendKeyEvent
function GUIUnitStatus:SendKeyEvent(key, down)
	local ret = originalUnitStatusSKE(self, key, down)
	local player = Client.GetLocalPlayer()
	if player and not ret and isValidSpectatorMode() and GetIsBinding(key, "Use") and lastDown ~= down then
		lastDown = down
		if not down and not ChatUI_EnteringChatMessage() and not MainMenu_GetIsOpened() then
			isEnabled = not isEnabled
			Client.SetOptionBoolean("CHUD_SpectatorHPUnitStatus", isEnabled)
			return true
		end
	end

	return ret
end