local serverConfigDefault = {
						settings =
							{
								rookie_friendly = true,
								force_even_teams_on_join = true,
								auto_team_balance = { enabled_on_unbalance_amount = 2, enabled_after_seconds = 10 },
								end_round_on_team_unbalance = 0.4,
								end_round_on_team_unbalance_check_after_time = 300,
								end_round_on_team_unbalance_after_warning_time = 30,
								auto_kick_afk_time = 300,
								auto_kick_afk_capacity = 0.5,
								voting = { votekickplayer = true, votechangemap = true, voteresetgame = true, voterandomizerr = true },
								reserved_slots = { amount = 0, ids = { } }
							},
						tags = { "rookie" }
					  }
					  
if Client then
	for k, v in pairs(serverConfigDefault["settings"]) do
		if type(v) == "boolean" then
			CHUDOptions[k] = {
				name = k,
				label = k,
				type = "select",
				values = { "false", "true" },
				category = "comp",
			}
		elseif type(v) == "number" then
			CHUDOptions[k] = {
				name = k,
				label = k,
				type = "number",
				category = "comp",
			}
		end
	end
end

if Server then
	function CHUDServerAdminPrint(client, message)

		if client then
		
			// First we must split up the message into a list of messages no bigger than kMaxPrintLength each.
			local messageList = { }
			while string.len(message) > kMaxPrintLength do
			
				local messagePart = string.sub(message, 0, kMaxPrintLength)
				table.insert(messageList, messagePart)
				message = string.sub(message, kMaxPrintLength + 1)
				
			end
			table.insert(messageList, message)
			
			for m = 1, #messageList do
				Server.SendNetworkMessage(client:GetControllingPlayer(), "CHUDServerConfig", { message = messageList[m] }, true)
			end
			
		end
	end
elseif Client then

    local function OnCHUDServerConfig(messageTable)
        Shared.Message(messageTable.message)
    end
    Client.HookNetworkMessage("CHUDServerConfig", OnCHUDServerConfig)
    
end

if Server then
// Fill the missing fields with default values so we can display them in the menu
function CHUDPopulateConfig(currentTable, defaultsTable)
	if type(defaultsTable) == "table" then
		for k, v in pairs(defaultsTable) do
			if currentTable[k] and type(v) == "table" then
				CHUDPopulateConfig(currentTable[k], v)
			elseif not currentTable[k] then
				currentTable[k] = v
			end
		end
	elseif not currentTable then
		currentTable = defaultsTable
	end
end

function CHUDGetServerSetting(client, setting)
	local kMaxPrintLength = 128
	local configFileName = "ServerConfig.json"

	WriteDefaultConfigFile(configFileName, defaultConfig)

	local config = LoadConfigFile(configFileName) or defaultConfig
	Print(json.encode(config))
	
	CHUDPopulateConfig(config, defaultConfig)
	
	Print(json.encode(config))
	
/*	local setting = Server.GetConfigSetting(setting)
    if not setting then
    
        Server.SetConfigSetting("reserved_slots", { amount = 0, ids = { } })
        setting = Server.GetConfigSetting("reserved_slots")
        
    end
    
    return setting*/

	/*if client then

		// First we must split up the message into a list of messages no bigger than kMaxPrintLength each.
		local messageList = { }
		while string.len(message) > kMaxPrintLength do
		
			local messagePart = string.sub(message, 0, kMaxPrintLength)
			table.insert(messageList, messagePart)
			message = string.sub(message, kMaxPrintLength)
			
		end
		table.insert(messageList, message)
		
		for m = 1, #messageList do
			Server.SendNetworkMessage(client:GetControllingPlayer(), "CHUDServerConfig", { message = messageList[m] }, true)
		end
		
	end*/
        
end

CreateServerAdminCommand("Console_sv_getsetting", CHUDGetServerSetting, "Retrieves server configuration", true)
end