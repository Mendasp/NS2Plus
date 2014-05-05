Script.Load("lua/CHUD/Elixer_Utility.lua")

local kFindWeaponRange = 2
local kPickupWeaponTimeLimit = 1
Class_AddMethod( "Marine", "FindNearbyAutoPickupWeapon",
	function(self)
	
		local toPosition = self:GetOrigin()
		local nearbyWeapons = GetEntitiesWithMixinWithinRange("Pickupable", toPosition, kFindWeaponRange)
		local closestWeapon = nil
		local closestDistance = Math.infinity
		
		for i, nearbyWeapon in ipairs(nearbyWeapons) do
		
			local pickupSlot = nearbyWeapon:isa("Weapon") and nearbyWeapon:GetHUDSlot()
			local isEmptySlot = (self:GetWeaponInHUDSlot(pickupSlot) == nil) or (self:GetWeaponInHUDSlot(pickupSlot):isa("Axe"))
		
			if nearbyWeapon:isa("Weapon") and nearbyWeapon:GetIsValidRecipient(self) and isEmptySlot then
			
				local nearbyWeaponDistance = (nearbyWeapon:GetOrigin() - toPosition):GetLengthSquared()
				if nearbyWeaponDistance < closestDistance then
				
					closestWeapon = nearbyWeapon
					closestDistance = nearbyWeaponDistance
				
				end
				
			end
			
		end
		
		return closestWeapon
	
	end)
	
Class_AddMethod( "Marine", "SetCHUDAutopickup",
	function(self, autoPickup)
		if autoPickup ~= nil then
			self.autoPickup = autoPickup
		end
	end
)
local originalMarineOnInit
originalMarineOnInit = Class_ReplaceMethod( "Marine", "OnInitialized",
	function(self)
		originalMarineOnInit(self)
	
		self.autoPickup = true
	
		if Client then
			local message = { }
			message.autoPickup = CHUDGetOption("autopickup")
			Client.SendNetworkMessage("SetCHUDAutopickup", message)
		end
	end)

Class_ReplaceMethod( "Marine", "HandleButtons", 
	function(self, input)
		
    PROFILE("Marine:HandleButtons")
    
    Player.HandleButtons(self, input)
    
    if self:GetCanControl() then
    
        // Update sprinting state
        self:UpdateSprintingState(input)
        
        local flashlightPressed = bit.band(input.commands, Move.ToggleFlashlight) ~= 0
        if not self.flashlightLastFrame and flashlightPressed then
        
            self:SetFlashlightOn(not self:GetFlashlightOn())
            StartSoundEffectOnEntity(Marine.kFlashlightSoundName, self, 1, self)
            
        end
        self.flashlightLastFrame = flashlightPressed

		local pickupSlot = self:FindNearbyAutoPickupWeapon() and self:FindNearbyAutoPickupWeapon():GetHUDSlot()
		local isEmptySlot = (self:GetWeaponInHUDSlot(pickupSlot) == nil) or (self:GetWeaponInHUDSlot(pickupSlot):isa("Axe"))
		local autoPickup = self:FindNearbyAutoPickupWeapon() and isEmptySlot and bit.band(input.commands, Move.Drop) == 0 and self.autoPickup
        if (bit.band(input.commands, Move.Drop) ~= 0 or autoPickup) and not self:GetIsVortexed() then
        
            if Server then
            
                // First check for a nearby weapon to pickup.
                local nearbyDroppedWeapon = ConditionalValue(autoPickup, self:FindNearbyAutoPickupWeapon(), self:GetNearbyPickupableWeapon())

                if nearbyDroppedWeapon then

					local lastActiveHUD = self:GetActiveWeapon():GetHUDSlot()
                
                    if Shared.GetTime() > self.timeOfLastPickUpWeapon + kPickupWeaponTimeLimit then
                    
                        if nearbyDroppedWeapon.GetReplacementWeaponMapName then
                        
                            local replacement = nearbyDroppedWeapon:GetReplacementWeaponMapName()
                            local toReplace = self:GetWeapon(replacement)
                            if toReplace then
                            
                                self:RemoveWeapon(toReplace)
                                DestroyEntity(toReplace)
                                
                            end
                            
                        end
                        
						local active = not self.autoPickup or nearbyDroppedWeapon:GetHUDSlot() == 1
                        self:AddWeapon(nearbyDroppedWeapon, active)
                        StartSoundEffectAtOrigin(Marine.kGunPickupSound, self:GetOrigin())
						
						// Fixes problem where if a marine drops all weapons and picks a welder the axe remains active
						if not active then
							self:SetHUDSlotActive(lastActiveHUD)
						end
                        
						// Don't add the pickup delay to autopickedup weapons
						if not autoPickup then
							self.timeOfLastPickUpWeapon = Shared.GetTime()
						end
                        
                    end
                    
                else
                
                    // No nearby weapon, drop our current weapon.
                    self:Drop()
					
					self.timeOfLastPickUpWeapon = Shared.GetTime()
                    
                end
                
            end
            
        end
        
    end
end)

if Server then
	local function OnSetCHUDAutopickup(client, message)

		if client then
		
			local player = client:GetControllingPlayer()
			if player and player:isa("Marine") then
				player:SetCHUDAutopickup(message.autoPickup)
			end
			
		end
		
	end

	Server.HookNetworkMessage("SetCHUDAutopickup", OnSetCHUDAutopickup)
	
	local originalWeaponDropped
	originalWeaponDropped = Class_ReplaceMethod( "Weapon", "Dropped",
		function(self, prevOwner)
			local slot = self:GetHUDSlot()

			originalWeaponDropped(self, prevOwner)
			
			if self.physicsModel then
				local viewCoords = prevOwner:GetViewCoords()
				local impulse = 0.075
				if slot == 2 then
					impulse = 0.0075
				elseif slot == 3 then
					impulse = 0.005
				end
				self.physicsModel:AddImpulse(self:GetOrigin(), (viewCoords.zAxis * impulse))
			end
		end)
end