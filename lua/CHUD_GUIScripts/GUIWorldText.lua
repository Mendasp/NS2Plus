local originalGUIWorldDamageText
originalGUIWorldDamageText = Class_ReplaceMethod( "GUIWorldText", "UpdateDamageMessage",
	function(self, message, messageItem, useColor, deltaTime)
		originalGUIWorldDamageText(self, message, messageItem, useColor, deltaTime)
		local oldalpha = useColor.a
		if CHUDGetOption("smalldmg") then
			messageItem:SetScale(messageItem:GetScale()*0.5)
		end
		
		useColorCHUD = ColorIntToColor(ConditionalValue(PlayerUI_IsOnMarineTeam(), CHUDGetOptionAssocVal("dmgcolor_m"), CHUDGetOptionAssocVal("dmgcolor_a")))
		messageItem:SetColor(Color(useColorCHUD.r, useColorCHUD.g, useColorCHUD.b, oldalpha))
	end)
	