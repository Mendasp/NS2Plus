local originalIPFUpdatePlayer = GUIInsight_PlayerFrames.UpdatePlayer
function GUIInsight_PlayerFrames:UpdatePlayer(player, playerRecord, team, yPosition)
	originalIPFUpdatePlayer(self, player, playerRecord, team, yPosition)

	for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
		if playerInfo.playerId == playerRecord.EntityId then
			if GUIItemContainsPoint(player["Background"], Client.GetCursorPosScreen()) and playerRecord.Status ~= Locale.ResolveString("STATUS_DEAD") then
				local text = tostring(playerRecord.Health or 0) .. " / " .. tostring(playerRecord.Armor or 0)
				if playerRecord.Status == Locale.ResolveString("STATUS_EXO") then
					text = tostring(playerRecord.Armor or 0)
				end
				player["Detail"]:SetText(text)
			end

			if playerRecord.EntityTeamNumber == kTeam2Index and playerRecord.Tech then
				local currentTech = GetTechIdsFromBitMask(playerRecord.Tech)

				-- Parasite should be in the last position of the array if it exists
				-- If it does, make player name yellow and remove it from the table
				if currentTech[#currentTech] == kTechId.Parasite then
					name:SetColor(kCommanderColorFloat)
					table.remove(currentTech, #currentTech)
				end

				-- Check if we have chambers for each upgrade type
				for i = 1, 3 do
					if #currentTech >= i then
						local isCragUpg = LookupTechData(tonumber(currentTech[i]), kTechDataCategory) == kTechId.CragHive and GetShellLevel(kTeam2Index) == 0
						local isShiftUpg = LookupTechData(tonumber(currentTech[i]), kTechDataCategory) == kTechId.ShiftHive and GetSpurLevel(kTeam2Index) == 0
						local isShadeUpg = LookupTechData(tonumber(currentTech[i]), kTechDataCategory) == kTechId.ShadeHive and GetVeilLevel(kTeam2Index) == 0

						if isCragUpg or isShiftUpg or isShadeUpg then
							player["Upgrades"][i]:SetColor(Color(1, 0, 0, 1))
						else
							player["Upgrades"][i]:SetColor(Color(1, 0.792, 0.227, 1))
						end
					end
				end
			end
		end
	end
end