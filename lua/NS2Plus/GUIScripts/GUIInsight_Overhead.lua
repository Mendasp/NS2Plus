Script.Load("lua/GUIInsight_Overhead.lua")

local originalOverheadUpdate
originalOverheadUpdate = Class_ReplaceMethod("GUIInsight_Overhead", "Update",
	function(self, deltaTime)
	
		if CHUDGetOption("deselectspec") then
			originalOverheadUpdate(self, deltaTime)
		else
			local lastPlayerId = GetUpValue( GUIInsight_Overhead.Update, "lastPlayerId", { LocateRecurse = true } )
			local mouseoverBackground = GetUpValue( GUIInsight_Overhead.Update, "mouseoverBackground", { LocateRecurse = true } )
			local mouseoverText = GetUpValue( GUIInsight_Overhead.Update, "mouseoverText", { LocateRecurse = true } )
			local mouseoverTextBack = GetUpValue( GUIInsight_Overhead.Update, "mouseoverTextBack", { LocateRecurse = true } )
			local GetEntityUnderCursor = GetUpValue( GUIInsight_Overhead.Update, "GetEntityUnderCursor", { LocateRecurse = true } )
			
			local player = Client.GetLocalPlayer()
			if player == nil then
				return
			end
			
			local entityId = player.followId
			-- Only initialize healthbars after the camera has finished animating
			-- Should help smooth transition to overhead
			if not PlayerUI_IsCameraAnimated() then
			
				if self.playerHealthbars == nil then
					self.playerHealthbars = GetGUIManager():CreateGUIScriptSingle("GUIInsight_PlayerHealthbars")
				end
				if self.otherHealthbars == nil then
					self.otherHealthbars = GetGUIManager():CreateGUIScriptSingle("GUIInsight_OtherHealthbars")
				end
				
				if entityId and entityId ~= Entity.invalidId then
					local entity = Shared.GetEntity(entityId)
					
					-- If we're not in relevancy range, get the position from the mapblips
					if not entity then
						for _, blip in ientitylist(Shared.GetEntitiesWithClassname("MapBlip")) do

							if blip.ownerEntityId == entityId then
							
								local blipOrig = blip:GetOrigin()
								player:SetWorldScrollPosition(blipOrig.x, blipOrig.z)
								
							end
						end
						-- Try to get the player again
						entity = Shared.GetEntity(entityId)
					end
					
					if entity and entity:isa("Player") and entity:GetIsAlive() then
						local origin = entity:GetOrigin()
						player:SetWorldScrollPosition(origin.x, origin.z)
					end
					
					if lastPlayerId ~= entityId then
						Client.SendNetworkMessage("SpectatePlayer", {entityId = entityId}, true)
						player.followId = entityId
						lastPlayerId = entityId
					end
				end
				
			end
			
			-- Store entity under cursor
			player.entityUnderCursor = GetEntityUnderCursor(player)
			local entity = player.entityUnderCursor
			
			if entity ~= nil and HasMixin(entity, "Live") and entity:GetIsAlive() then

				local text = ToString(math.ceil(entity:GetHealthScalar() * 100)) .. "%"
				
				if HasMixin(entity, "Construct") then
					if not entity:GetIsBuilt() then
					
						local builtStr
						if entity:GetTeamNumber() == kTeam1Index then
							builtStr = Locale.ResolveString("TECHPOINT_BUILT")
						else
							builtStr = Locale.ResolveString("GROWN")
						end
						local constructionStr = string.format(" (%d%% %s)", math.ceil(entity:GetBuiltFraction()*100), builtStr)
						text = text .. constructionStr   
						
					end
				end
		 
				local xScalar, yScalar = Client.GetCursorPos()
				local x = xScalar * Client.GetScreenWidth()
				local y = yScalar * Client.GetScreenHeight()
				mouseoverBackground:SetPosition(Vector(x + 10, y + 18, 0))
				mouseoverBackground:SetIsVisible(true)
				
				mouseoverText:SetText(text)
				mouseoverTextBack:SetText(text)

			else

				mouseoverBackground:SetIsVisible(false)

			end
		end
	end)
