local kBackgroundHeight = 32
local kFontNames = { marine = "fonts/AgencyFB_small.fnt", alien = "fonts/AgencyFB_small.fnt" }
local kScreenOffset = 40
local kScreenOffsetX = 38
local kKillHighlight = PrecacheAsset("ui/killfeed.dds")
local kKillLeftBorderCoords = { 0, 0, 8, 32 }
local kKillMiddleBorderCoords = { 9, 0, 39, 32 }
local kKillRightBorderCoords = { 40, 0, 48, 32 }

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
					currentColor.a = alpha
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
		
		insertMessage["Weapon"]:SetSize(Vector(GUIScale(iconWidth/2), GUIScale(iconHeight/2), 0))
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
		
		insertMessage["Weapon"]:SetPosition(Vector(killerTextWidth, -GUIScale(iconHeight/2) / 2, 0))
		
		if insertMessage["Background"] == nil then
		
			insertMessage["Background"] = GUIManager:CreateGraphicItem()
			insertMessage["Background"].left = GUIManager:CreateGraphicItem()
			insertMessage["Background"].left:SetAnchor(GUIItem.Left, GUIItem.Top)
			insertMessage["Background"].right = GUIManager:CreateGraphicItem()
			insertMessage["Background"].right:SetAnchor(GUIItem.Right, GUIItem.Top)
			insertMessage["Background"]:AddChild(insertMessage["Background"].right)
			insertMessage["Background"]:AddChild(insertMessage["Background"].left)
			insertMessage["Weapon"]:AddChild(insertMessage["Killer"])
			insertMessage["Background"]:AddChild(insertMessage["Weapon"])
			insertMessage["Weapon"]:AddChild(insertMessage["Target"])
			
		end
		
		local player = Client.GetLocalPlayer()
		local alpha = ConditionalValue(player and Client.GetIsControllingPlayer() and player:GetName() == killerName and targetIsPlayer and CHUDGetOption("killfeedhighlight") > 0, 1, 0)
		
		insertMessage["BackgroundWidth"] = textWidth + GUIScale(iconWidth/2)
		insertMessage["Background"]:SetSize(Vector(insertMessage["BackgroundWidth"], kBackgroundHeight, 0))
		insertMessage["Background"]:SetAnchor(GUIItem.Right, GUIItem.Top)
		insertMessage["BackgroundXOffset"] = -textWidth - (iconWidth/2) - GUIScale(kScreenOffset) - kScreenOffsetX
		insertMessage["Background"]:SetPosition(Vector(insertMessage["BackgroundXOffset"], 0, 0))
		insertMessage["Background"]:SetColor(Color(1, 1, 1, alpha))
		insertMessage["Background"]:SetTexture(kKillHighlight)
		insertMessage["Background"]:SetTexturePixelCoordinates(unpack(kKillMiddleBorderCoords))
		insertMessage["Background"].left:SetTexture(kKillHighlight)
		insertMessage["Background"].left:SetTexturePixelCoordinates(unpack(kKillLeftBorderCoords))
		insertMessage["Background"].left:SetSize(Vector(8, kBackgroundHeight, 0))
		insertMessage["Background"].left:SetInheritsParentAlpha(true)
		insertMessage["Background"].left:SetPosition(Vector(-8, 0, 0))
		insertMessage["Background"].right:SetTexture(kKillHighlight)
		insertMessage["Background"].right:SetTexturePixelCoordinates(unpack(kKillRightBorderCoords))
		insertMessage["Background"].right:SetSize(Vector(8, kBackgroundHeight, 0))
		insertMessage["Background"].right:SetInheritsParentAlpha(true)
		insertMessage.sustainTime = ConditionalValue( targetIsPlayer==1, kPlayerSustainTime, kSustainTime )
		
		table.insert(self.messages, insertMessage)
		
	end)