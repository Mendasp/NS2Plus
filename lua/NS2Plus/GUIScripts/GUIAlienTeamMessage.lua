local originalAlienMessage = GUIAlienTeamMessage.SetTeamMessage
function GUIAlienTeamMessage:SetTeamMessage(message)
	originalAlienMessage(self, message)
	if not CHUDGetOption("banners") then
		self.background:SetIsVisible(false)
	end
	if CHUDGetOption("mingui") then
		self.background:DestroyAnimations()
	end
end

