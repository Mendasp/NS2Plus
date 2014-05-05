local oldNS2GamerulesOnUpdate
oldNS2GamerulesOnUpdate = Class_ReplaceMethod( "NS2Gamerules", "OnUpdate",
	function( self, timePassed )
		oldNS2GamerulesOnUpdate( self, timePassed )
					
		self.gameInfo.numPlayers = Server.GetNumPlayers()
end)
	
	