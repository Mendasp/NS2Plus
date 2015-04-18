local originalFeedbackInit
originalFeedbackInit = Class_ReplaceMethod("GUIFeedback", "Initialize",
	function(self)
		originalFeedbackInit(self)
		
		self.buildText:SetText(self.buildText:GetText() .. " (NS2+ v"  .. kCHUDVersion .. ")")
	end)