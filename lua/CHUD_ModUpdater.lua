// Don't use this updater if the server is already using the Shine one
if Shine and Shine:IsExtensionEnabled( "workshopupdater" ) then
	Shared.Message("Shine Workshop Updater is enabled. Disabling CHUD Mod Updater.")
	return
end

local updateCheckInterval = 15*60
local lastTimeChecked = Shared.GetTime() - updateCheckInterval
local mapChangeNeeded = false
local modsTable = {}

function CHUDParseModInfo(modInfo)
	local response = modInfo["response"]
	if response["result"] == 1 then
		for _, res in pairs(response["publishedfiledetails"]) do
			if res["result"] == 1 and not mapChangeNeeded then
				if modsTable[res["publishedfileid"]] and modsTable[res["publishedfileid"]] ~= res["time_updated"] then
					mapChangeNeeded = true
					SendCHUDMessage("Detected mod update. New players won't be able to join until map change.")
				end
				
				modsTable[res["publishedfileid"]] = res["time_updated"]
			end
		end
	end
end

function CHUDModUpdater()
	if mapChangeNeeded and Server.GetNumPlayers() == 0 then
		SendCHUDMessage("The server is empty. Changing map.")
		MapCycle_CycleMap()
	end

	if lastTimeChecked < Shared.GetTime() - updateCheckInterval then
		lastTimeChecked = Shared.GetTime()
		
		local params = {}
		params["itemcount"] = Server.GetNumActiveMods()
		for modNum = 1, Server.GetNumActiveMods() do
			params["publishedfileids[" .. modNum-1 .. "]"] = tonumber("0x" .. Server.GetActiveModId(modNum))
		end

		if params["itemcount"] > 0 and not mapChangeNeeded then
			Shared.SendHTTPRequest("http://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/", "POST", params, function(result) CHUDParseModInfo(json.decode(result)) end)
		end
	end
end

Event.Hook("UpdateServer", CHUDModUpdater)