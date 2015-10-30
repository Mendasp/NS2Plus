local kNS2StatsProfileURL = "http://ns2stats.com/player/ns2id/"
local team1Skill, team2Skill, textHeight, teamItemWidth

local originalScoreboardUpdateTeam
originalScoreboardUpdateTeam = Class_ReplaceMethod( "GUIScoreboard", "UpdateTeam",
function(self, updateTeam)
	originalScoreboardUpdateTeam(self, updateTeam)
	
	local teamGUIItem = updateTeam["GUIs"]["Background"]
	local teamNumber = updateTeam["TeamNumber"]
	local teamScores = updateTeam["GetScores"]()
	local playerList = updateTeam["PlayerList"]
	
	local teamAvgSkill = 0
	local numPlayers = table.count(teamScores)
	
	-- Resize the player list if it doesn't match.
	if table.count(playerList) ~= numPlayers then
		self:ResizePlayerList(playerList, numPlayers, teamGUIItem)
	end
	
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
	self.avgSkillItemBg:SetAnchor(GUIItem.Middle, GUIItem.Top)
	self.scoreboardBackground:AddChild(self.avgSkillItemBg)
	
	self.avgSkillItem2Bg = GUIManager:CreateGraphicItem()
	self.avgSkillItem2Bg:SetColor(Color(0, 0, 0, 0.75))
	self.avgSkillItem2Bg:SetLayer(kGUILayerScoreboard)
	self.avgSkillItem2Bg:SetAnchor(GUIItem.Middle, GUIItem.Top)
	self.scoreboardBackground:AddChild(self.avgSkillItem2Bg)
	
	self.avgSkillItem = GUIManager:CreateTextItem()
	self.avgSkillItem:SetFontName(GUIScoreboard.kGameTimeFontName)
	self.avgSkillItem:SetScale(Vector(1, 1, 1) * GUIScoreboard.kScalingFactor)
	self.avgSkillItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
	self.avgSkillItem:SetTextAlignmentX(GUIItem.Align_Center)
	self.avgSkillItem:SetTextAlignmentY(GUIItem.Align_Center)
	self.avgSkillItem:SetColor(ColorIntToColor(kMarineTeamColor))
	self.avgSkillItem:SetText("")
	self.avgSkillItem:SetLayer(kGUILayerScoreboard)
	GUIMakeFontScale(self.avgSkillItem)
	
	self.avgSkillItem2 = GUIManager:CreateTextItem()
	self.avgSkillItem2:SetFontName(GUIScoreboard.kGameTimeFontName)
	self.avgSkillItem2:SetScale(Vector(1, 1, 1) * GUIScoreboard.kScalingFactor)
	self.avgSkillItem2:SetAnchor(GUIItem.Middle, GUIItem.Top)
	self.avgSkillItem2:SetTextAlignmentX(GUIItem.Align_Center)
	self.avgSkillItem2:SetTextAlignmentY(GUIItem.Align_Center)
	self.avgSkillItem2:SetColor(kRedColor)
	self.avgSkillItem2:SetText("")
	self.avgSkillItem2:SetLayer(kGUILayerScoreboard)
	GUIMakeFontScale(self.avgSkillItem2)
	
	self.avgSkillItemBg:SetIsVisible(false)
	self.avgSkillItem2Bg:SetIsVisible(false)
	
	teamItemWidth = self.teams[1].GUIs.Background:GetSize().x
	textHeight = self.avgSkillItem:GetTextHeight("Avg") * self.avgSkillItem:GetScale().y
	
	self.avgSkillItemBg:SetSize(Vector(teamItemWidth, textHeight+5*GUIScoreboard.kScalingFactor, 0))
	self.avgSkillItem2Bg:SetSize(Vector(teamItemWidth, textHeight+5*GUIScoreboard.kScalingFactor, 0))
end)

local originalScoreboardUpdate
originalScoreboardUpdate = Class_ReplaceMethod( "GUIScoreboard", "Update",
function(self, deltaTime)
	
	originalScoreboardUpdate(self, deltaTime)
	
	if self.visible then
		self.centerOnPlayer = CHUDGetOption("sbcenter")
		
		-- Shine:IsExtensionEnabled was only returning plugin state, but not the plugin
		local pgpEnabled = Shine and Shine.Plugins and Shine.Plugins["pregameplus"] and Shine.Plugins["pregameplus"].dt and Shine.Plugins["pregameplus"].dt.Enabled

		self.showPlayerSkill = GetGameInfoEntity().showPlayerSkill and (pgpEnabled or not PlayerUI_GetHasGameStarted())
		self.showAvgSkill = GetGameInfoEntity().showAvgSkill

		if self.showAvgSkill == true then
			local team1Players = #self.teams[2]["GetScores"]()
			local team2Players = #self.teams[3]["GetScores"]()
			local hasText = false
			
			self.avgSkillItemBg:SetIsVisible(true)
			self.avgSkillItem2Bg:SetIsVisible(true)
			
			self.scoreboardBackground:AddChild(self.avgSkillItem)
			self.scoreboardBackground:AddChild(self.avgSkillItem2)
			if team1Players > 0 and team2Players > 0 and team1Skill and team2Skill then
				local team1Text = string.format("Avg. marine skill: %d", team1Skill)
				local team2Text = string.format("Avg. alien skill: %d", team2Skill)
				
				self.avgSkillItem:SetText(team1Text)
				self.avgSkillItem2:SetText(team2Text)
				hasText = true
				
				if teamItemWidth*2 > self.scoreboardBackground:GetSize().x then
					local team1TextWidth = self.avgSkillItem:GetTextWidth(self.avgSkillItem:GetText()) * self.avgSkillItem:GetScale().x
					local team2TextWidth = self.avgSkillItem2:GetTextWidth(self.avgSkillItem2:GetText()) * self.avgSkillItem2:GetScale().x
					
					self.avgSkillItem:SetPosition(Vector(-20*GUIScoreboard.kScalingFactor-team1TextWidth/2, textHeight/2+5*GUIScoreboard.kScalingFactor, 0))
					self.avgSkillItem2:SetPosition(Vector(20*GUIScoreboard.kScalingFactor+team2TextWidth/2, textHeight/2+5*GUIScoreboard.kScalingFactor, 0))
					self.avgSkillItem2Bg:SetIsVisible(false)
				else
					self.avgSkillItemBg:AddChild(self.avgSkillItem)
					self.avgSkillItem2Bg:AddChild(self.avgSkillItem2)
					self.avgSkillItem:SetPosition(Vector(0, textHeight/2+5*GUIScoreboard.kScalingFactor, 0))
					self.avgSkillItem2:SetPosition(Vector(0, textHeight/2+5*GUIScoreboard.kScalingFactor, 0))
				end
			elseif team1Players > 0 and team1Skill then
				self.avgSkillItem:SetText(string.format("Avg. marine skill: %d", team1Skill))
				self.avgSkillItem:SetPosition(Vector(0, textHeight/2+5*GUIScoreboard.kScalingFactor, 0))
				
				self.avgSkillItem2:SetText("")
				self.avgSkillItem2Bg:SetIsVisible(false)
				
				hasText = true
			elseif team2Players > 0 and team2Skill then
				self.avgSkillItem2:SetText(string.format("Avg. alien skill: %d", team2Skill))
				self.avgSkillItem2:SetPosition(Vector(0, textHeight/2+5*GUIScoreboard.kScalingFactor, 0))
				
				self.avgSkillItem:SetText("")
				self.avgSkillItemBg:SetIsVisible(false)
				
				hasText = true
			else
				self.avgSkillItem:SetText("")
				self.avgSkillItemBg:SetIsVisible(false)
				
				self.avgSkillItem2:SetText("")
				self.avgSkillItem2Bg:SetIsVisible(false)
			end
			
			local sliderbarBgYSize = GUIScoreboard.kBgMaxYSpace-20*GUIScoreboard.kScalingFactor
			if hasText then
				self.background:SetPosition(Vector(self.background:GetPosition().x, self.background:GetPosition().y+textHeight, 0))
				self.backgroundStencil:SetPosition(Vector(self.backgroundStencil:GetPosition().x, self.backgroundStencil:GetPosition().y+textHeight, 0))
				if self.slidebarBg:GetIsVisible() then
					self.backgroundStencil:SetSize(Vector(self.backgroundStencil:GetSize().x, self.backgroundStencil:GetSize().y-textHeight, 0))
					sliderbarBgYSize = sliderbarBgYSize-textHeight
				end
				
				self.avgSkillItemBg:SetPosition(Vector(self.teams[2].GUIs.Background:GetPosition().x, ConditionalValue(GUIScoreboard.kScalingFactor == 1, 5*GUIScoreboard.kScalingFactor, 0), 0))
				self.avgSkillItem2Bg:SetPosition(Vector(self.teams[3].GUIs.Background:GetPosition().x,  ConditionalValue(GUIScoreboard.kScalingFactor == 1, 5*GUIScoreboard.kScalingFactor, 0), 0))
				
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

local originalLocaleResolveString = Locale.ResolveString
function Locale.ResolveString(resolveString)
	if CHUDGetOption("kda") then
		if resolveString == "SB_ASSISTS" then
			return originalLocaleResolveString("SB_DEATHS")
		elseif resolveString == "SB_DEATHS" then
			return originalLocaleResolveString("SB_ASSISTS")
		else
			return originalLocaleResolveString(resolveString)
		end
	else
		return originalLocaleResolveString(resolveString)
	end
end