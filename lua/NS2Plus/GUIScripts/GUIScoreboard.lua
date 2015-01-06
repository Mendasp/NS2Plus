local kNS2StatsProfileURL = "http://ns2stats.com/player/ns2id/"
local team1Skill, team2Skill

local originalScoreboardUpdateTeam
originalScoreboardUpdateTeam = Class_ReplaceMethod( "GUIScoreboard", "UpdateTeam",
function(self, updateTeam)
	originalScoreboardUpdateTeam(self, updateTeam)
	
	local GetTeamItemWidth = GetUpValue( GUIScoreboard.Update, "GetTeamItemWidth", { LocateRecurse = true } )
	
	local teamNumber = updateTeam["TeamNumber"]
	local teamScores = updateTeam["GetScores"]()
	local playerList = updateTeam["PlayerList"]
	local teamNameGUIItem = updateTeam["GUIs"]["TeamName"]
	
	local teamAvgSkill = 0
	local numPlayers = table.count(teamScores)
	
	local currentPlayerIndex = 1
	for index, player in pairs(playerList) do
		local playerRecord = teamScores[currentPlayerIndex]
		currentPlayerIndex = currentPlayerIndex + 1
		local clientIndex = playerRecord.ClientIndex
		
		-- Swap KDA/KAD
		if CHUDGetOption("kda") and player["Assists"]:GetPosition().x < player["Deaths"]:GetPosition().x then
			local temp = player["Assists"]:GetPosition()
			player["Assists"]:SetPosition(player["Deaths"]:GetPosition())
			player["Deaths"]:SetPosition(temp)
		end
		
		if self.showPlayerSkill then
			player["Name"]:SetText(string.format("[%s] %s", playerRecord.Skill, player["Name"]:GetText()))
		end
		
		teamAvgSkill = teamAvgSkill + playerRecord.Skill
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
	
	originalScoreboardUpdate(self, deltaTime)
	
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
	local ret = originalScoreboardSKE(self, key, down)
	
	if self.hoverMenu.background:GetIsVisible() then
		local steamId = GetSteamIdForClientIndex(self.hoverPlayerClientIndex) or 0
		local function openNS2StatsProf()
			Client.ShowWebpage(string.format("%s%s", kNS2StatsProfileURL, steamId))
		end
		
		local found = 0
		local added = false
		for index, entry in ipairs(self.hoverMenu.links) do
			if not entry.isSeparator then
				local text = entry.link:GetText()
				if text == Locale.ResolveString("SB_MENU_HIVE_PROFILE") then
					found = index
				elseif text == "NS2Stats profile" then
					added = true
				end
			end
		end
		
		local teamColorBg
		local teamColorHighlight
		local playerName = Scoreboard_GetPlayerData(self.hoverPlayerClientIndex, "Name")
		local teamNumber = Scoreboard_GetPlayerData(self.hoverPlayerClientIndex, "EntityTeamNumber")
		local isCommander = Scoreboard_GetPlayerData(self.hoverPlayerClientIndex, "IsCommander")
		local textColor = Color(1, 1, 1, 1)
		local nameBgColor = Color(0, 0, 0, 0)
		
		if isCommander then
			teamColorBg = GUIScoreboard.kCommanderFontColor
		elseif teamNumber == 1 then
			teamColorBg = GUIScoreboard.kBlueColor
		elseif teamNumber == 2 then
			teamColorBg = GUIScoreboard.kRedColor
		else
			teamColorBg = GUIScoreboard.kSpectatorColor
		end
		
		teamColorHighlight = teamColorBg * 0.75
		teamColorBg = teamColorBg * 0.5
		
		if not added then
			if found > 0 then
				found = found+1
			else
				found = nil
			end
			
			self.hoverMenu:AddButton("NS2Stats profile", teamColorBg, teamColorHighlight, textColor, openNS2StatsProf, found)
		end
	end
	
	return ret
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