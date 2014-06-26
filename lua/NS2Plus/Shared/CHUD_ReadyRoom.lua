AppendToEnum( kTechId, "ReadyRoomEmbryo" )
AppendToEnum( kTechId, "ReadyRoomExo" )	

Script.Load( "lua/ReadyRoomExo.lua" )
Script.Load( "lua/ReadyRoomEmbryo.lua" )
Script.Load( "lua/Weapons/Alien/ReadyRoomLeap.lua" )
Script.Load( "lua/Weapons/Alien/ReadyRoomBlink.lua" )
	
	
local oldLookupTechId = LookupTechId
local oldLookupTechData = LookupTechData

local function AddNS2PlusTechChanges()
	kTechData[#kTechData+1] = 
	{
		[kTechDataId] = kTechId.ReadyRoomEmbryo,
		[kTechDataMapName] = ReadyRoomEmbryo.kMapName,
		[kTechDataDisplayName] = "READY_ROOM_EMBRYO",
		[kTechDataModel] = MarineVariantMixin.kModelNames["male"]["green"],
		[kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents)
	}
	
	kTechData[#kTechData+1] = 
	{
		[kTechDataId] = kTechId.ReadyRoomExo,
		[kTechDataMapName] = ReadyRoomExo.kMapName,
		[kTechDataDisplayName] = "READY_ROOM_EXO",
		[kTechDataMaxExtents] = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents),
	}
	
	LookupTechId = oldLookupTechId
	LookupTechData = oldLookupTechData
end

function LookupTechId(...)
	local techId = oldLookupTechId(...)
	AddNS2PlusTechChanges()
	return techId
end
function LookupTechData(...)
	local data = oldLookupTechData(...)
	AddNS2PlusTechChanges()
	return data
end


Class_ReplaceMethod( "Onos", "GetHasMovementSpecial", 
	function(self)
		return self:GetHasOneHive()
	end)


Class_ReplaceMethod( "Fade", "GetHasMovementSpecial", 
	function(self)
		return self:GetHasOneHive()
	end)


if Server then

	local parent,InitViewModel = LocateUpValue( Player.OnInitialized, "InitViewModel", {LocateRecurse = true } )

	function InitViewModelHook(self)
		InitViewModel(self)
		
		// Only give weapons when playing.
		if self:GetTeamNumber() ~= kNeutralTeamType and not self.preventWeapons then
			-- self:InitWeapons gets called here via Player.OnInitialized
		elseif self:GetTeamNumber() == kNeutralTeamType then
			self:InitWeaponsForReadyRoom()
		end
	end
	ReplaceUpValue( parent, "InitViewModel", InitViewModelHook )


	Class_AddMethod( "Player", "InitWeaponsForReadyRoom",
		function( self )		
		end)


	Class_ReplaceMethod( "Skulk", "InitWeaponsForReadyRoom",
		function( self )				
			Alien.InitWeapons(self)
			self:GiveItem(ReadyRoomLeap.kMapName)
			self:SetActiveWeapon(ReadyRoomLeap.kMapName)   
		end)
	

	Class_ReplaceMethod( "Fade", "InitWeaponsForReadyRoom",
		function( self )			
			Alien.InitWeapons(self)
			self:GiveItem(ReadyRoomBlink.kMapName)
			self:SetActiveWeapon(ReadyRoomBlink.kMapName)
		end)
	
	
	Class_ReplaceMethod( "ReadyRoomTeam", "GetRespawnMapName",
		function( self, player )
			
			local mapName = player.kMapName    
			
			if mapName == nil then
				mapName = ReadyRoomPlayer.kMapName
			end
			
			// Use previous life form if dead or in commander chair
			if (mapName == MarineCommander.kMapName) 
			   or (mapName == AlienCommander.kMapName) 
			   or (mapName == Spectator.kMapName) 
			   or (mapName == AlienSpectator.kMapName) 
			   or (mapName ==  MarineSpectator.kMapName) then 
			
				mapName = player:GetPreviousMapName()
				
			end
			
			// need to set embryos to ready room players, otherwise they wont be able to move
			if mapName == Embryo.kMapName then
				mapName = ReadyRoomEmbryo.kMapName
			elseif mapName == Exo.kMapName then
				mapName = ReadyRoomExo.kMapName
			end
			
			return mapName
			
		end)
	
	
	local oldOnJoinTeam
	oldOnJoinTeam = Class_ReplaceMethod( "Alien", "OnJoinTeam", 
		function( self )
			if self:GetTeamNumber() ~= kNeutralTeamType then
				oldOnJoinTeam( self )
			end
		end)
	
	
	Class_AddMethod( "Alien", "CopyPlayerDataForReadyRoomFrom",
		function( self, player )
			local respawnMapName = ReadyRoomTeam.GetRespawnMapName(nil,player)
			local gestationMapName = respawnMapName == ReadyRoomEmbryo.kMapName and player.gestationClass or nil
			
			local charge = 
				( respawnMapName == Onos.kMapName or gestationMapName == Onos.kMapName ) and 
				( player.oneHive or GetIsTechUnlocked( player, kTechId.Charge ) )
				
			local sstep = 
				( respawnMapName == Fade.kMapName or gestationMapName == Fade.kMapName ) and 
				( player.oneHive or GetIsTechUnlocked( player, kTechId.ShadowStep ) )
			
			local leap = 
				( respawnMapName == Skulk.kMapName or gestationMapName == Skulk.kMapName ) and 
				( player.twoHives or GetIsTechUnlocked( player, kTechId.Leap ) )
			
			self.oneHive = charge or sstep
			self.twoHives = leap
			self.gestationClass = gestationMapName	
		end)
	


	local oldAlienCopyPlayerDataFrom
	oldAlienCopyPlayerDataFrom = Class_ReplaceMethod( "Alien", "CopyPlayerDataFrom",
		function (self, player)
			if self:GetTeamNumber() == kNeutralTeamType and player:GetTeamNumber() ~= kNeutralTeamType then
				-- always copy when going from live alien to ready room
				Player.CopyPlayerDataFrom(self, player)
				Alien.CopyPlayerDataForReadyRoomFrom( self, player )
			--elseif self:GetTeamNumber() ~= kNeutralTeamType and player:GetTeamNumber() == kNeutralTeamType
			--	-- don't copy data from an Alien while entering the game
			--	Player.CopyPlayerDataFrom(self, player)
			elseif player:isa("AlienSpectator") then		
				-- don't copy data from an AlienSpectator to live alien if not going to the RR
				Player.CopyPlayerDataFrom(self, player)
			else
				-- live alien to live alien, use defaults
				oldAlienCopyPlayerDataFrom( self, player )
			end		
		end)


	Class_ReplaceMethod( "AlienSpectator", "CopyPlayerDataFrom",
		function (self, player)
			-- always copy when going from live alien to alien spectator
			Player.CopyPlayerDataFrom( self, player )
			Alien.CopyPlayerDataForReadyRoomFrom( self, player )
		end)
		
	
	local oldAlienReset
	oldAlienReset = Class_ReplaceMethod( "Alien", "Reset",
		function(self)
			if self:GetTeamNumber() == kNeutralTeamType then
				Player.Reset( self )	
			else
				oldAlienReset( self )
			end
		end)
	

end