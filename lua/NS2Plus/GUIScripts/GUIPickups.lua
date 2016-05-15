local originalInit
originalInit = Class_ReplaceMethod( "GUIPickups", "Initialize",
	function(self)
		originalInit(self)
			
		GUIPickups.kShouldShowExpirationBars = CHUDGetOption("pickupexpire") > 0
		GUIPickups.kOnlyShowExpirationBarsForWeapons = CHUDGetOption("pickupexpire") == 1
		GUIPickups.kUseColorIndicatorForExpirationBars = CHUDGetOption("pickupexpirecolor") > 0
	end)