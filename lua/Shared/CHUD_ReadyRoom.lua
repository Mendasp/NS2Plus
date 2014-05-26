AppendToEnum( kTechId, "ReadyRoomEmbryo" )
AppendToEnum( kTechId, "ReadyRoomExo" )	

Script.Load( "lua/ReadyRoomExo.lua" )
Script.Load( "lua/ReadyRoomEmbryo.lua" )
Script.Load( "lua/Weapons/Alien/ReadyRoomLeap.lua" )
Script.Load( "lua/Weapons/Alien/ReadyRoomBlink.lua" )
	
	
local oldBuildTechData = BuildTechData
function BuildTechData() 
	local techData = oldBuildTechData()
	
	techData[#techData + 1] = 
	{
		[kTechDataId] = kTechId.ReadyRoomEmbryo,
		[kTechDataMapName] = ReadyRoomEmbryo.kMapName,
		[kTechDataDisplayName] = "READY_ROOM_EMBRYO",
		[kTechDataModel] = Embryo.kModelName,
		[kTechDataMaxExtents] = Vector(Embryo.kXExtents, Embryo.kYExtents, Embryo.kZExtents)
	}
	
	techData[#techData + 1] = 
	{
		[kTechDataId] = kTechId.ReadyRoomExo,
		[kTechDataMapName] = ReadyRoomExo.kMapName,
		[kTechDataDisplayName] = "READY_ROOM_EXO",
		[kTechDataMaxExtents] = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents),
	}
	
	return techData
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
	
	
	local oldGetRespawnMapName
	oldGetRespawnMapName = Class_ReplaceMethod( "ReadyRoomTeam", "GetRespawnMapName",
		function( self, player )
			local mapName = player.kMapName 
			if mapName == Embryo.kMapName then
				return ReadyRoomEmbryo.kMapName
			elseif mapName == Exo.kMapName then
				return ReadyRoomExo.kMapName
			else
				return oldGetRespawnMapName( self, player )
			end
		end)
	
	
	local function CopyPlayerDataForReadyRoom( self, player )
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
	end
	
	
	local oldOnJoinTeam
	oldOnJoinTeam = Class_ReplaceMethod( "Alien", "OnJoinTeam", 
		function( self )
			if self:GetTeamNumber() ~= kNeutralTeamType then
				oldOnJoinTeam( self )
			end
		end)


	local oldAlienCopyPlayerDataFrom
	oldAlienCopyPlayerDataFrom = Class_ReplaceMethod( "Alien", "CopyPlayerDataFrom",
		function (self, player)
			if self:GetTeamNumber() == kNeutralTeamType then
				-- always copy when going from live alien to ready room
				Player.CopyPlayerDataFrom(self, player)
				CopyPlayerDataForReadyRoom( self, player )
			elseif player:isa("AlienSpectator") then		
				-- don't copy data from an AlienSpectator to live alien if not going to the RR
				Player.CopyPlayerDataFrom(self, player)
			else
				oldAlienCopyPlayerDataFrom( self, player )
			end		
		end)


	local oldAlienSpectatorCopyPlayerDataFrom
	oldAlienSpectatorCopyPlayerDataFrom = Class_ReplaceMethod( "AlienSpectator", "CopyPlayerDataFrom",
		function (self, player)
			oldAlienSpectatorCopyPlayerDataFrom( self, player )
			-- always copy when going from live alien to alien spectator
			CopyPlayerDataForReadyRoom( self, player )
		end)

end