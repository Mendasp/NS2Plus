local originalGUIWorldTextInit = GUIWorldText.Initialize
function GUIWorldText:Initialize()

	originalGUIWorldTextInit(self)

	local speeds = { [0] = 220, [1] = 800, [2] = 9001 }
	kWorldDamageNumberAnimationSpeed = speeds[CHUDGetOption("fasterdamagenumbers")]

end

local originalGUIWorldDamageText = GUIWorldText.UpdateDamageMessage
	function GUIWorldText:UpdateDamageMessage(message, messageItem, useColor, deltaTime)
	originalGUIWorldDamageText(self, message, messageItem, useColor, deltaTime)

	local oldalpha = useColor.a
	messageItem:SetScale(messageItem:GetScale()*CHUDGetOption("dmgscale"))

	local useColorCHUD = ColorIntToColor(ConditionalValue(PlayerUI_IsOnMarineTeam(), CHUDGetOption("dmgcolor_m"), CHUDGetOption("dmgcolor_a")))
	messageItem:SetColor(Color(useColorCHUD.r, useColorCHUD.g, useColorCHUD.b, oldalpha))
end
