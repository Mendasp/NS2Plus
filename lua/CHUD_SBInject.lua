// All of this to change 2 letters
// Thanks to bawNg for creating this awesome injection code!
InjectIntoScope(GUIScoreboard.Initialize, function()

	local iconOffset
	local iconSize
	local localGetTeamItemWidth
	InjectIntoScope(CreateTeamBackground, function()
		iconOffset = kIconOffset
		iconSize = kIconSize
		localGetTeamItemWidth = GetTeamItemWidth()
	end)
	
	function CreateTeamBackground(self, teamNumber)

		local color = nil
		local teamItem = GUIManager:CreateGraphicItem()
		
		// Background
		teamItem:SetSize(Vector(localGetTeamItemWidth, GUIScoreboard.kTeamItemHeight, 0))
		if teamNumber == kTeamReadyRoom then
		
			color = GUIScoreboard.kSpectatorColor
			teamItem:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
			teamItem:SetPosition(Vector(-GetTeamItemWidth() / 2, -35, 0))
			
		elseif teamNumber == kTeam1Index then
		
			color = GUIScoreboard.kBlueColor
			teamItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
			teamItem:SetPosition(Vector(-GetTeamItemWidth() - 10, GUIScoreboard.kTeamBackgroundYOffset, 0))
			
		elseif teamNumber == kTeam2Index then
		
			color = GUIScoreboard.kRedColor
			teamItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
			teamItem:SetPosition(Vector(10, GUIScoreboard.kTeamBackgroundYOffset, 0))
			
		end
		
		teamItem:SetColor(Color(0, 0, 0, 0.75))
		teamItem:SetIsVisible(false)
		teamItem:SetLayer(kGUILayerScoreboard)
		
		// Team name text item.
		local teamNameItem = GUIManager:CreateTextItem()
		teamNameItem:SetFontName(GUIScoreboard.kTeamNameFontName)
		teamNameItem:SetAnchor(GUIItem.Left, GUIItem.Top)
		teamNameItem:SetTextAlignmentX(GUIItem.Align_Min)
		teamNameItem:SetTextAlignmentY(GUIItem.Align_Min)
		teamNameItem:SetPosition(Vector(10, 5, 0))
		teamNameItem:SetColor(color)
		teamItem:AddChild(teamNameItem)
		
		// Add team info (team resources and number of players).
		local teamInfoItem = GUIManager:CreateTextItem()
		teamInfoItem:SetFontName(GUIScoreboard.kTeamInfoFontName)
		teamInfoItem:SetAnchor(GUIItem.Left, GUIItem.Top)
		teamInfoItem:SetTextAlignmentX(GUIItem.Align_Min)
		teamInfoItem:SetTextAlignmentY(GUIItem.Align_Min)
		teamInfoItem:SetPosition(Vector(12, GUIScoreboard.kTeamNameFontSize + 7, 0))
		teamInfoItem:SetColor(color)
		teamItem:AddChild(teamInfoItem)
		
		local currentColumnX = Client.GetScreenWidth() / 6
		local playerDataRowY = 10
		
		// Status text item.
		local statusItem = GUIManager:CreateTextItem()
		statusItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
		statusItem:SetAnchor(GUIItem.Left, GUIItem.Top)
		statusItem:SetTextAlignmentX(GUIItem.Align_Min)
		statusItem:SetTextAlignmentY(GUIItem.Align_Min)
		statusItem:SetPosition(Vector(currentColumnX + 60, playerDataRowY, 0))
		statusItem:SetColor(color)
		statusItem:SetText("")
		teamItem:AddChild(statusItem)
		
		currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX * 2 + 33
		
		// Score text item.
		local scoreItem = GUIManager:CreateTextItem()
		scoreItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
		scoreItem:SetAnchor(GUIItem.Left, GUIItem.Top)
		scoreItem:SetTextAlignmentX(GUIItem.Align_Min)
		scoreItem:SetTextAlignmentY(GUIItem.Align_Min)
		scoreItem:SetPosition(Vector(currentColumnX + 30, playerDataRowY, 0))
		scoreItem:SetColor(color)
		scoreItem:SetText(Locale.ResolveString("SB_SCORE"))
		teamItem:AddChild(scoreItem)
		
		currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX + 40
		
		// Kill text item.
		local killsItem = GUIManager:CreateTextItem()
		killsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
		killsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
		killsItem:SetTextAlignmentX(GUIItem.Align_Min)
		killsItem:SetTextAlignmentY(GUIItem.Align_Min)
		killsItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
		killsItem:SetColor(color)
		killsItem:SetText("K")
		teamItem:AddChild(killsItem)
		
		currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
		
		// Assist text item.
		local assistsItem = GUIManager:CreateTextItem()
		assistsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
		assistsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
		assistsItem:SetTextAlignmentX(GUIItem.Align_Min)
		assistsItem:SetTextAlignmentY(GUIItem.Align_Min)
		assistsItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
		assistsItem:SetColor(color)
		if CHUDGetOption("kda") then
			assistsItem:SetText("D")
		else
			assistsItem:SetText("A")
		end
		teamItem:AddChild(assistsItem)
		
		currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
		
		// Deaths text item.
		local deathsItem = GUIManager:CreateTextItem()
		deathsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
		deathsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
		deathsItem:SetTextAlignmentX(GUIItem.Align_Min)
		deathsItem:SetTextAlignmentY(GUIItem.Align_Min)
		deathsItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
		deathsItem:SetColor(color)
		if CHUDGetOption("kda") then
			deathsItem:SetText("A")
		else
			deathsItem:SetText("D")
		end
		teamItem:AddChild(deathsItem)
		
		currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
		
		// Resources text item.
		local resItem = GUIManager:CreateGraphicItem()
		resItem:SetPosition(Vector(currentColumnX , playerDataRowY, 0) + iconOffset)
		resItem:SetTexture("ui/buildmenu.dds")
		resItem:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.CollectResources)))
		resItem:SetSize(iconSize)
		teamItem:AddChild(resItem)
		
		currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
		
		// Ping text item.
		local pingItem = GUIManager:CreateTextItem()
		pingItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
		pingItem:SetAnchor(GUIItem.Left, GUIItem.Top)
		pingItem:SetTextAlignmentX(GUIItem.Align_Min)
		pingItem:SetTextAlignmentY(GUIItem.Align_Min)
		pingItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
		pingItem:SetColor(color)
		pingItem:SetText(Locale.ResolveString("SB_PING"))
		teamItem:AddChild(pingItem)
		
		return { Background = teamItem, TeamName = teamNameItem, TeamInfo = teamInfoItem }
		
	end
end)