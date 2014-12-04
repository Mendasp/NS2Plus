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

local originalScoreboardUpdateTeam
originalScoreboardUpdateTeam = Class_ReplaceMethod( "GUIScoreboard", "UpdateTeam",
function(self, updateTeam)
	originalScoreboardUpdateTeam(self, updateTeam)
	
	local teamNumber = updateTeam["TeamNumber"]
	local teamScores = updateTeam["GetScores"]()
	local playerList = updateTeam["PlayerList"]
	local teamNumber = updateTeam["TeamNumber"]
	local teamNameGUIItem = updateTeam["GUIs"]["TeamName"]
	local teamColor = updateTeam["Color"]
	local mouseX, mouseY = Client.GetCursorPosScreen()
	
	local teamAvgSkill = 0
	local numPlayers = table.count(teamScores)
	
	local currentPlayerIndex = 1
	for index, player in pairs(playerList) do
		local playerRecord = teamScores[currentPlayerIndex]
		
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
		
		currentPlayerIndex = currentPlayerIndex + 1
		
		local color = Color(0.5,0.5,0.5,1)
		if playerRecord.isCommander then
			color = GUIScoreboard.kCommanderFontColor * 0.8
		else
			color = teamColor * 0.8
		end
		
		if not self.hoverMenu.background:GetIsVisible() then
			if MouseTracker_GetIsVisible() and GUIItemContainsPoint(player["Background"], mouseX, mouseY) and not GUIItemContainsPoint(player["Voice"], mouseX, mouseY) then
				for i = 1, #player.BadgeItems do
					local badgeItem = player.BadgeItems[i]
					if GUIItemContainsPoint(badgeItem, mouseX, mouseY) and badgeItem:GetIsVisible() then
						self.hoverPlayerClientIndex = 0
						return
					end
				end
				
				self.hoverPlayerClientIndex = playerRecord.ClientIndex
				player["Background"]:SetColor(color)
			end
		elseif GetSteamIdForClientIndex(playerRecord.ClientIndex) == GetSteamIdForClientIndex(self.hoverPlayerClientIndex) then
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

local originalScoreboardSKE
originalScoreboardSKE = Class_ReplaceMethod( "GUIScoreboard", "SendKeyEvent",
function(self, key, down)
	if key == InputKey.MouseButton0 and self.mousePressed["LMB"]["Down"] ~= down and down then
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
			self.hoverMenu:AddButton("Hive profile", openHiveProf)
			
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