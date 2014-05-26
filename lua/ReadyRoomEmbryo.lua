Script.Load("lua/ReadyRoomPlayer.lua")

class 'ReadyRoomEmbryo' (ReadyRoomPlayer)

ReadyRoomEmbryo.kMapName = "ready_room_embryo"

local networkVars = { }

if Server then
	function ReadyRoomEmbryo:CopyPlayerDataFrom( player )
		--ReadyRoomPlayer.CopyPlayerDataFrom( self, player )
		Alien.CopyPlayerDataFrom( self, player )
		self.gestationClass = player.gestationClass
	end

	function ReadyRoomEmbryo:PerformEject()
		if self:GetIsOnGround() and not self:GetIsOnEntity() then
			
			local newPlayer = self:Replace( self.gestationClass )
			newPlayer:SetCameraDistance(0)

			local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
			local newAlienExtents = LookupTechData(newPlayer:GetTechId(), kTechDataMaxExtents)

			if not GetHasRoomForCapsule(newAlienExtents, self:GetOrigin() + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterTwo(self, newPlayer)) then

				local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))

				if spawnPoint then
					newPlayer:SetOrigin(spawnPoint)
				end

			end

			newPlayer:DropToFloor()

			self:TriggerEffects("player_end_gestate")

			newPlayer:SetHatched()
			newPlayer:TriggerEffects("egg_death")

			return
		end
	end


	function ReadyRoomEmbryo:HandleButtons( input )
		ReadyRoomPlayer.HandleButtons( self, input )
		
		if bit.band(input.commands, Move.Drop) ~= 0 then
			self:PerformEject()
		end
	end
end


Shared.LinkClassToMap("ReadyRoomEmbryo", ReadyRoomEmbryo.kMapName, networkVars)