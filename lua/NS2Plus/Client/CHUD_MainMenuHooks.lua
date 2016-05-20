local oldMainMenu_Open = MainMenu_Open
function MainMenu_Open()
	Shared.Message("----------------------------------")
	for i=1,5 do
		Shared.Message( "NS2+ has moved! Please run 'plus_workshop' to open the overlay to the new mod, and ask server ops to update to 28eb0f83.")
	end
	Shared.Message("----------------------------------")
	oldMainMenu_Open()
end

Event.Hook( "Console_plus_workshop", function() Client.ShowWebpage( "http://steamcommunity.com/sharedfiles/filedetails/?id=686493571" ) end )
