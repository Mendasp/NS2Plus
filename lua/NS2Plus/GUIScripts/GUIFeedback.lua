local originalFeedbackInit = GUIFeedback.Initialize
function  GUIFeedback:Initialize()
	originalFeedbackInit(self)

	self.buildText:SetText(self.buildText:GetText() .. " (NS2+ v"  .. kCHUDVersion .. ")")
end