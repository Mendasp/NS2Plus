local originalGUINotificationsInit = GUINotifications.Initialize
function GUINotifications:Initialize()
	originalGUINotificationsInit(self)

	-- This is some advanced shit right here
	GUINotifications.kScoreDisplayKillTextColor = ColorIntToColor(CHUDGetOption("scorecolor"))
	GUINotifications.kScoreDisplayTextColor = ColorIntToColor(CHUDGetOption("assistscolor"))
end