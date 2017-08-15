local originalInit = GUIPickups.Initialize
function GUIPickups:Initialize()
	originalInit(self)

	GUIPickups.kShouldShowExpirationBars = CHUDGetOption("pickupexpire") > 0
	GUIPickups.kOnlyShowExpirationBarsForWeapons = CHUDGetOption("pickupexpire") == 1
	GUIPickups.kUseColorIndicatorForExpirationBars = CHUDGetOption("pickupexpirecolor") > 0
end