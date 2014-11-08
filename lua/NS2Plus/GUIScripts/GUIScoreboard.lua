local team1Skill, team2Skill

local originalScoreboardUpdateTeam
originalScoreboardUpdateTeam = Class_ReplaceMethod( "GUIScoreboard", "UpdateTeam",
function(self, updateTeam)
	originalScoreboardUpdateTeam(self, updateTeam)
	
	local teamNumber = updateTeam["TeamNumber"]
	local teamScores = updateTeam["GetScores"]()
	local playerList = updateTeam["PlayerList"]
	local teamNumber = updateTeam["TeamNumber"]
	local teamNameGUIItem = updateTeam["GUIs"]["TeamName"]
	
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
		
		teamAvgSkill = teamAvgSkill + playerRecord.Skill
		
		currentPlayerIndex = currentPlayerIndex + 1
	end
	
	local showAvgSkill = GetGameInfoEntity().showAvgSkill
	
	if (teamNumber == 1 or teamNumber == 2) and teamAvgSkill > 0 and showAvgSkill then
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
	
	if GetGameInfoEntity().showAvgSkill then
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