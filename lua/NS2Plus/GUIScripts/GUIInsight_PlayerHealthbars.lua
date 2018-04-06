local isEnabled = Client.GetOptionBoolean("CHUD_SpectatorHPInsight", false)

local originalIPHBCreatePlayerUI = GUIInsight_PlayerHealthbars.CreatePlayerGUIItem
function GUIInsight_PlayerHealthbars:CreatePlayerGUIItem()
	local playerUI = originalIPHBCreatePlayerUI(self)

	if not playerUI.HPText then
		local playerHPItem = GUIManager:CreateTextItem()
		playerHPItem:SetFontName(Fonts.kInsight)
		playerHPItem:SetScale(GUIScale(Vector(1,1,1)) * 0.8)
		playerHPItem:SetTextAlignmentX(GUIItem.Align_Center)
		playerHPItem:SetTextAlignmentY(GUIItem.Align_Max)
		playerUI.Background:AddChild(playerHPItem)

		playerUI.HPText = playerHPItem
	end

	return playerUI
end
	
local originalIPHBUpdatePlayers = GUIInsight_PlayerHealthbars.UpdatePlayers
local playerList
function GUIInsight_PlayerHealthbars:UpdatePlayers(deltaTime)
	originalIPHBUpdatePlayers(self, deltaTime)

	local players = Shared.GetEntitiesWithClassname("Player")

	for index, player in ientitylist(players) do

		local playerIndex = player:GetId()
		local relevant = player:GetIsVisible() and player:GetIsAlive() and not player:isa("Commander") and not player:isa("Spectator") and not player:isa("ReadyRoomPlayer")

		if relevant then
			local health = math.max(math.ceil(player:GetHealth()), 1)
			local armor = math.ceil(player:GetArmor())

			if playerList[playerIndex] then
				local text = health .. " / " .. armor
				if player:isa("Exo") then
					text = tostring(math.max(armor, 1))
				end

				local nameHeight = 0
				if isEnabled then
					nameHeight = -(playerList[playerIndex].Name:GetTextHeight(playerList[playerIndex].Name:GetText()) * playerList[playerIndex].Name:GetScale().y) + GUIScale(5)
				end
				playerList[playerIndex].Name:SetPosition(Vector(0,nameHeight,0))

				playerList[playerIndex].HPText:SetIsVisible(isEnabled)
				playerList[playerIndex].HPText:SetText(text)
				playerList[playerIndex].HPText:SetColor(kNameTagFontColors[player:GetTeamType()])
			end

		end

	end
end
debug.joinupvalues(GUIInsight_PlayerHealthbars.UpdatePlayers, originalIPHBUpdatePlayers)
	
local lastDown = false
local originalIPHBSKE = GUIInsight_PlayerHealthbars.SendKeyEvent
function GUIInsight_PlayerHealthbars:SendKeyEvent(key, down)
	local ret = originalIPHBSKE(self, key, down)
	if not ret and GetIsBinding(key, "Use") and lastDown ~= down then
		lastDown = down
		if not down and not ChatUI_EnteringChatMessage() and not MainMenu_GetIsOpened() then
			isEnabled = not isEnabled
			Client.SetOptionBoolean("CHUD_SpectatorHPInsight", isEnabled)
			return true
		end
	end

	return ret
end