Script.Load("lua/Shared/CHUD_Shared.lua")

Script.Load("lua/CHUD_Particles.lua")
Script.Load("lua/CHUD_MainMenu.lua")
Script.Load("lua/CHUD_Settings.lua")
Script.Load("lua/CHUD_Options.lua")
Script.Load("lua/CHUD_Atmospherics.lua")
Script.Load("lua/CHUD_Lights.lua")
Script.Load("lua/CHUD_UnitStatus.lua")
Script.Load("lua/CHUD_PlayerClient.lua")
Script.Load("lua/CHUD_Tracers.lua")
Script.Load("lua/CHUD_ScoreDisplay.lua")
Script.Load("lua/CHUD_Stats.lua")
Script.Load("lua/CHUD_ServerBrowser.lua")
Script.Load("lua/CHUD_Sounds.lua")
Script.Load("lua/CHUD_Hitsounds.lua")
Script.Load("lua/CHUD_Outlines.lua")

function AnnounceCHUD()
	Shared.Message("NS2+ loaded. Type \"plus\" in console for available commands. You can also customize your game from the menu.")
	GetCHUDSettings()
end

Event.Hook("LoadComplete", AnnounceCHUD)
Event.Hook("LoadComplete", SetCHUDCinematics)
Event.Hook("LoadComplete", SetCHUDAmbients)
Event.Hook("LocalPlayerChanged", CHUDLoadLights)

AddClientUIScriptForClass("Marine", "CHUDGUI_DeathStats")
AddClientUIScriptForClass("Alien", "CHUDGUI_DeathStats")
AddClientUIScriptForClass("Spectator", "CHUDGUI_DeathStats")

AddClientUIScriptForClass("Marine", "CHUDGUI_ClassicAmmo")


function Client.AddWorldMessage(messageType, message, position, entityId)

    // Only add damage messages if we have it enabled
    if messageType ~= kWorldTextMessageType.Damage or Client.GetOptionBoolean( "drawDamage", true ) then

        // If we already have a message for this entity id, update existing message instead of adding new one
        local time = Client.GetTime()
            
        local updatedExisting = false
        
        if messageType == kWorldTextMessageType.Damage then
        
            for _, currentWorldMessage in ipairs(Client.worldMessages) do
            
                if currentWorldMessage.messageType == messageType and currentWorldMessage.entityId == entityId and entityId ~= nil and entityId ~= Entity.invalidId then
					
					// When you have a flamethrower this creates new messages when the ground is in flames too
					// Let's just check that we have a shotgun active
					local player = Client.GetLocalPlayer()
					local weapon = player and player:GetActiveWeapon()
					local diff = weapon and weapon:isa("Shotgun") and CHUDGetOption( "uniqueshotgunhits" ) and time - currentWorldMessage.creationTime
					
					if diff and diff < 0.001 then
						currentWorldMessage.canAccumulate = false
					end
					
					if diff and diff < 0.001 or currentWorldMessage.canAccumulate then
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
				worldMessage.canAccumulate = true
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