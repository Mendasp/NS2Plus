originalBlur = Class_ReplaceMethod( "Player", "SetBlurEnabled",
	function(self, blurEnabled)
		if not CHUDGetOption("blur") then
			Player.screenEffects.blur:SetActive(false)
		else
			originalBlur(self, blurEnabled)
		end
	end
)

originalUpdateScreenEff = Class_ReplaceMethod( "Player", "UpdateScreenEffects",
	function(self, deltaTime)
		originalUpdateScreenEff(self, deltaTime)
		//if not Client.GetOptionBoolean("CHUD_LowHealthEff", true) then
			Player.screenEffects.lowHealth:SetActive(false)
		//end
	end
)

// Disables low health effects
function UpdateDSPEffects()
	// We're not doing anything in this function
    // but leave this for future generations to wonder why this was an option in the first place

    // Most ancient piece of code in this mod - Archaeologists pls be careful, this code has a curse
	/*if Client.GetOptionBoolean("CHUD_LowHealthEff", true) then
		originalDSPEff()
	end*/
end

local lastIngameNumPlayers = 0
local totalNumPlayers = 0
local nextUpdateTotalNumPlayers = 0

local function OnServerRefreshed(serverData)
	local name = Client.GetConnectedServerName()
	if name == serverData.name then
		totalNumPlayers = serverData.numPlayers
	end			
	nextUpdateTotalNumPlayers = Shared.GetTime() + 3
end

function PlayerUI_GetServerNumPlayers()
	
	local ingameNumPlayers = #Scoreboard_GetPlayerList()
	if ingameNumPlayers < lastIngameNumPlayers then
		totalNumPlayers = math.max( ingameNumPlayers, totalNumPlayers - ( lastIngameNumPlayers - ingameNumPlayers ) )
	end
	lastIngameNumPlayers = ingameNumPlayers	
	
	if nextUpdateTotalNumPlayers ~= -1 and nextUpdateTotalNumPlayers < Shared.GetTime() then	
		local addy = Client.GetOptionString(kLastServerConnected, "")	
		if Client.GetOptionBoolean("CHUDScoreboardConnecting", true) then
			Client.RefreshServer(addy, OnServerRefreshed)
		end
		
		nextUpdateTotalNumPlayers = -1		
	end
	
	return ingameNumPlayers, totalNumPlayers
    
end

local lastChatCommand = Shared.GetTime()
local chatInterval = 15

local function ClientSay(...)

	local args = {...}
	local message = ""
	
	for _, word in ipairs(args) do
		if message == "" then
			message = word
		else
			message = message .. " " .. word
		end
	end
	
	if message ~= nil and string.len(message) > 0 and Shared.GetTime() > lastChatCommand + chatInterval then

		lastChatCommand = Shared.GetTime()
		message = string.sub(message, 1, kMaxChatLength)
		Client.SendNetworkMessage("ChatClient", BuildChatClientMessage(false, message), true)
		
	end

end

local function ClientTeamSay(...)
	local args = {...}
	local message = ""
	
	for _, word in ipairs(args) do
		if message == "" then
			message = word
		else
			message = message .. " " .. word
		end
	end
	
	if message ~= nil and string.len(message) > 0 and Shared.GetTime() > lastChatCommand + chatInterval then

		lastChatCommand = Shared.GetTime()
		message = string.sub(message, 1, kMaxChatLength)
		Client.SendNetworkMessage("ChatClient", BuildChatClientMessage(true, message), true)
		
	end
end

local originalPlayerOnInit
originalPlayerOnInit = Class_ReplaceMethod("Player", "OnInitialized",
	function(self)
		originalPlayerOnInit(self)
		
		local message = { }
		message.overkill = CHUDGetOption("overkilldamagenumbers")
		Client.SendNetworkMessage("SetCHUDOverkill", message)
	end)

// Bandaid fix for players crashing when they run Client.RefreshServer
local function OnCommandNS2PDC()
	if Client.GetOptionBoolean("CHUDScoreboardConnecting", true) then
		Client.SetOptionBoolean("CHUDScoreboardConnecting", false)
		Shared.Message("Players connecting in scoreboard ENABLED")
	else
		Client.SetOptionBoolean("CHUDScoreboardConnecting", true)
		Shared.Message("Players connecting in scoreboard DISABLED")
	end
end
Event.Hook("Console_ns2pdc", OnCommandNS2PDC)

Event.Hook("Console_say", ClientSay)
Event.Hook("Console_team_say", ClientTeamSay)