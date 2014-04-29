local CHUDSendStats = CHUDServerOptions["hivestats"].currentValue

local hiveReportStr = ConditionalValue(CHUDSendStats, "Enabled", "Disabled")

Shared.Message("[NS2+] Hive stats reporting is: " .. hiveReportStr)

function CHUDCheckCheats()
	if Shared.GetCheatsEnabled() and CHUDSendStats then
		CHUDSendStats = false
		
		Shared.Message("[NS2+] Cheats enabled. Disabling Hive stats reporting.")
	end
end

originalPlayerBotName = Class_ReplaceMethod("PlayerBot", "UpdateNameAndGender",
	function(self)
		originalPlayerBotName(self)
		
		CHUDSendStats = false
		
		Shared.Message("[NS2+] Bots have been added. Disabling Hive stats reporting.")
	end)

// We check if cheats or bots have been used at any point to disable sending stats
Class_ReplaceMethod("PlayerRanking", "GetTrackServer",
	function(self)
		return CHUDSendStats and ShineGetGamemode() == "ns2"
	end)
	
Event.Hook("UpdateServer", CHUDCheckCheats)