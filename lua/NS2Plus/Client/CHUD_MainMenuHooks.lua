function MainMenu_Open()

	// Don't load or open main menu while debugging (too slow).
	if not GetIsDebugging() or kAllowDebuggingMainMenu then
	
		// Load and set default sound levels
		OptionsDialogUI_OnInit()
		
		if not MainMenu_IsInGame() then
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

		if not gMainMenu then
			gMainMenu = GetGUIManager():CreateGUIScript("menu/GUIMainMenu")
		end
		gMainMenu:SetIsVisible(true)
		
		MainMenu_OnOpenMenu()
		
	end
	
end