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


function PlayerUI_GetServerNumPlayers()
	
    local entityList = Shared.GetEntitiesWithClassname("GameInfo")
    if entityList:GetSize() > 0 then    
        local gameInfo = entityList:GetEntityAtIndex(0)
        return gameInfo.numPlayers or 0
	end
    
end
