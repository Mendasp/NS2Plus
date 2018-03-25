--move select all button a little down so there is enough space for the time text items
local oldInitializeSelectAllPlayersIcon = GUICommanderButtons.InitializeSelectAllPlayersIcon
function GUICommanderButtons:InitializeSelectAllPlayersIcon()
	GUICommanderButtons.kSelectAllPlayersY = GUIScale(100)

	oldInitializeSelectAllPlayersIcon(self)
end