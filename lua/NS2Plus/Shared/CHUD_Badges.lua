local kCHUDBadges = "https://raw.githubusercontent.com/Mendasp/NS2Plus/master/configs/badges.json"

gCHUDBadgesData = {}
gCHUDBadgesData["ns2plus_dev"] = {scoreboardTexture = "ui/badges/ns2plus_dev_20.dds", formalName = "NS2+ Developer"}
gCHUDBadgesData["ns2plus_god"] = {scoreboardTexture = "ui/badges/ns2plus_dev_20.dds", formalName = "NS2+ God / Developer"}
gCHUDBadgesData["ns2news"] = {scoreboardTexture = "ui/badges/ns2news_20.dds", formalName = "NS2News Contributor"}
gCHUDBadgesData["golden_pax"] = {scoreboardTexture = "ui/badges/golden_pax_20.dds", formalName = "PAX 2012 (Smurfing Golden exclusive)"}

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
				for key, value in pairs(CHUDBadgesTable[steamid]) do
					if value == true and not table.contains(badgeNames, key) then
						badges[#badges+1] = gCHUDBadgesData[key]["scoreboardTexture"]
						badgeNames[#badgeNames+1] = key
					end
				end
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

local processing = false
local retries = 0
local function SaveBadgesJSON(response)
	local finalResponseTable = {}
	if response then
		local responseTable = json.decode(response)
		if responseTable and type(responseTable) == "table" then
			finalResponseTable = responseTable
		end
	end
	
	if finalResponseTable["finishedLoading"] then
		-- Make a lookup table by steamId
		local tmp = {}
		for badgeName, steamIds in pairs(finalResponseTable) do
			if type(steamIds) == "table" then
				for _, curSteamId in ipairs(steamIds) do
					if not tmp[curSteamId] then
						tmp[curSteamId] = {}
					end
					table.insert(tmp[curSteamId], badgeName)
				end
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
	
	-- Retry 5 times if it fails
	if #CHUDBadgesTable == 0 then
		if retries < 5 then
			retries = retries + 1
			processing = false
		else
			Shared.Message("[NS2+] Failed to retrieve NS2+ badges file. This isn't a critical error. Move along citizen.")
		end
	end
end

local localTesting = false
if Server then
	function LoadBadges()
		if processing == false then
			if localTesting then
				local openedFile = io.open("configs/badges.json", "r")
				if openedFile then
					local parsedFile = openedFile:read("*all")
					io.close(openedFile)
					
					if parsedFile then
						SaveBadgesJSON(parsedFile)
					end
				end
			else
				Shared.SendHTTPRequest(kCHUDBadges, "GET", SaveBadgesJSON)
				processing = true
			end
		end
	end
	
	local function SendBadges(client)
		for _, msg in ipairs(CHUDBadgesTable) do
			Server.SendNetworkMessage(client, "CHUDBadges", msg, true)
		end
	end
	
	Event.Hook("ClientConnect", SendBadges)
	Event.Hook("UpdateServer", LoadBadges)
end
