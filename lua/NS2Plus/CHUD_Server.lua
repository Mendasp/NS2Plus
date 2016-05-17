-- Allow customizations for our HUD textures
Server.RemoveFileHashes("ui/centerhudbar.dds")
Server.RemoveFileHashes("ui/bottomhudbar*.dds")
Server.AddFileHashes("NS2Plus/lights/*")

-- Clear tags on map restart
SetCHUDTagBitmask(0)

Script.Load("lua/NS2Plus/Server/CHUD_ServerSettings.lua")
Script.Load("lua/NS2Plus/Server/CHUD_ModUpdater.lua")
Script.Load("lua/NS2Plus/Server/CHUD_ServerStats.lua")
Script.Load("lua/NS2Plus/Server/CHUD_ClientOptions.lua")
Script.Load("lua/NS2Plus/Server/CHUD_DropPack.lua")
Script.Load("lua/NS2Plus/Server/CHUD_Player.lua")

Script.Load("lua/NS2Plus/Server/CHUD_GameInfo.lua")

Shared.Message("------[NS2+ Server Settings]------")

if #CHUDClientOptions > 0 then
	local blockedString = ""
	for _, option in pairs(CHUDClientOptions) do
		if blockedString ~= "" then
			blockedString = blockedString .. ", " .. option
		else
			blockedString = option
		end
	end

	Shared.Message("Blocked client options: " .. blockedString)
end

local showAvgSkill = ConditionalValue(CHUDServerOptions["showavgteamskill"].currentValue, "Enabled", "Disabled")
local showPlayerSkill = ConditionalValue(CHUDServerOptions["showplayerskill"].currentValue, "Enabled", "Disabled")
local showEndStatsAuto = ConditionalValue(CHUDServerOptions["autodisplayendstats"].currentValue, "Enabled", "Disabled")
local showEndStatsTeamBreakdown = ConditionalValue(CHUDServerOptions["endstatsteambreakdown"].currentValue, "Enabled", "Disabled")
local saveStats = ConditionalValue(CHUDServerOptions["savestats"].currentValue, "Enabled", "Disabled")
Shared.Message("Display team avg. skill: " .. showAvgSkill)
Shared.Message("Display player skill pregame: " .. showPlayerSkill)
Shared.Message("Display end game stats automatically on round end: " .. showEndStatsAuto)
Shared.Message("End game team stats scoreboard: " .. showEndStatsTeamBreakdown)
Shared.Message("Save end round stats to file: " .. saveStats)

-- Mod updater setting also depends on shine
if CHUDServerOptions["modupdater"].shine then
	Shared.Message("Shine workshop updater is enabled. Disabling NS2+ mod updater.")
else
	local modUpdStr = ConditionalValue(CHUDServerOptions["modupdater"].currentValue == false, "Disabled", "Enabled")
	Shared.Message("Mod updater: " .. modUpdStr)
	if CHUDServerOptions["modupdater"].currentValue == true then
		Shared.Message("\t- Check every: " .. CHUDServerOptions["modupdatercheckinterval"].currentValue .. " min.")
		Shared.Message("\t- Reminder interval: " .. CHUDServerOptions["modupdaterreminderinterval"].currentValue .. " min.")
	end
end

Shared.Message("----------------------------------")
	for i=1,25 do
		Shared.Message( "NS2+ has moved! Please update servers to modID 28eb0f83")
	end
Shared.Message("----------------------------------")