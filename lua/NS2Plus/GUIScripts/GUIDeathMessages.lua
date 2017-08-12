local originalDeathMessagesInit
originalDeathMessagesInit = Class_ReplaceMethod("GUIDeathMessages", "Initialize",
	function(self)
		originalDeathMessagesInit(self)
		
		self.scale = CHUDGetOption("killfeedscale")
		
		local CHUDBackgroundHeight = GUIScale(32*CHUDGetOption("killfeediconscale"))
		
		ReplaceUpValue(GUIDeathMessages.AddMessage, "kBackgroundHeight", CHUDBackgroundHeight, { LocateRecurse = true })
	end)

local originalDeathMessagesUpdate
originalDeathMessagesUpdate = Class_ReplaceMethod("GUIDeathMessages", "Update",
	function(self, deltaTime)
		originalDeathMessagesUpdate(self, deltaTime)
		
		for i, message in ipairs(self.messages) do
		
				local currentColor = message["Background"]:GetColor()
				
				if CHUDGetOption("killfeedcolorcustom") then
					local alpha = currentColor.a
					currentColor = ColorIntToColor(CHUDGetOption("killfeedcolor"))
					currentColor.a = alpha
				end
				
				if CHUDGetOption("killfeedhighlight") == 0 then
					currentColor.a = 0
				end

				message["Background"]:SetColor(currentColor)
				-- Left and right elements inherit alpha from their parent
				currentColor.a = 1
				message["Background"].left:SetColor(currentColor)
				message["Background"].right:SetColor(currentColor)
			
		end
	end)