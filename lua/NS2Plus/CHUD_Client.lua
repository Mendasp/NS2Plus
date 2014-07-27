Script.Load("lua/NS2Plus/CHUD_Shared.lua")

Script.Load("lua/NS2Plus/Client/CHUD_Particles.lua")
Script.Load("lua/NS2Plus/Client/CHUD_MainMenu.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Settings.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Options.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Atmospherics.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Lights.lua")
Script.Load("lua/NS2Plus/Client/CHUD_UnitStatus.lua")
Script.Load("lua/NS2Plus/Client/CHUD_PlayerClient.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Tracers.lua")
Script.Load("lua/NS2Plus/Client/CHUD_ScoreDisplay.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Stats.lua")
Script.Load("lua/NS2Plus/Client/CHUD_ServerBrowser.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Sounds.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Hitsounds.lua")
Script.Load("lua/NS2Plus/Client/CHUD_EquipmentOutline.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Outlines.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Decals.lua")
Script.Load("lua/NS2Plus/Client/CHUD_WeaponTime.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Dissolve.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Location.lua")

AddClientUIScriptForTeam("all", "NS2Plus/Client/CHUDGUI_DeathStats")
AddClientUIScriptForTeam("all", "NS2Plus/Client/CHUDGUI_EndStats")

local function OnLoadComplete()
	GetCHUDSettings()
	SetCHUDCinematics()
	SetCHUDAmbients()
	Shared.Message("NS2+ loaded. Type \"plus\" in console for available commands. You can also customize your game from the menu.")
end

local function OnLocalPlayerChanged()
	CHUDLoadLights()
	CHUDEvaluateGUIVis()
end

Event.Hook("LoadComplete", OnLoadComplete)
Event.Hook("LocalPlayerChanged", OnLocalPlayerChanged)

function Client.AddWorldMessage(messageType, message, position, entityId)

	// Only add damage messages if we have it enabled
	if messageType ~= kWorldTextMessageType.Damage or Client.GetOptionBoolean( "drawDamage", true ) then

		// If we already have a message for this entity id, update existing message instead of adding new one
		local time = Client.GetTime()
			
		local updatedExisting = false
		
		if messageType == kWorldTextMessageType.Damage and entityId ~= nil and entityId ~= Entity.invalidId then
		
			for _, currentWorldMessage in ipairs(Client.worldMessages) do
			
				if currentWorldMessage.messageType == messageType and currentWorldMessage.entityId == entityId and currentWorldMessage.canAccumulate then

					currentWorldMessage.creationTime = time
					currentWorldMessage.position = position
					currentWorldMessage.previousNumber = tonumber(currentWorldMessage.message)
					currentWorldMessage.message = currentWorldMessage.message + message
					currentWorldMessage.minimumAnimationFraction = kWorldDamageRepeatAnimationScalar
					
					updatedExisting = true
					break
					
				end
				
			end
			
		end
		
		if not updatedExisting then
		
			local worldMessage = {}
			
			worldMessage.messageType = messageType
			worldMessage.message = message
			worldMessage.position = position        
			worldMessage.creationTime = time
			worldMessage.entityId = entityId
			worldMessage.animationFraction = 0
			worldMessage.lifeTime = ConditionalValue(kWorldTextMessageType.CommanderError == messageType, kCommanderErrorMessageLifeTime, kWorldMessageLifeTime)
			
			if messageType == kWorldTextMessageType.Damage then
				
				worldMessage.lifeTime = CHUDGetOption("damagenumbertime")
				
				local player = Client.GetLocalPlayer()
				local weapon = player and player:GetActiveWeapon()
				if weapon and weapon:isa("Shotgun") and CHUDGetOption( "uniqueshotgunhits" ) then
					worldMessage.canAccumulate = false
				else
					worldMessage.canAccumulate = true
				end
					
			end
			
			if messageType == kWorldTextMessageType.CommanderError then
			
				local commander = Client.GetLocalPlayer()
				if commander then
					commander:TriggerInvalidSound()
				end
				
			end
			
			table.insert(Client.worldMessages, worldMessage)
			
		end
		
	end
	
end

local debugLights = false
local oldOnUpdateRender
oldOnUpdateRender = Class_ReplaceMethod( "Shotgun", "OnUpdateRender",
	function( self )

		oldOnUpdateRender( self )

		local parent = self:GetParent()
		if parent and parent:GetIsLocalPlayer() then		
			local viewModel = parent:GetViewModelEntity()
			if viewModel and viewModel:GetRenderModel() then
				local clip = self:GetClip()
				local time = Shared.GetTime()
				if self.lightCount ~= clip and 
					not self.lightChangeTime or self.lightChangeTime + 0.15 < time 
				then
					self.lightCount = clip
					self.lightChangeTime = time
				end
				
				viewModel:InstanceMaterials()
				viewModel:GetRenderModel():SetMaterialParameter("ammo", self.lightCount )
				
			end
		end

end)

local oldBadgesGetBadgeTextures = Badges_GetBadgeTextures
function Badges_GetBadgeTextures( clientId, usecase )
	local badges = oldBadgesGetBadgeTextures( clientId, usecase )
	if usecase == "scoreboard" then
		local steamid = GetSteamIdForClientIndex( clientId )
		if steamid == 49009641 then
			-- remi.D
			badges[#badges+1] = "ui/badges/community_dev_20.dds"
			badges[#badges+1] = "ui/badges/ns2plus_dev_20.dds"
		end
		if steamid == 39843 then
			-- mendasp
			badges[#badges+1] = "ui/badges/ns2plus_dev_20.dds"
		end
	end
	return badges
end
 
Event.Hook( "Console_debugshotgunlights", function()
		debugLights = not debugLights
		EPrint( "Shotgun debugging is %s", debugLights and "ON" or "OFF" )
	end)
