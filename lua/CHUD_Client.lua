function ApplyCHUDSettings()
	/*for name, script in pairs(GetGUIManager().scripts) do
		ApplyCHUD(script, script._scriptName)
	end*/
end

Script.Load("lua/CHUD_Shared.lua")
Script.Load("lua/CHUD_Particles.lua")
Script.Load("lua/CHUD_MainMenu.lua")
Script.Load("lua/CHUD_Settings.lua")
Script.Load("lua/CHUD_Options.lua")
Script.Load("lua/CHUD_Lights.lua")
Script.Load("lua/CHUD_UnitStatus.lua")
Script.Load("lua/CHUD_HUDElements.lua")
Script.Load("lua/CHUD_Tracers.lua")
Script.Load("lua/CHUD_ScoreDisplay.lua")
Script.Load("lua/CHUD_Stats.lua")
Script.Load("lua/CHUD_ServerBrowser.lua")
Script.Load("lua/CHUD_Sounds.lua")
Script.Load("lua/CHUD_Hitsounds.lua")
Script.Load("lua/CHUD_Outlines.lua")
Script.Load("lua/CHUD_FlashAtmos.lua")

function AnnounceCHUD()
	Shared.Message("NS2+ loaded. Type \"plus\" in console for available commands. You can also customize your game from the menu.")
	GetCHUDSettings()
end

function OnCommandCHUDStopSound()
	for a = 1, #Client.ambientSoundList do
		Client.ambientSoundList[a]:OnDestroy()
	end
	Client.ambientSoundList = { }
end

Event.Hook("LoadComplete", AnnounceCHUD)
Event.Hook("LoadComplete", SetCHUDCinematics)
Event.Hook("Console_stopsound", OnCommandCHUDStopSound)
Event.Hook("LocalPlayerChanged", CHUDLoadLights)

AddClientUIScriptForClass("Marine", "CHUDGUI_DeathStats")
AddClientUIScriptForClass("Alien", "CHUDGUI_DeathStats")
AddClientUIScriptForClass("Spectator", "CHUDGUI_DeathStats")

AddClientUIScriptForClass("Marine", "CHUDGUI_ClassicAmmo")