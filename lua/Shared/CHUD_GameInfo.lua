
local gameInfoNetworkVars =
{
	numPlayers = "integer",
}

if Server then
	local oldGameInfoOnCreate
	oldGameInfoOnCreate = Class_ReplaceMethod( "GameInfo", "OnCreate",
		function( self )
			oldGameInfoOnCreate( self )
		
			self.numPlayers = 0
		end)
end

Class_Reload( "GameInfo", gameInfoNetworkVars )