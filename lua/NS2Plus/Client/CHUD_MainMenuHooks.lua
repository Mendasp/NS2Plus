local oldMainMenu_Open = MainMenu_Open
function MainMenu_Open()
	if (not GetIsDebugging() or kAllowDebuggingMainMenu) and not MainMenu_IsInGame() then
		local check = io.open("lua/NS2Plus/CHUD_Shared.lua", "r")
		if check then
			Script.Load("lua/Class.lua")
			CHUDMainMenu = true
			Script.Load("lua/NS2Plus/CHUD_Shared.lua")
			Script.Load("lua/NS2Plus/Shared/CHUD_Utility.lua")
			Script.Load("lua/NS2Plus/Client/CHUD_MainMenu.lua")
			Script.Load("lua/NS2Plus/Client/CHUD_Settings.lua")
			Script.Load("lua/NS2Plus/Client/CHUD_Options.lua")
			Script.Load("lua/NS2Plus/Client/CHUD_ServerBrowser.lua")
			Script.Load("lua/NS2Plus/Client/CHUD_Hitsounds.lua")
			Script.Load("lua/menu/GUIHoverTooltip.lua")
			Script.Load("lua/NS2Plus/GUIScripts/GUIHoverTooltip.lua")
			GetCHUDSettings()
			io.close(check)
			Shared.Message("NS2+ Main Menu mods loaded. Build " .. kCHUDVersion .. ".")
		else
			Shared.Message("NS2+ has been updated or is not available, not loading main menu mods. A restart will be required when the update is installed (you can do it from the mods menu).")
		end
	end
		
	Shared.Message("----------------------------------")
	for i=1,5 do
		Shared.Message( "NS2+ has moved! Please run 'plus_workshop' to open the overlay to the new mod, and ask server ops to update to 28eb0f83.")
	end
	Shared.Message("----------------------------------")

	oldMainMenu_Open()
end

Event.Hook( "Console_plus_workshop", function() Client.ShowWebpage( "http://steamcommunity.com/sharedfiles/filedetails/?id=686493571" ) end )
