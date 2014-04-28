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


local oldSetGameEnded
oldSetGameEnded = Class_ReplaceMethod( "GUIGameEnd", "SetGameEnded", 
	function( self, playerWon, playerIsMarine )
			
		local entityList = Shared.GetEntitiesWithClassname("GameInfo")
		if entityList:GetSize() > 0 then
			local gameInfo = entityList:GetEntityAtIndex(0)		
			gameInfo.prevTimeLength = math.max( 0, math.floor(Shared.GetTime()) - gameInfo:GetStartTime() )
		end
	
		oldSetGameEnded( self, playerWon, playerIsMarine )
	
	end
)