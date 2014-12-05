local team1Skill, team2Skill

local kSteamProfileURL = "http://steamcommunity.com/profiles/"
local kHiveProfileURL = "http://hive.naturalselection2.com/profile/"

local originalScoreboardInit
originalScoreboardInit = Class_ReplaceMethod( "GUIScoreboard", "Initialize",
function(self)
	originalScoreboardInit(self)
	self.hoverMenu = GetGUIManager():CreateGUIScriptSingle("GUIHoverMenu")
	
	self.hoverPlayerClientIndex = 0
end)

local kPlayerItemLeftMargin = 10
local kPlayerVoiceChatIconSize = 20
local kPlayerBadgeRightPadding = 4

local originalScoreboardCreatePlayerItem
originalScoreboardCreatePlayerItem = Class_ReplaceMethod( "GUIScoreboard", "CreatePlayerItem",
function(self)
	
	local reusedItems = table.count(self.reusePlayerItems) > 0
	local playerItem = originalScoreboardCreatePlayerItem(self)
	
	if not reusedItems then
		playerItem["Number"]:SetIsVisible(false)
		playerItem["Voice"]:SetIsVisible(false)
		
		local playerTextIcon = GUIManager:CreateGraphicItem()
		playerTextIcon:SetSize(Vector(kPlayerVoiceChatIconSize, kPlayerVoiceChatIconSize, 0))
		playerTextIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
		playerTextIcon:SetTexture("ui/keyboard.dds")
		playerTextIcon:SetStencilFunc(GUIItem.NotEqual)
		playerTextIcon:SetIsVisible(false)
		playerTextIcon:SetColor(GUIScoreboard.kVoiceMuteColor)
		playerItem["Background"]:AddChild(playerTextIcon)
		
		local steamFriendIcon = GUIManager:CreateGraphicItem()
		steamFriendIcon:SetSize(Vector(kPlayerVoiceChatIconSize, kPlayerVoiceChatIconSize, 0))
		steamFriendIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
		steamFriendIcon:SetTexture("ui/steamfriend.dds")
		steamFriendIcon:SetStencilFunc(GUIItem.NotEqual)
		steamFriendIcon:SetIsVisible(false)
		playerItem["Background"]:AddChild(steamFriendIcon)
		
		playerItem["Text"] = playerTextIcon
		playerItem["SteamFriend"] = steamFriendIcon
	end
	
	return playerItem
	
end)

local originalScoreboardUpdateTeam
originalScoreboardUpdateTeam = Class_ReplaceMethod( "GUIScoreboard", "UpdateTeam",
function(self, updateTeam)
	originalScoreboardUpdateTeam(self, updateTeam)
	
	local GetTeamItemWidth = GetUpValue( GUIScoreboard.Update, "GetTeamItemWidth", { LocateRecurse = true } )
	
	local teamNumber = updateTeam["TeamNumber"]
	local teamScores = updateTeam["GetScores"]()
	local playerList = updateTeam["PlayerList"]
	local teamNameGUIItem = updateTeam["GUIs"]["TeamName"]
	local teamColor = updateTeam["Color"]
	local mouseX, mouseY = Client.GetCursorPosScreen()
	
	local teamAvgSkill = 0
	local numPlayers = table.count(teamScores)
	
	local currentPlayerIndex = 1
	for index, player in pairs(playerList) do
		local playerRecord = teamScores[currentPlayerIndex]
		currentPlayerIndex = currentPlayerIndex + 1
		local clientIndex = playerRecord.ClientIndex
		local steamId = GetSteamIdForClientIndex(clientIndex)
		
		// Swap KDA/KAD
		if CHUDGetOption("kda") and player["Assists"]:GetPosition().x < player["Deaths"]:GetPosition().x then
			local temp = player["Assists"]:GetPosition()
			player["Assists"]:SetPosition(player["Deaths"]:GetPosition())
			player["Deaths"]:SetPosition(temp)
		end
		
		if self.showPlayerSkill then
			player["Name"]:SetText(string.format("[%s] %s", playerRecord.Skill, player["Name"]:GetText()))
			player["Status"]:SetText("")
		end
		
		teamAvgSkill = teamAvgSkill + playerRecord.Skill
		
		for i = 1, #player["BadgeItems"] do
			player["BadgeItems"][i]:SetPosition(Vector(kPlayerItemLeftMargin + (i-1) * kPlayerVoiceChatIconSize + (i-1) * kPlayerBadgeRightPadding, -kPlayerVoiceChatIconSize/2, 0))
		end
		
		local statusPos = ConditionalValue(GUIScoreboard.screenWidth < 1280, GUIScoreboard.kPlayerItemWidth + 30, (GetTeamItemWidth() - GUIScoreboard.kTeamColumnSpacingX * 10) + 60)
		local playerStatus = player["Status"]:GetText()
		if playerStatus == "-" or playerStatus == "" then
			player["Status"]:SetText("")
			statusPos = statusPos + GUIScoreboard.kTeamColumnSpacingX * 1.7
		end
		
		local numBadges = math.min(#Badges_GetBadgeTextures(clientIndex, "scoreboard"), #player["BadgeItems"])
		local pos = kPlayerItemLeftMargin + numBadges * kPlayerVoiceChatIconSize + numBadges * kPlayerBadgeRightPadding
		
		player["Name"]:SetPosition(Vector(pos, 0, 0))
		
		local voiceMuted = ChatUI_GetClientMuted(clientIndex)
		local textMuted = ChatUI_GetSteamIdTextMuted(steamId)
		local isSteamFriend = playerRecord.IsSteamFriend
		
		local nameRightPos = pos + kPlayerBadgeRightPadding
		
		pos = statusPos - kPlayerVoiceChatIconSize - kPlayerBadgeRightPadding
		
		if isSteamFriend then
			player["SteamFriend"]:SetPosition(Vector(pos, -kPlayerVoiceChatIconSize/2, 0))
			pos = pos - kPlayerVoiceChatIconSize - kPlayerBadgeRightPadding
		end
		player["SteamFriend"]:SetIsVisible(isSteamFriend)
		
		if voiceMuted then
			player["Voice"]:SetPosition(Vector(pos, -kPlayerVoiceChatIconSize/2, 0))
			pos = pos - kPlayerVoiceChatIconSize - kPlayerBadgeRightPadding
		end
		player["Voice"]:SetIsVisible(voiceMuted)
		player["Voice"]:SetColor(GUIScoreboard.kVoiceMuteColor)
		
		if textMuted then
			player["Text"]:SetPosition(Vector(pos, -kPlayerVoiceChatIconSize/2, 0))
			pos = pos - kPlayerVoiceChatIconSize - kPlayerBadgeRightPadding
		end
		player["Text"]:SetIsVisible(textMuted)
		
		pos = pos + kPlayerVoiceChatIconSize + kPlayerBadgeRightPadding
		
		local finalName = player["Name"]:GetText()
		while nameRightPos + player["Name"]:GetTextWidth(finalName) > pos do
			finalName = string.sub(finalName, 1, string.len(finalName)-2)
			player["Name"]:SetText(finalName .. "...")
		end
		
		local color = Color(0.5, 0.5, 0.5, 1)
		if playerRecord.IsCommander then
			color = GUIScoreboard.kCommanderFontColor * 0.8
		else
			color = teamColor * 0.8
		end
		
		-- If the player is our steam friend it will show white
		-- Ignoring if he's a rookie or not
		if playerRecord.IsRookie then
			player["Name"]:SetColor(kNewPlayerColorFloat)
		end
		
		if not self.hoverMenu.background:GetIsVisible() then
			if MouseTracker_GetIsVisible() and
				GUIItemContainsPoint(player["Background"], mouseX, mouseY) and
				not (GUIItemContainsPoint(player["Voice"], mouseX, mouseY) and player["Voice"]:GetIsVisible()) and 
				not (GUIItemContainsPoint(player["Text"], mouseX, mouseY) and player["Text"]:GetIsVisible()) then
				local canHighlight = true
				for i = 1, #player.BadgeItems do
					local badgeItem = player.BadgeItems[i]
					if GUIItemContainsPoint(badgeItem, mouseX, mouseY) and badgeItem:GetIsVisible() then
						canHighlight = false
						self.hoverPlayerClientIndex = 0
						break
					end
				end
			
				if canHighlight then
					self.hoverPlayerClientIndex = clientIndex
					player["Background"]:SetColor(color)
				end
			end
		elseif steamId == GetSteamIdForClientIndex(self.hoverPlayerClientIndex) then
			player["Background"]:SetColor(color)
		end
	end

	if (teamNumber == 1 or teamNumber == 2) and teamAvgSkill > 0 and self.showAvgSkill then
		local skill = teamAvgSkill/numPlayers
		if teamNumber == 1 then
			team1Skill = skill
		elseif teamNumber == 2 then
			team2Skill = skill
		end
		
		teamNameGUIItem:SetText(string.format("%s (Avg. skill: %d)", teamNameGUIItem:GetText(), skill))
	end
end)

local originalScoreboardInit
originalScoreboardInit = Class_ReplaceMethod( "GUIScoreboard", "Initialize",
function(self)
	originalScoreboardInit(self)
	
	self.avgSkillItem = nil
end)

local originalScoreboardUpdate
originalScoreboardUpdate = Class_ReplaceMethod( "GUIScoreboard", "Update",
function(self, deltaTime)
	
	if not self.hoverMenu.background:GetIsVisible() then
		self.hoverPlayerClientIndex = 0
	end
	
	originalScoreboardUpdate(self, deltaTime)
	
	if not self.visible then
		self.hoverMenu:Hide()
	end
	
	self.centerOnPlayer = CHUDGetOption("sbcenter")
	local _, pgp = Shine and Shine:IsExtensionEnabled( "pregameplus" )
	local pgpEnabled = pgp and pgp.dt and pgp.dt.Enabled

	self.showPlayerSkill = GetGameInfoEntity().showPlayerSkill and (pgpEnabled or not PlayerUI_GetHasGameStarted())
	self.showAvgSkill = GetGameInfoEntity().showAvgSkill
	
	if self.showAvgSkill == true then
		if not self.avgSkillItem then
			self.avgSkillItem = GUIManager:CreateTextItem()
			self.avgSkillItem:SetFontName(GUIScoreboard.kGameTimeFontName)
			self.avgSkillItem:SetAnchor(GUIItem.Middle, GUIItem.Center)
			self.avgSkillItem:SetTextAlignmentX(GUIItem.Align_Center)
			self.avgSkillItem:SetTextAlignmentY(GUIItem.Align_Center)
			self.avgSkillItem:SetColor(Color(1, 1, 1, 1))
			self.avgSkillItem:SetText("")
			self.gameTimeBackground:AddChild(self.avgSkillItem)
			
			GUIScoreboard.kGameTimeBackgroundSize.y = GUIScale(48)
			self.gameTimeBackground:SetSize(GUIScoreboard.kGameTimeBackgroundSize)
			self.slidebarBg:SetSize(Vector(GUIScoreboard.kSlidebarSize.x, GUIScoreboard.kBgMaxYSpace-20-GUIScale(32), 0))
			self.avgSkillItem:SetPosition(Vector(0, GUIScale(12), 0))
		end
		
		local team1Players = #self.teams[2]["GetScores"]()
		local team2Players = #self.teams[3]["GetScores"]()
		local skillText = ""

		if team1Players > 0 and team2Players > 0 and team1Skill and team2Skill then
			skillText = string.format("Avg. marine skill: %d | Avg. alien skill: %d", team1Skill, team2Skill)
		elseif team1Players > 0 and team1Skill then
			skillText = string.format("Avg. marine skill: %d", team1Skill)
		elseif team2Players > 0 and team2Skill then
			skillText = string.format("Avg. alien skill: %d", team2Skill)
		end
		
		if skillText == "" then
			self.gameTime:SetPosition(Vector(0, 0, 0))
		else
			self.gameTime:SetPosition(Vector(0, -GUIScale(12), 0))
		end
		
		self.avgSkillItem:SetText(skillText)
		
	end
end)

local function newHandlePlayerVoiceClicked(self)

	local mouseX, mouseY = Client.GetCursorPosScreen()
	for t = 1, #self.teams do
	
		local playerList = self.teams[t]["PlayerList"]
		for p = 1, #playerList do
		
			local playerItem = playerList[p]
			if GUIItemContainsPoint(playerItem["Voice"], mouseX, mouseY) and playerItem["Voice"]:GetIsVisible() then
			
				local clientIndex = playerItem["ClientIndex"]
				ChatUI_SetClientMuted(clientIndex, not ChatUI_GetClientMuted(clientIndex))
				
			end
			
		end
		
	end
	
end

local function HandlePlayerTextClicked(self)

	local mouseX, mouseY = Client.GetCursorPosScreen()
	for t = 1, #self.teams do
	
		local playerList = self.teams[t]["PlayerList"]
		for p = 1, #playerList do
		
			local playerItem = playerList[p]
			if GUIItemContainsPoint(playerItem["Text"], mouseX, mouseY) and playerItem["Text"]:GetIsVisible() then
			
				local clientIndex = playerItem["ClientIndex"]
				local steamId = GetSteamIdForClientIndex(clientIndex)
				ChatUI_SetSteamIdTextMuted(steamId, not ChatUI_GetSteamIdTextMuted(steamId))
				
			end
			
		end
		
	end
	
end

ReplaceLocals(GUIScoreboard.SendKeyEvent, { HandlePlayerVoiceClicked = newHandlePlayerVoiceClicked })

local originalScoreboardSKE
originalScoreboardSKE = Class_ReplaceMethod( "GUIScoreboard", "SendKeyEvent",
function(self, key, down)
	if key == InputKey.MouseButton0 and self.mousePressed["LMB"]["Down"] ~= down and down then
		HandlePlayerTextClicked(self)
		
		local steamId = GetSteamIdForClientIndex(self.hoverPlayerClientIndex) or 0
		if self.hoverMenu.background:GetIsVisible() then
			return false
		elseif steamId ~= 0 then
			local isTextMuted = ChatUI_GetSteamIdTextMuted(steamId)
			local isVoiceMuted = ChatUI_GetClientMuted(self.hoverPlayerClientIndex)
			local function openSteamProf()
				Client.ShowWebpage(string.format("%s[U:1:%s]", kSteamProfileURL, steamId))
			end
			local function openHiveProf()
				Client.ShowWebpage(string.format("%s%s", kHiveProfileURL, steamId))
			end
			local function muteText()
				ChatUI_SetSteamIdTextMuted(steamId, not isTextMuted)
			end
			local function muteVoice()
				ChatUI_SetClientMuted(self.hoverPlayerClientIndex, not isVoiceMuted)
			end
		
			self.hoverMenu:ResetButtons()
			self.hoverMenu:AddButton("Steam profile", openSteamProf)
			self.hoverMenu:AddButton("NS2 profile", openHiveProf)
			
			if Client.GetSteamId() ~= steamId then
				self.hoverMenu:AddButton(ConditionalValue(isVoiceMuted, "Unm", "M") .. "ute voice", muteVoice)
				self.hoverMenu:AddButton(ConditionalValue(isTextMuted, "Unm", "M") .. "ute text", muteText)
			end
			
			self.hoverMenu:Show()
		end
	end
	
	return originalScoreboardSKE(self, key, down)
end)

local originalLocaleResolveString = Locale.ResolveString
function Locale.ResolveString(string)
	if string == "SB_ASSISTS" and CHUDGetOption("kda") then
		return originalLocaleResolveString("SB_DEATHS")
	elseif string == "SB_DEATHS" and CHUDGetOption("kda") then
		return originalLocaleResolveString("SB_ASSISTS")
	else
		return originalLocaleResolveString(string)
	end
end