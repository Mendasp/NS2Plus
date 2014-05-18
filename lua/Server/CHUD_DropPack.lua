originalDropPackOnUpdate = Class_ReplaceMethod( "DropPack", "OnUpdate",
	function(self, deltaTime)
		if not CHUDServerOptions["droppacksignorey"].currentValue then
			originalDropPackOnUpdate(self, deltaTime)
			return
		end

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
