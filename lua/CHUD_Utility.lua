if Server then
	function SendCHUDMessage(message)

		if message then
		
			Server.SendNetworkMessage("Chat", BuildChatMessage(false, "NS2+", -1, kTeamReadyRoom, kNeutralTeamType, message), true)
			Shared.Message("Chat All - NS2+: " .. message)
			Server.AddChatToHistory(message, "NS2+", 0, kTeamReadyRoom, false)
			
		end
		
	end

	local kMaxPrintLength = 128
	// Messages were cut off by 1 character when over kMaxPrintLength
    function ServerAdminPrint(client, message)
    
        if client then
        
            // First we must split up the message into a list of messages no bigger than kMaxPrintLength each.
            local messageList = { }
            while string.len(message) > kMaxPrintLength do
            
                local messagePart = string.sub(message, 0, kMaxPrintLength)
                table.insert(messageList, messagePart)
				// Right here, this mofo
				// Fixed and stuff
                message = string.sub(message, kMaxPrintLength)
                
            end
            table.insert(messageList, message)
            
            for m = 1, #messageList do
                Server.SendNetworkMessage(client:GetControllingPlayer(), "ServerAdminPrint", { message = messageList[m] }, true)
            end
            
        end
        
        // Display message in the server console.
        Shared.Message(message)
        
    end
	
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