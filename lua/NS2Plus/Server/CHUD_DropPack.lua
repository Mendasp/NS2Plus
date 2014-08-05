local commDrops = { "ammopack", "medpack", "catpack" }
local originalDropPackOnInit
originalDropPackOnInit = Class_ReplaceMethod( "DropPack", "OnInitialized",
	function(self)
	
		originalDropPackOnInit(self)
		
		local mapName = self:GetMapName()
		
		if table.contains(commDrops, mapName) then
			CHUDCommStats[CHUDMarineComm][mapName].misses = CHUDCommStats[CHUDMarineComm][mapName].misses + 1
		end
	
	end)

originalDropPackOnUpdate = Class_ReplaceMethod( "DropPack", "OnUpdate",
	function(self, deltaTime)
		-- GetEntitiesForTeamWithinXZRange ignores the Y axis
		local marinesNearby = GetEntitiesForTeamWithinXZRange("Marine", self:GetTeamNumber(), self:GetOrigin(), self.pickupRange)
		Shared.SortEntitiesByDistance(self:GetOrigin(), marinesNearby)

		local pickedUp = false
		for _, marine in ipairs(marinesNearby) do

			if self:GetIsValidRecipient(marine) then

				self:OnTouch(marine)
				DestroyEntity(self)
				pickedUp = true
				break

			end

		end

		if not pickedUp then
			originalDropPackOnUpdate(self, deltaTime)
		end
	end
)
