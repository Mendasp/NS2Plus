local originalGUINotificationsInit
originalGUINotificationsInit = Class_ReplaceMethod( "GUINotifications", "Initialize",
	function(self)
		originalGUINotificationsInit(self)
		
		// This is some advanced shit right here
		GUINotifications.kScoreDisplayKillTextColor = ColorIntToColor(CHUDGetOption("scorecolor"))
		GUINotifications.kScoreDisplayTextColor = ColorIntToColor(CHUDGetOption("assistscolor"))
	end)