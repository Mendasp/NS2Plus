local kCHUDBadges = "https://raw.githubusercontent.com/Mendasp/NS2Plus/master/configs/badges.json"

gCHUDBadgesData = {}
gCHUDBadgesData["ns2plus_dev"] = {scoreboardTexture = "ui/badges/ns2plus_dev_20.dds", formalName = "NS2+ Developer"}
gCHUDBadgesData["ns2plus_god"] = {scoreboardTexture = "ui/badges/ns2plus_dev_20.dds", formalName = "NS2+ God / Developer"}
gCHUDBadgesData["ns2wc_winner"] = {scoreboardTexture = "ui/badges/ns2wc_winner_20.dds", formalName = "NS2WC 2014 Winner"}
gCHUDBadgesData["ns2wc_runnerup"] = {scoreboardTexture = "ui/badges/ns2wc_runnerup_20.dds", formalName = "NS2WC 2014 Finalist"}
gCHUDBadgesData["ns2wc_semi"] = {scoreboardTexture = "ui/badges/ns2wc_semi_20.dds", formalName = "NS2WC 2014 Semifinalist"}

local CHUDBadgesTable = {}
local kCHUDBadgesMessage = 
{
	steamId = "integer",
}

for name, badge in pairs(gCHUDBadgesData) do
	kCHUDBadgesMessage[name] = "boolean"
	if Client and badge["scoreboardTexture"] then
		PrecacheAsset(badge["scoreboardTexture"])
	end
end

Shared.RegisterNetworkMessage("CHUDBadges", kCHUDBadgesMessage)

if Client then
	local oldBadgesGetBadgeTextures = Badges_GetBadgeTextures
	function Badges_GetBadgeTextures( clientId, usecase )
		local badges, badgeNames = oldBadgesGetBadgeTextures( clientId, usecase )
		if usecase == "scoreboard" then
			local steamid = GetSteamIdForClientIndex( clientId )
			if CHUDBadgesTable[steamid] then
				if steamid == 49009641 then
					-- remi.D
					-- Hive doesn't allow to choose only 1, so do it by hand
					badges[#badges+1] = "ui/badges/community_dev_20.dds"
					badgeNames[#badgeNames+1] = "community_dev"
				end
				for key, value in pairs(CHUDBadgesTable[steamid]) do
					if value == true then
						badges[#badges+1] = gCHUDBadgesData[key]["scoreboardTexture"]
						badgeNames[#badgeNames+1] = key
					end
				end
				-- Once it's added, don't go through this again
				CHUDBadgesTable[steamid] = false
			end
		end
		return badges, badgeNames
	end
	
	local oldGetBadgeFormalName = GetBadgeFormalName
	function GetBadgeFormalName(name)
		local formalName = gCHUDBadgesData[name] and gCHUDBadgesData[name]["formalName"]
		return formalName or oldGetBadgeFormalName(name)
	end
	
	Client.HookNetworkMessage("CHUDBadges",
		function(msg) 
			CHUDBadgesTable[msg.steamId] = msg
		end)
end

local function SaveBadgesJSON(response)
	local finalResponseTable = {}
	if response then
		local responseTable = json.decode(response)
		if responseTable and type(responseTable) == "table" then
			finalResponseTable = responseTable
		end
	end
	
	-- Make a lookup table by steamId
	local tmp = {}
	for badgeName, steamIds in pairs(finalResponseTable) do
		for _, curSteamId in ipairs(steamIds) do
			if not tmp[curSteamId] then
				tmp[curSteamId] = {}
			end
			table.insert(tmp[curSteamId], badgeName)
		end
	end
	
	-- Now construct a table of messages to send players
	for steamid, badges in pairs(tmp) do
		local msg = { steamId = steamid }
		for badgeName, _ in pairs(gCHUDBadgesData) do
			msg[badgeName] = table.contains(badges, badgeName)
		end
		table.insert(CHUDBadgesTable, msg)
	end
end

if Server then
	function LoadBadges()
		Shared.SendHTTPRequest(kCHUDBadges, "GET", SaveBadgesJSON)
	end
	
	-- For local testing
	/*local openedFile = io.open("configs/badges.json", "r")
	if openedFile then
		local parsedFile = openedFile:read("*all")
		io.close(openedFile)
		
		if parsedFile then
			SaveBadgesJSON(parsedFile)
		end
	end*/
	
	local function SendBadges(client)
		for _, msg in ipairs(CHUDBadgesTable) do
			Server.SendNetworkMessage(client, "CHUDBadges", msg, true)
		end
	end
	
	Event.Hook("ClientConnect", SendBadges)
	Event.Hook("MapPostLoad", LoadBadges)
end