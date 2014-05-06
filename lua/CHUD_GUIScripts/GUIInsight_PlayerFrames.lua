Script.Load("lua/GUIInsight_PlayerFrames.lua")

local originalIPFUpdatePlayer = GUIInsight_PlayerFrames.UpdatePlayer
function GUIInsight_PlayerFrames:UpdatePlayer(player, playerRecord, team, yPosition)

	local playerName = playerRecord.Name
	local newStatus = playerRecord.Status
	local teamNumber = team["TeamNumber"]
	
	if newStatus ~= player.status then

		local oldStatus = player.status

		if newStatus == Locale.ResolveString("STATUS_DEAD") then
		
			if player.Name:GetText() == playerName then

				local texture = nil
				local textureCoordinates = nil
				if oldStatus == Locale.ResolveString("STATUS_LERK") then
					texture = "ui/Lerk.dds"
					textureCoordinates = {0, 0, 284, 253}
				end
				
				if texture ~= nil then
				
					local position = player["Background"]:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight())
					local text = string.format("%s %s Has Died", oldStatus, playerName)
					local icon = {Texture = texture, TextureCoordinates = textureCoordinates, Color = Color(1,1,1,0.25), Size = Vector(0,0,0)}
					local info = {Text = text, Scale = Vector(0.2,0.2,0.2), Color = Color(0.5,0.5,0.5,0.5), ShadowColor = Color(0,0,0,0.5)}
					local alert = GUIInsight_AlertQueue:CreateAlert(position, icon, info, teamNumber)
					GUIInsight_AlertQueue:AddAlert(alert, Color(1,1,1,1), Color(1,1,1,1))
					
				end
			
			end
		
		end
		
	end

	originalIPFUpdatePlayer(self, player, playerRecord, team, yPosition)
	
	for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
		if playerInfo.playerId == playerRecord.EntityId then
			local nameColor = ConditionalValue(playerInfo.isParasited, kCommanderColorFloat, Color(1,1,1,1))
			player["Name"]:SetColor(nameColor)
		
			if not player["Background"].ups then
			
				local pos = 0
				if playerInfo.teamNumber == kTeam2Index then
					pos = -144
				end

				local ups = { }
				
				for i = 1, 3 do
					ups[i] = GUIManager:CreateGraphicItem()
					ups[i]:SetSize(GUIScale(Vector(48, 48, 0)))
					ups[i]:SetAnchor(GUIItem.Right, GUIItem.Top)
					ups[i]:SetTexture("ui/blank.dds")
					ups[i]:SetTexturePixelCoordinates(unpack({0,0,256,92}))
					ups[i]:SetPosition(GUIScale(Vector(pos, -8, 0)))
					pos = pos + ConditionalValue(playerInfo.teamNumber == kTeam1Index, 40, -40)
				end
				
				player["Background"].ups = ups
				for i = 1, 3 do
					player["Background"]:AddChild(player["Background"].ups[i])
				end

			end
			local result = { }

			for i in string.gmatch(playerInfo.extraTech, "%S+") do
				table.insert(result, i)
			end

			for i = 1, 3 do
				if #result >= i then
					player["Background"].ups[i]:SetTexture("ui/buildmenu.dds")
					player["Background"].ups[i]:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(tonumber(result[i]))))
					player["Background"].ups[i]:SetColor(ConditionalValue(playerInfo.teamNumber == kTeam1Index, Color(0.8, 0.95, 1, 1), Color(1, 0.792, 0.227)))
				else
					player["Background"].ups[i]:SetTexture("ui/blank.dds")
				end
			end

		end
	end
end