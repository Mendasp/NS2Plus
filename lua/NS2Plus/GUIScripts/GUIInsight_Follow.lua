// FEELIN' LAZY, JUST PUT ALL THIS CRAP IN A SINGLE FILE

Script.Load("lua/GUIInsight_Overhead.lua")
local originalInsightOverheadSendKeyEvent
originalInsightOverheadSendKeyEvent = Class_ReplaceMethod("GUIInsight_Overhead", "SendKeyEvent",
	function(self, key, down)
		// DO NOTHING, HEHEHE!
	end)

local originalInsightOverheadUpdate
originalInsightOverheadUpdate = Class_ReplaceMethod("GUIInsight_Overhead", "Update",
	function(self, deltaTime)
		originalInsightOverheadUpdate(self, deltaTime)
		
		local player = Client.GetLocalPlayer()
		if player == nil then
			return
		end
		
		if player.selectedId then
			local entity = Shared.GetEntity(player.selectedId)
			
			// If we're not in relevancy range, get the position from the mapblips
			if not entity then
				for _, blip in ientitylist(Shared.GetEntitiesWithClassname("MapBlip")) do

					if blip.ownerEntityId == player.selectedId then
					
						local player = Client.GetLocalPlayer()
						local blipOrig = blip:GetOrigin()
						player:SetWorldScrollPosition(blipOrig.x, blipOrig.z)
						
					end
				end
				// Try to get the player again
				entity = Shared.GetEntity(player.selectedId)
			end
			
			// If the player is dead, deselect
			if entity and entity:isa("Player") and entity:GetIsAlive() then
				local origin = entity:GetOrigin()
				player:SetWorldScrollPosition(origin.x, origin.z)
			else
				player.selectedId = Entity.invalidId
			end

		end
	end)
	
Script.Load("lua/GUIInsight_PlayerFrames.lua")
local originalInsightPlayerFramesInit
originalInsightPlayerFramesInit = Class_ReplaceMethod("GUIInsight_PlayerFrames", "Initialize",
	function(self)
		originalInsightPlayerFramesInit(self)
		self.prevKeyStatus = false
	end)
	
local originalInsightPlayerFramesSendKeyEvent
originalInsightPlayerFramesSendKeyEvent = Class_ReplaceMethod("GUIInsight_PlayerFrames", "SendKeyEvent",
	function(self, key, down)
		
		local isVisible = GetUpValue( originalInsightPlayerFramesSendKeyEvent, "isVisible", { LocateRecurse = true } )
		local kPlayersPanelSize = GetUpValue( originalInsightPlayerFramesSendKeyEvent, "kPlayersPanelSize", { LocateRecurse = true } )
		local kFrameYSpacing = GetUpValue( originalInsightPlayerFramesSendKeyEvent, "kFrameYSpacing", { LocateRecurse = true } )
		if isVisible and key == InputKey.MouseButton0 and self.prevKeyStatus ~= down and not down then
			
			local cursor = MouseTracker_GetCursorPos()
			
			for index, team in ipairs(self.teams) do

				local inside, posX, posY = GUIItemContainsPoint( team.Background, cursor.x, cursor.y )
				if inside then
					local player = Client.GetLocalPlayer()
					local index = math.floor( posY / (kPlayersPanelSize.y + kFrameYSpacing) ) + 1
					local entityId = team.PlayerList[index].EntityId
						   
					// When clicking the same player, deselect so it stops following
					if player.selectedId == entityId then
						entityId = Entity.invalidId
					end

					Client.SendNetworkMessage("SpectatePlayer", {entityId = entityId}, true)
					
				end
			end
			
		end
		
		if key == InputKey.MouseButton0 then
			self.prevKeyStatus = down
		end
		
		return false
	end)