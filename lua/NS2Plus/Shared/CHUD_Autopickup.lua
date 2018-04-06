function Marine:ShouldAutopickupWeapons()
	return self.autoPickup 
end

function Marine:ShouldAutopickupBetterWeapons()
	return self.autoPickupBetter
end

Class_AddMethod( "Marine", "SetCHUDAutopickup",
	function(self, message)
		if message ~= nil then
			if message.autoPickup ~= nil then
				self.autoPickup = message.autoPickup
			end
			if message.autoPickupBetter ~= nil then
				self.autoPickupBetter = message.autoPickupBetter
			end
		end
	end
)

local originalMarineOnInit
originalMarineOnInit = Class_ReplaceMethod( "Marine", "OnInitialized",
	function(self)
		originalMarineOnInit(self)
		
		if Client then
			self.autoPickup = CHUDGetOption("autopickup")
			self.autoPickupBetter = CHUDGetOption("autopickupbetter")
			local message = 
			{
				autoPickup = self.autoPickup,
				autoPickupBetter = self.autoPickupBetter
			}
			Client.SendNetworkMessage("SetCHUDAutopickup", message)
		elseif Server then
			self.autoPickup = true
			self.autoPickupBetter = false
		end
	end)


if Server then
	local function OnSetCHUDAutopickup(client, message)

		if client then
		
			local player = client:GetControllingPlayer()
			if player and player:isa("Marine") then
				if message ~= nil then
					player:SetCHUDAutopickup(message)
				end
			end
			
		end
		
	end

	Server.HookNetworkMessage("SetCHUDAutopickup", OnSetCHUDAutopickup)

end
