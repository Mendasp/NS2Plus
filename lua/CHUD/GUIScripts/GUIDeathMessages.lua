local originalGUIDeathMessagesUpdate
originalGUIDeathMessagesUpdate = Class_ReplaceMethod("GUIDeathMessages", "Update",
	function(self, deltaTime)
		originalGUIDeathMessagesUpdate(self, deltaTime)
		
		for i, message in ipairs(self.messages) do
		
			message["Time"] = message["Time"] + deltaTime
			if message["Time"] >= message.sustainTime then
			
				local fadeFraction = (message["Time"]-message.sustainTime) / kFadeOutTime
				local alpha = ConditionalValue(CHUDGetOption("killfeedhighlight") > 0, Clamp( 1-fadeFraction, 0, 1 ), 0)
				local currentColor = message["Background"]:GetColor()
				if currentColor.a > 0 then
					currentColor.a = alpha
				end
				message["Background"]:SetColor(currentColor)
				
			end
			
		end
	end)