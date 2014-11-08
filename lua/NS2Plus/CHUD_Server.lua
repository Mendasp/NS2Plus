Script.Load("lua/NS2Plus/CHUD_Shared.lua")

// Clear tags on map restart
SetCHUDTagBitmask(0)

Script.Load("lua/NS2Plus/Server/CHUD_ServerSettings.lua")
Script.Load("lua/NS2Plus/Server/CHUD_ModUpdater.lua")
Script.Load("lua/NS2Plus/Server/CHUD_ServerStats.lua")
Script.Load("lua/NS2Plus/Server/CHUD_ClientOptions.lua")
Script.Load("lua/NS2Plus/Server/CHUD_DropPack.lua")

Script.Load("lua/NS2Plus/Server/CHUD_CrashFixes.lua")
Script.Load("lua/NS2Plus/Server/CHUD_GameInfo.lua")

Shared.Message("")

if #CHUDClientOptions > 0 then
	local blockedString = ""
	for _, option in pairs(CHUDClientOptions) do
		if blockedString ~= "" then
			blockedString = blockedString .. ", " .. option
		else
			blockedString = option
		end
	end

	Shared.Message("[NS2+] Blocked client options: " .. blockedString)
end

local showAvgSkill = ConditionalValue(CHUDServerOptions["showavgteamskill"].currentValue, "Enabled", "Disabled")
Shared.Message("[NS2+] Display team avg. skill: " .. showAvgSkill)

-- Mod updater setting also depends on shine
if CHUDServerOptions["modupdater"].shine then
	Shared.Message("[NS2+] Shine workshop updater is enabled. Disabling NS2+ mod updater.")
else
	local modUpdStr = ConditionalValue(CHUDServerOptions["modupdater"].currentValue == false, "Disabled", "Enabled")
	Shared.Message("[NS2+] Mod updater: " .. modUpdStr)
	if CHUDServerOptions["modupdater"].currentValue == true then
		Shared.Message("\t- Check every: " .. CHUDServerOptions["modupdatercheckinterval"].currentValue .. " min.")
		Shared.Message("\t- Reminder interval: " .. CHUDServerOptions["modupdaterreminderinterval"].currentValue .. " min.")
	end
end

Shared.Message("")