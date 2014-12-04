//=============================================================================
//
// lua/Chat.lua
// 
// Created by Max McGuire (max@unknownworlds.com)
// Copyright 2011, Unknown Worlds Entertainment
//
//=============================================================================

// color, playername, color, message
local chatMessages = { }
local enteringChatMessage = false
local startedChatTime = 0
local teamOnlyChat = false
// Note: Nothing clears this out but it is probably safe to assume the player won't
// mute enough clients to run out of memory.
local mutedClients = { }
local mutedTextClients = { }

/**
 * Returns true if the passed in client is currently speaking.
 */
function ChatUI_GetIsClientSpeaking(clientIndex)

    // Handle the local client specially.
    if Client.GetLocalClientIndex() == clientIndex then
        return Client.IsVoiceRecordingActive()
    end
    
    return Client.GetIsClientSpeaking(clientIndex)
    
end

function ChatUI_SetClientMuted(muteClientIndex, setMute)

    // Player cannot mute themselves.
    local localPlayer = Client.GetLocalPlayer()
    if localPlayer and localPlayer:GetClientIndex() == muteClientIndex and not localPlayer:GetTeamNumber() == kSpectatorIndex then
        return
    end
    
    local message = BuildMutePlayerMessage(muteClientIndex, setMute)
    Client.SendNetworkMessage("MutePlayer", message, true)
    mutedClients[muteClientIndex] = setMute

end

function ChatUI_GetClientMuted(clientIndex)
    return mutedClients[clientIndex] == true
end

function ChatUI_SetSteamIdTextMuted(steamId, setTextMute)
    // Player cannot mute themselves.
    local localPlayer = Client.GetSteamId()
    if localPlayer == steamId then
        return
    end
    
    mutedTextClients[steamId] = setTextMute

end

function ChatUI_GetSteamIdTextMuted(steamId)
    return mutedTextClients[steamId] == true
end

function ChatUI_GetMessages()

    local uiChatMessages = { }
    
    if table.maxn(chatMessages) > 0 then
    
        table.copy(chatMessages, uiChatMessages)
        chatMessages = { }
        
    end
    
    return uiChatMessages
    
end

// Return true if we want the UI to take key input for chat
function ChatUI_EnteringChatMessage()

    if MainMenu_GetIsOpened() then
        return false
    else 
        return enteringChatMessage
    end
    
end

function ChatUI_GetStartedChatTime()
    return startedChatTime
end

// Return string prefix to display in front of the chat input
function ChatUI_GetChatMessageType()

    if teamOnlyChat then
        return "Team: "
    end
    
    return "All: "
    
end

/**
 * Called when player hits return after entering a chat message. Send it to the server.
 */
function ChatUI_SubmitChatMessageBody(chatMessage)

    // Quote string so spacing doesn't come through as multiple arguments
    if chatMessage ~= nil and string.len(chatMessage) > 0 then
    
        chatMessage = string.UTF8Sub(chatMessage, 1, kMaxChatLength)
        Client.SendNetworkMessage("ChatClient", BuildChatClientMessage(teamOnlyChat, chatMessage), true)
        
        teamOnlyChat = false
        
    end
    
    enteringChatMessage = false
    
    SetMoveInputBlocked(false)
    
end

/** 
 * Client should call this when player hits key to enter a chat message.
 */
function ChatUI_EnterChatMessage(teamOnly)

    if not enteringChatMessage then
    
        enteringChatMessage = true
        startedChatTime = Shared.GetTime()
        teamOnlyChat = teamOnly
        
        SetMoveInputBlocked(true)
        
    end
    
end

/**
 * This function is called when the client receives a chat message.
 */
local function OnMessageChat(message)

    local player = Client.GetLocalPlayer()
    
    if player then
    
        // color, playername, color, message

        local isCommander = false
        local drawRookie = false
        local steamId = 0
        
        local playerData = ScoreboardUI_GetAllScores()
        
        for _, playerRecord in ipairs(playerData) do

            if playerRecord.Name == message.playerName then
                isCommander = playerRecord.IsCommander
                drawRookie = playerRecord.IsRookie and ((player:GetTeamNumber() == playerRecord.EntityTeamNumber) or (player:GetTeamNumber() == kSpectatorIndex))
                steamId = GetSteamIdForClientIndex(playerRecord.ClientIndex)
                break
            end
            
        end  
        
        local rookieText = ""
        if isCommander then
            table.insert(chatMessages, kCommanderColor)
        elseif drawRookie then
            table.insert(chatMessages, kNewPlayerColor)
            rookieText = " " .. Locale.ResolveString("ROOKIE_CHAT")
        else
            table.insert(chatMessages, GetColorForTeamNumber(message.teamNumber))
        end
        
        // Tack on location name if any
        local locationNameText = ""
        
        // Lookup location name from passed in id
        local locationName = ""
        if message.locationId > 0 then
            locationNameText = string.format("(Team, %s) ", Shared.GetString(message.locationId))
        else
            locationNameText = "(Team) "
        end
        
        // Pre-pend "team" or "all"
        local preMessageString = string.format("%s%s%s: ", message.teamOnly and locationNameText or "(All) ", message.playerName, rookieText, locationNameText)
        
        table.insert(chatMessages, preMessageString)
        
        if isCommander then
            table.insert(chatMessages, kCommanderColorFloat)
        elseif drawRookie then
            table.insert(chatMessages, kNewPlayerColorFloat)
        else
            table.insert(chatMessages, kChatTextColor[message.teamType])
        end
        
        table.insert(chatMessages, message.message)
        
        // Player steamId (for muting text)
        table.insert(chatMessages, steamId)
        // texture x
        table.insert(chatMessages, 0)
        // texture y
        table.insert(chatMessages, 0)
        // entity id
        table.insert(chatMessages, 0)
        
        StartSoundEffect(player:GetChatSound())
        
        // Only print to log if the client isn't running a local server
        // which has already printed to log.
        if not Client.GetIsRunningServer() then
        
            local prefixText = "Chat All"
            if message.teamOnly then
                prefixText = "Chat Team " .. message.teamNumber
            end
            
            Shared.Message(prefixText .. " - " .. message.playerName .. ": " .. message.message)
            
        end
        
    end
    
end

local kSystemMessageHexColor = 0xFFD800
local kSystemMessageColor = Color(1.0, 0.8, 0.0, 1)

// Let other modules add messages to the chat system - useful for system messages
function ChatUI_AddSystemMessage(msgText)

    local player = Client.GetLocalPlayer()    
    
    if player then
    
        table.insert(chatMessages, kSystemMessageHexColor)
        table.insert(chatMessages, "")
        
        table.insert(chatMessages, kSystemMessageColor)
        table.insert(chatMessages, msgText)

         // reserved for possible texture name
        table.insert(chatMessages, "")
        // texture x
        table.insert(chatMessages, 0)
        // texture y
        table.insert(chatMessages, 0)
        // entity id
        table.insert(chatMessages, 0)

        StartSoundEffect(player:GetChatSound())
        
    end
    
end

Client.HookNetworkMessage("Chat", OnMessageChat)
