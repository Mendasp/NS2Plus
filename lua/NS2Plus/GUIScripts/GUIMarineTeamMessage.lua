local originalMarineMessage = GUIMarineTeamMessage.SetTeamMessage
function GUIMarineTeamMessage:SetTeamMessage(message)
    originalMarineMessage(self, message)
    if not CHUDGetOption("banners") then
        self.background:SetIsVisible(false)
    end
    if CHUDGetOption("mingui") then
        self.background:DestroyAnimations()
    end
end

