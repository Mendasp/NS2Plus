

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