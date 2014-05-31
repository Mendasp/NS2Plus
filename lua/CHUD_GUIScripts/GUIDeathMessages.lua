local kBackgroundHeight = 32
local kBackgroundColor = Color(0, 0, 0, 0)
local kBackgroundColorPlayerIsKiller = Color(0, 0, 0, 0.4)
local kFontNames = { marine = "fonts/AgencyFB_small.fnt", alien = "fonts/AgencyFB_small.fnt" }
local kScreenOffset = 40
local kScreenOffsetX = 38
local kBackgroundPadding = 20

local kSustainTime = 4
local kPlayerSustainTime = 4
local kFadeOutTime = 1

local originalGUIDeathMessagesUpdate
originalGUIDeathMessagesUpdate = Class_ReplaceMethod("GUIDeathMessages", "Update",
	function(self, deltaTime)
		originalGUIDeathMessagesUpdate(self, deltaTime)
		
		for i, message in ipairs(self.messages) do
		
			message["Time"] = message["Time"] + deltaTime
			if message["Time"] >= message.sustainTime then
			
				local fadeFraction = (message["Time"]-message.sustainTime) / kFadeOutTime
				local alpha = Clamp( 1-fadeFraction, 0, 1 )
				local currentColor = message["Background"]:GetColor()
				if currentColor.a > 0 then
					currentColor.a = alpha * 0.4
				end
				message["Background"]:SetColor(currentColor)
				
			end
			
		end
	end)

Class_ReplaceMethod("GUIDeathMessages", "AddMessage",
	function(self, killerColor, killerName, targetColor, targetName, iconIndex, targetIsPlayer)

		local style = PlayerUI_IsOnMarineTeam() and "marine" or "alien"
		local xOffset = DeathMsgUI_GetTechOffsetX(0)
		local yOffset = DeathMsgUI_GetTechOffsetY(iconIndex)
		local iconWidth = DeathMsgUI_GetTechWidth(0)
		local iconHeight = DeathMsgUI_GetTechHeight(0)
		
		local insertMessage = { Background = nil, Killer = nil, Weapon = nil, Target = nil, Time = 0 }
		
		// Check if we can reuse an existing message.
		if table.count(self.reuseMessages) > 0 then
		
			insertMessage = self.reuseMessages[1]
			insertMessage["Time"] = 0
			insertMessage["Background"]:SetIsVisible(true)
			table.remove(self.reuseMessages, 1)
			
		end
		
		if insertMessage["Killer"] == nil then
			insertMessage["Killer"] = GUIManager:CreateTextItem()
		end
		
		insertMessage["Killer"]:SetFontName(kFontNames[style])
		insertMessage["Killer"]:SetAnchor(GUIItem.Left, GUIItem.Center)
		insertMessage["Killer"]:SetTextAlignmentX(GUIItem.Align_Max)
		insertMessage["Killer"]:SetTextAlignmentY(GUIItem.Align_Center)
		insertMessage["Killer"]:SetColor(ColorIntToColor(killerColor))
		insertMessage["Killer"]:SetText(killerName)
		
		if insertMessage["Weapon"] == nil then
			insertMessage["Weapon"] = GUIManager:CreateGraphicItem()
		end
		
		insertMessage["Weapon"]:SetSize(Vector(GUIScale(iconWidth), GUIScale(iconHeight), 0))
		insertMessage["Weapon"]:SetAnchor(GUIItem.Left, GUIItem.Center)
		insertMessage["Weapon"]:SetTexture(kInventoryIconsTexture)
		insertMessage["Weapon"]:SetTexturePixelCoordinates(xOffset, yOffset, xOffset + iconWidth, yOffset + iconHeight)
		insertMessage["Weapon"]:SetColor(Color(1, 1, 1, 1))
		
		if insertMessage["Target"] == nil then
			insertMessage["Target"] = GUIManager:CreateTextItem()
		end
		
		insertMessage["Target"]:SetFontName(kFontNames[style])
		insertMessage["Target"]:SetAnchor(GUIItem.Right, GUIItem.Center)
		insertMessage["Target"]:SetTextAlignmentX(GUIItem.Align_Min)
		insertMessage["Target"]:SetTextAlignmentY(GUIItem.Align_Center)
		insertMessage["Target"]:SetColor(ColorIntToColor(targetColor))
		insertMessage["Target"]:SetText(targetName)
		
		local killerTextWidth = insertMessage["Killer"]:GetTextWidth(killerName)
		local targetTextWidth = insertMessage["Target"]:GetTextWidth(targetName)
		local textWidth = killerTextWidth + targetTextWidth
		
		insertMessage["Weapon"]:SetPosition(Vector(killerTextWidth + kBackgroundPadding / 2, -GUIScale(iconHeight) / 2, 0))
		
		if insertMessage["Background"] == nil then
		
			insertMessage["Background"] = GUIManager:CreateGraphicItem()
			insertMessage["Weapon"]:AddChild(insertMessage["Killer"])
			insertMessage["Background"]:AddChild(insertMessage["Weapon"])
			insertMessage["Weapon"]:AddChild(insertMessage["Target"])
			
		end
		
		local player = Client.GetLocalPlayer()
		local backgroundColor = ConditionalValue(player and player:GetName() == killerName and targetIsPlayer, kBackgroundColorPlayerIsKiller, kBackgroundColor)
		
		insertMessage["BackgroundWidth"] = textWidth + GUIScale(iconWidth) + kBackgroundPadding
		insertMessage["Background"]:SetSize(Vector(insertMessage["BackgroundWidth"], kBackgroundHeight, 0))
		insertMessage["Background"]:SetAnchor(GUIItem.Right, GUIItem.Top)
			insertMessage["BackgroundXOffset"] = -textWidth - iconWidth - GUIScale(kScreenOffset) - kScreenOffsetX
		insertMessage["Background"]:SetPosition(Vector(insertMessage["BackgroundXOffset"], 0, 0))
		insertMessage["Background"]:SetColor(backgroundColor)
		insertMessage.sustainTime = ConditionalValue( targetIsPlayer==1, kPlayerSustainTime, kSustainTime )
		
		table.insert(self.messages, insertMessage)
		
	end)