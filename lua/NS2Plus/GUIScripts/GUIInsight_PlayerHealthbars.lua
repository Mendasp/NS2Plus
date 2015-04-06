Script.Load("lua/GUIInsight_PlayerHealthbars.lua")

local isEnabled = Client.GetOptionBoolean("CHUD_SpectatorHPInsight", false)

local originalIPHBCreatePlayerUI
originalIPHBCreatePlayerUI = Class_ReplaceMethod("GUIInsight_PlayerHealthbars", "CreatePlayerGUIItem",
	function(self)
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
	end)
	
local originalIPHBUpdatePlayers
originalIPHBUpdatePlayers = Class_ReplaceMethod("GUIInsight_PlayerHealthbars", "UpdatePlayers",
	function(self, deltaTime)
		originalIPHBUpdatePlayers(self, deltaTime)
		
		local players = Shared.GetEntitiesWithClassname("Player")
		
		for index, player in ientitylist(players) do

			local playerIndex = player:GetId()
			local relevant = player:GetIsVisible() and player:GetIsAlive() and not player:isa("Commander") and not player:isa("Spectator") and not player:isa("ReadyRoomPlayer")
				
			if relevant then
			
				local playerList = GetUpValue( GUIInsight_PlayerHealthbars.UpdatePlayers, "playerList", { LocateRecurse = true } )
				local health = player:GetHealth()
				local armor = player:GetArmor()

				if playerList[playerIndex] then
					local text = health .. " / " .. armor
					if player:isa("Exo") then
						text = tostring(armor)
					end
					
					local nameHeight = 0
					if isEnabled then
						nameHeight = -(playerList[playerIndex].Name:GetTextHeight(playerList[playerIndex].Name:GetText()))/2
					end
					playerList[playerIndex].Name:SetPosition(Vector(0,nameHeight,0))
					
					playerList[playerIndex].HPText:SetIsVisible(isEnabled)
					playerList[playerIndex].HPText:SetText(text)
					playerList[playerIndex].HPText:SetColor(kNameTagFontColors[player:GetTeamType()])
				end
				
			end
			
		end

	end)
	
local originalIPHBSKE
originalIPHBSKE = Class_ReplaceMethod("GUIInsight_PlayerHealthbars", "SendKeyEvent",
	function(self, key, down)
		local ret = originalIPHBSKE(self, key, down)
		if not ret and GetIsBinding(key, "Use") and not down and not ChatUI_EnteringChatMessage() and not MainMenu_GetIsOpened() then
			isEnabled = not isEnabled
			Client.SetOptionBoolean("CHUD_SpectatorHPInsight", isEnabled)
			return true
		end
		
		return ret
	end)