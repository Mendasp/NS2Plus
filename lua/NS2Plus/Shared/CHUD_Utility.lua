function CHUDWrapTextIntoTable( str, limit, indent, indent1 )

	limit = limit or 72
	indent = indent or ""
	indent1 = indent1 or indent
	
	local here = 1 - #indent1
	str = indent1..str:gsub( "(%s+)()(%S+)()",
		function( sp, st, word, fi )
			if fi-here > limit then
				here = st - #indent
				//Print(indent..word)
				return "\n"..indent..word
			end
		end )
	
	return StringSplit(str, "\n")
end

if Server then
	function SendCHUDMessage(message)
		
		if message then
		
			local messageList = CHUDWrapTextIntoTable(message, kMaxChatLength)
			
			for m = 1, #messageList do
				Server.SendNetworkMessage("Chat", BuildChatMessage(false, "NS2+", -1, kTeamReadyRoom, kNeutralTeamType, messageList[m]), true)
				Shared.Message("Chat All - NS2+: " .. messageList[m])
				Server.AddChatToHistory(messageList[m], "NS2+", 0, kTeamReadyRoom, false)
			end
						
		end
		
	end

	function CHUDServerAdminPrint(client, message)
		local kMaxPrintLength = 128
		
		if client then
		
			// First we must split up the message into a list of messages no bigger than kMaxPrintLength each.
			local messageList = CHUDWrapTextIntoTable(message, kMaxPrintLength)
			
			for m = 1, #messageList do
				Server.SendNetworkMessage(client:GetControllingPlayer(), "ServerAdminPrint", { message = messageList[m] }, true)
			end
			
		end
		
	end
	
	function GetCHUDTagBitmask()
		
		local tags = { }
		Server.GetTags(tags)
			
		for t = 1, #tags do
			local _, pos = string.find(tags[t], "CHUD_0x")
			if pos then
				return(tonumber(string.sub(tags[t], pos+1)))
			end
		end
		
	end
	
	function SetCHUDTagBitmask(bitmask)
		
		local tags = { }
		Server.GetTags(tags)
		
		for t = 1, #tags do
			if string.find(tags[t], "CHUD_0x") then
				Server.RemoveTag(tags[t])
			end
		end
		
		Server.AddTag("CHUD_0x" .. bitmask)
		
	end
	
	function AddCHUDTagBitmask(mask)
		local bitmask = GetCHUDTagBitmask() or 0
		bitmask = bit.bor(bitmask, mask)
		SetCHUDTagBitmask(bitmask)
	end
	
	function SubstractCHUDTagBitmask(mask)
		local bitmask = GetCHUDTagBitmask() or 0
		bitmask = bit.band(bitmask, bit.bnot(mask))
		SetCHUDTagBitmask(bitmask)
	end
	
end

function CheckCHUDTagOption(bitmask, option)
	return(bit.band(bitmask, option) > 0)
end

// Obviously from Shine
local Gamemode
function ShineGetGamemode()
	if Gamemode then return Gamemode end

	local GameSetup = io.open( "game_setup.xml", "r" )

	if not GameSetup then
		Gamemode = "ns2"

		return "ns2"
	end

	local Data = GameSetup:read( "*all" )

	GameSetup:close()

	local Match = Data:match( "<name>(.+)</name>" )

	Gamemode = Match or "ns2"

	return Gamemode
end

// Reminder to fix all the stupid time rounding stuff
local function FormatTime(time)

    local t = math.round(time)
    local h = math.floor(t / 3600)
    local m = math.floor((t / 60) % 60)
    local s = math.floor(t % 60)
    return string.format("%d:%.2d:%.2d", h,  m, s)
    
end

function CHUDGetGameTime()
	
	local gameTime, state = PlayerUI_GetGameLengthTime()
	if state == kGameState.NotStarted then
		gameTime = 0
	end
				
	local minutes = math.floor(gameTime / 60)
	local seconds = math.floor(gameTime % 60)
							
	return(string.format("%d:%.2d", minutes, seconds))
	
end

if Client then
	function CHUDEvaluateGUIVis()
		local player = Client.GetLocalPlayer()
		local teamNumber = player:GetTeamNumber()
		
		local classicammo = false
		local customhud = false
		
		local classicammoScript = "NS2Plus/Client/CHUDGUI_ClassicAmmo"
		local customhudScript = "NS2Plus/Client/CHUDGUI_CustomHUD"
		if teamNumber == kTeam1Index then
			if CHUDGetOption("classicammo") then
				GetGUIManager():CreateGUIScriptSingle(classicammoScript)
				classicammo = true
			end
			
			if CHUDGetOption("customhud_m") > 0 then
				GetGUIManager():CreateGUIScriptSingle(customhudScript)
				customhud = true
			end
		elseif teamNumber == kTeam2Index then
			if CHUDGetOption("customhud_a") > 0 then
				GetGUIManager():CreateGUIScriptSingle(customhudScript)
				customhud = true
			end
		end
		
		if GetGUIManager():GetGUIScriptSingle(classicammoScript) and not classicammo then
			GetGUIManager():DestroyGUIScriptSingle(classicammoScript)
		end
		if GetGUIManager():GetGUIScriptSingle(customhudScript) and not customhud then
			GetGUIManager():DestroyGUIScriptSingle(customhudScript)
		end
	end
end