local originalDeathMessagesInit = GUIDeathMessages.Initialize
function GUIDeathMessages:Initialize()
	originalDeathMessagesInit(self)

	self.scale = CHUDGetOption("killfeedscale")

	self:OnResolutionChanged() --apply new scale
end

local originalDeathMessagesUpdate = GUIDeathMessages.Update
function GUIDeathMessages:Update(deltaTime)
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
end