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
	end
end)

local originalScoreboardInit
originalScoreboardInit = Class_ReplaceMethod( "GUIScoreboard", "Initialize",
function(self)
	originalScoreboardInit(self)
	
	self.avgSkillItemBg = GUIManager:CreateGraphicItem()
	self.avgSkillItemBg:SetColor(Color(0, 0, 0, 0.75))
	self.avgSkillItemBg:SetLayer(kGUILayerScoreboard)
	self.avgSkillItemBg:SetAnchor(GUIItem.Center, GUIItem.Top)
	self.scoreboardBackground:AddChild(self.avgSkillItemBg)
	
	self.avgSkillItem2Bg = GUIManager:CreateGraphicItem()
	self.avgSkillItem2Bg:SetColor(Color(0, 0, 0, 0.75))
	self.avgSkillItem2Bg:SetLayer(kGUILayerScoreboard)
	self.avgSkillItem2Bg:SetAnchor(GUIItem.Center, GUIItem.Top)
	self.scoreboardBackground:AddChild(self.avgSkillItem2Bg)
	
	self.avgSkillItem = GUIManager:CreateTextItem()
	self.avgSkillItem:SetFontName(GUIScoreboard.kGameTimeFontName)
	self.avgSkillItem:SetAnchor(GUIItem.Center, GUIItem.Top)
	self.avgSkillItem:SetTextAlignmentX(GUIItem.Align_Center)
	self.avgSkillItem:SetTextAlignmentY(GUIItem.Align_Center)
	self.avgSkillItem:SetColor(ColorIntToColor(kMarineTeamColor))
	self.avgSkillItem:SetText("")
	self.avgSkillItem:SetLayer(kGUILayerScoreboard)
	self.scoreboardBackground:AddChild(self.avgSkillItem)
	
	self.avgSkillItem2 = GUIManager:CreateTextItem()
	self.avgSkillItem2:SetFontName(GUIScoreboard.kGameTimeFontName)
	self.avgSkillItem2:SetAnchor(GUIItem.Center, GUIItem.Top)
	self.avgSkillItem2:SetTextAlignmentX(GUIItem.Align_Center)
	self.avgSkillItem2:SetTextAlignmentY(GUIItem.Align_Center)
	self.avgSkillItem2:SetColor(kRedColor)
	self.avgSkillItem2:SetText("")
	self.avgSkillItem2:SetLayer(kGUILayerScoreboard)
	self.scoreboardBackground:AddChild(self.avgSkillItem2)
end)

local originalScoreboardUpdate
originalScoreboardUpdate = Class_ReplaceMethod( "GUIScoreboard", "Update",
function(self, deltaTime)
	
	originalScoreboardUpdate(self, deltaTime)
	
	if self.visible then
		self.centerOnPlayer = CHUDGetOption("sbcenter")
		local _, pgp = Shine and Shine:IsExtensionEnabled( "pregameplus" )
		local pgpEnabled = pgp and pgp.dt and pgp.dt.Enabled

		self.showPlayerSkill = GetGameInfoEntity().showPlayerSkill and (pgpEnabled or not PlayerUI_GetHasGameStarted())
		self.showAvgSkill = GetGameInfoEntity().showAvgSkill

		if self.showAvgSkill == true then
			local GetTeamItemWidth = GetUpValue( GUIScoreboard.Update, "GetTeamItemWidth", { LocateRecurse = true } )
			
			local team1Players = #self.teams[2]["GetScores"]()
			local team2Players = #self.teams[3]["GetScores"]()
			local hasText = false

			-- Check if the teams are on top of each other or not
			local isVerticalSB = GetTeamItemWidth()*2 > self.scoreboardBackground:GetSize().x
			local textHeight = self.avgSkillItem:GetTextHeight("Avg")
			local scoreBgVis = self.slidebarBg:GetIsVisible()
			
			self.avgSkillItemBg:SetIsVisible(not scoreBgVis)
			self.avgSkillItem2Bg:SetIsVisible(not scoreBgVis)
			
			if team1Players > 0 and team2Players > 0 and team1Skill and team2Skill then
				local team1Text = string.format("Avg. marine skill: %d", team1Skill)
				local team2Text = string.format("Avg. alien skill: %d", team2Skill)
				
				self.avgSkillItem:SetText(team1Text)
				self.avgSkillItem2:SetText(team2Text)
				hasText = true
				
				if isVerticalSB then
					self.avgSkillItem:SetPosition(Vector(-20-self.avgSkillItem:GetTextWidth(team1Text)/2, textHeight, 0))
					self.avgSkillItem2:SetPosition(Vector(20+self.avgSkillItem2:GetTextWidth(team2Text)/2,textHeight, 0))
					self.avgSkillItem2Bg:SetIsVisible(false)
				else
					self.avgSkillItem:SetPosition(Vector(self.teams[2].GUIs.Background:GetPosition().x+GetTeamItemWidth()/2, textHeight, 0))
					self.avgSkillItem2:SetPosition(Vector(self.teams[3].GUIs.Background:GetPosition().x+GetTeamItemWidth()/2, textHeight, 0))
				end
			elseif team1Players > 0 and team1Skill then
				self.avgSkillItem:SetText(string.format("Avg. marine skill: %d", team1Skill))
				self.avgSkillItem:SetPosition(Vector(0, textHeight, 0))
				
				self.avgSkillItem2:SetText("")
				self.avgSkillItem2Bg:SetIsVisible(false)
				
				hasText = true
			elseif team2Players > 0 and team2Skill then
				self.avgSkillItem2:SetText(string.format("Avg. alien skill: %d", team2Skill))
				self.avgSkillItem2:SetPosition(Vector(0, textHeight, 0))
				
				self.avgSkillItem:SetText("")
				self.avgSkillItemBg:SetIsVisible(false)
				
				hasText = true
			else
				self.avgSkillItem:SetText("")
				self.avgSkillItemBg:SetIsVisible(false)
				
				self.avgSkillItem2:SetText("")
				self.avgSkillItem2Bg:SetIsVisible(false)
			end
			
			local sliderbarBgYSize = GUIScoreboard.kBgMaxYSpace-20
			if hasText then
				self.background:SetPosition(Vector(self.background:GetPosition().x, self.background:GetPosition().y+textHeight, 0))
				self.backgroundStencil:SetPosition(Vector(self.backgroundStencil:GetPosition().x, self.backgroundStencil:GetPosition().y+textHeight, 0))
				if self.slidebarBg:GetIsVisible() then
					self.backgroundStencil:SetSize(Vector(self.backgroundStencil:GetSize().x, self.backgroundStencil:GetSize().y-textHeight, 0))
					sliderbarBgYSize = sliderbarBgYSize-textHeight
				end
				
				local team1TextWidth = self.avgSkillItem:GetTextWidth(self.avgSkillItem:GetText())
				local team2TextWidth = self.avgSkillItem2:GetTextWidth(self.avgSkillItem2:GetText())
				local team1Width = self.teams[2].GUIs.Background:GetSize().x
				local team2Width = self.teams[3].GUIs.Background:GetSize().x
				
				self.avgSkillItemBg:SetSize(Vector(team1Width, textHeight+5, 0))
				self.avgSkillItem2Bg:SetSize(Vector(team2Width, textHeight+5, 0))
				
				self.avgSkillItemBg:SetPosition(Vector(-(team1Width/2)+self.teams[2].GUIs.Background:GetPosition().x+GetTeamItemWidth()/2, 5, 0))
				self.avgSkillItem2Bg:SetPosition(Vector(-(team2Width/2)+self.teams[3].GUIs.Background:GetPosition().x+GetTeamItemWidth()/2, 5, 0))
				
				-- Reposition the slider
				local sliderPos = (self.slidePercentage * self.slidebarBg:GetSize().y/100)
				if sliderPos < self.slidebar:GetSize().y/2 then
					sliderPos = 0
				end
				if sliderPos > self.slidebarBg:GetSize().y - self.slidebar:GetSize().y then
					sliderPos = self.slidebarBg:GetSize().y - self.slidebar:GetSize().y
				end
				self.slidebar:SetPosition(Vector(0, sliderPos, 0))
			end
		end
	end
end)

local originalScoreboardSKE
originalScoreboardSKE = Class_ReplaceMethod( "GUIScoreboard", "SendKeyEvent",
function(self, key, down)
	local ret = originalScoreboardSKE(self, key, down)
	
	if GetIsBinding(key, "Scoreboard") and not down then
		self.hoverMenu:Hide()
	end
	
	if self.visible and self.hoverMenu.background:GetIsVisible() then
		local steamId = GetSteamIdForClientIndex(self.hoverPlayerClientIndex) or 0
		local function openNS2StatsProf()
			Client.ShowWebpage(string.format("%s%s", kNS2StatsProfileURL, steamId))
		end
		
		local found = 0
		local added = false
		local teamColorBg = Color(0.5, 0.5, 0.5, 0.5)
		local teamColorHighlight = Color(0.75, 0.75, 0.75, 0.75)
		local textColor = Color(1, 1, 1, 1)
		for index, entry in ipairs(self.hoverMenu.links) do
			if not entry.isSeparator then
				local text = entry.link:GetText()
				if text == Locale.ResolveString("SB_MENU_HIVE_PROFILE") then
					teamColorBg = entry.bgColor
					teamColorHighlight = entry.bgHighlightColor
					found = index
				elseif text == "NS2Stats profile" then
					added = true
				end
			end
		end
		
		if not added then
			if found > 0 then
				found = found+1
			else
				found = nil
			end
			
			-- Don't add the button if we can't find the one we expect
			if found then
				self.hoverMenu:AddButton("NS2Stats profile", teamColorBg, teamColorHighlight, textColor, openNS2StatsProf, found)
				-- Calling the show function will reposition the menu (in case we're out of the window)
				self.hoverMenu:Show()
			end
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