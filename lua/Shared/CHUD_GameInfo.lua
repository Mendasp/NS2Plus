local gameInfoNetworkVars =
{
	numPlayers = "integer",
}

if Server then
	local numPlayersCount = 0
	
	local function UpdateGameInfoWithNumPlayers()
		
		local entityList = Shared.GetEntitiesWithClassname("GameInfo")
		if entityList:GetSize() > 0 then
		
			local gameInfo = entityList:GetEntityAtIndex(0)
			gameInfo.numPlayers = numPlayersCount
			
		end
	end
	
	local function IncPlayerCount()
		numPlayersCount = numPlayersCount + 1
		UpdateGameInfoWithNumPlayers()
		Shared.Message( "[NUMPLAYERSCOUNT] ".. numPlayersCount )
	end
	
	local function DecPlayerCount()
		numPlayersCount = numPlayersCount - 1
		UpdateGameInfoWithNumPlayers()
		Shared.Message( "[NUMPLAYERSCOUNT] ".. numPlayersCount )
	end
	
	Event.Hook( "ClientConnect", IncPlayerCount )
	Event.Hook( "ClientDisconnect", DecPlayerCount )
	
end

Class_Reload( "GameInfo", gameInfoNetworkVars )
