local originalGUIWorldTextInit
originalGUIWorldTextInit = Class_ReplaceMethod( "GUIWorldText", "Initialize",
	function(self)
	
		originalGUIWorldTextInit(self)
		
		local speeds = { [0] = 220, [1] = 800, [2] = 9001 }
		kWorldDamageNumberAnimationSpeed = speeds[CHUDGetOption("fasterdamagenumbers")]
	
	end)

local originalGUIWorldDamageText
originalGUIWorldDamageText = Class_ReplaceMethod( "GUIWorldText", "UpdateDamageMessage",
	function(self, message, messageItem, useColor, deltaTime)
		originalGUIWorldDamageText(self, message, messageItem, useColor, deltaTime)
		local oldalpha = useColor.a
		messageItem:SetScale(messageItem:GetScale()*CHUDGetOption("dmgscale"))
		
		useColorCHUD = ColorIntToColor(ConditionalValue(PlayerUI_IsOnMarineTeam(), CHUDGetOptionAssocVal("dmgcolor_m"), CHUDGetOptionAssocVal("dmgcolor_a")))
		messageItem:SetColor(Color(useColorCHUD.r, useColorCHUD.g, useColorCHUD.b, oldalpha))
	end)
	