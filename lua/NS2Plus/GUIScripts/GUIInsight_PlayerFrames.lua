Script.Load("lua/GUIInsight_PlayerFrames.lua")

local originalIPFUpdatePlayer
originalIPFUpdatePlayer = Class_ReplaceMethod("GUIInsight_PlayerFrames", "UpdatePlayer",
	function(self, player, playerRecord, team, yPosition)
		originalIPFUpdatePlayer(self, player, playerRecord, team, yPosition)
		
		for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
			if playerInfo.playerId == playerRecord.EntityId then
				if GUIItemContainsPoint(player["Background"], Client.GetCursorPosScreen()) and playerRecord.Status ~= Locale.ResolveString("STATUS_DEAD") then
					local text = playerRecord.Health .. " / " .. playerRecord.Armor
					if playerRecord.Status == Locale.ResolveString("STATUS_EXO") then
						text = tostring(playerRecord.Armor)
					end
					player["Detail"]:SetText(text)
				end
			end
		end
	end)