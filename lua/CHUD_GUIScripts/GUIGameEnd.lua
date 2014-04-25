function PlayerUI_GetGameLengthTime()
	
    local entityList = Shared.GetEntitiesWithClassname("GameInfo")
    if entityList:GetSize() > 0 then
    
        local gameInfo = entityList:GetEntityAtIndex(0)
        local state = gameInfo:GetState()
        
        if state ~= kGameState.Started then
			
			return gameInfo.prevTimeLength or 0
		
		else
		
            return math.floor(Shared.GetTime()) - gameInfo:GetStartTime()
			
        end
        
    end
    
    return 0
    
end


local oldSetGameEnded
oldSetGameEnded = Class_ReplaceMethod( "GUIGameEnd", "SetGameEnded", 
	function( self, playerWon, playerIsMarine )
			
		local entityList = Shared.GetEntitiesWithClassname("GameInfo")
		if entityList:GetSize() > 0 then
			local gameInfo = entityList:GetEntityAtIndex(0)		
			gameInfo.prevTimeLength = math.floor(Shared.GetTime()) - gameInfo:GetStartTime();
		end
	
		oldSetGameEnded( self, playerWon, playerIsMarine )
	
	end
)