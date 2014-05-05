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

function PlayerUI_GetGameLengthTime()
	
    local state
    local entityList = Shared.GetEntitiesWithClassname("GameInfo")
    if entityList:GetSize() > 0 then
    
        local gameInfo = entityList:GetEntityAtIndex(0)
        
		state = gameInfo:GetState()
        		
        if state ~= kGameState.PreGame and
           state ~= kGameState.Countdown
		then
			if state ~= kGameState.Started then
				return gameInfo.prevTimeLength or 0, state
			else
				return math.max( 0, math.floor(Shared.GetTime()) - gameInfo:GetStartTime() ), state
			end
        end
        
    end
    
    return 0, state
    
end


local function UpdateTotalNumPlayers()
	local time = Shared.GetTime()
	if nextUpdateTotalNumPlayers < time then
		nextUpdateTotalNumPlayers = time + 3
		
		local addy = Client.GetOptionString(kLastServerConnected, "")
		
		local function OnServerRefreshed(serverData)
			local name = Client.GetConnectedServerName()
			if name ~= serverData.name then
				Shared.Message( "Mismatched server, connected player reporting may be incorrect" )
			end
			totalNumPlayers = serverData.numPlayers
		end
		Client.RefreshServer(addy, OnServerRefreshed)
	end
end


local lastIngameNumPlayers = 0
local totalNumPlayers = 0
local nextUpdateTotalNumPlayers = 0

local function OnServerRefreshed(serverData)
	local name = Client.GetConnectedServerName()
	if name ~= serverData.name then
		totalNumPlayers = 0
	else
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
	
	local time = Shared.GetTime()
	if nextUpdateTotalNumPlayers ~= -1 and nextUpdateTotalNumPlayers < time then
		
		local addy = Client.GetOptionString(kLastServerConnected, "")	
		Client.RefreshServer(addy, OnServerRefreshed)
		
		nextUpdateTotalNumPlayers = -1
		
	end
	
	return ingameNumPlayers, totalNumPlayers
    
end
