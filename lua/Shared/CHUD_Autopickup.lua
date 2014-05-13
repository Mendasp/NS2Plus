Script.Load("lua/CHUD/Elixer_Utility.lua")

local kFindWeaponRange = 2
local kPickupWeaponTimeLimit = 1
Class_AddMethod( "Marine", "FindNearbyAutoPickupWeapon",
	function(self)
	
		local toPosition = self:GetOrigin()
		local nearbyWeapons = GetEntitiesWithMixinWithinRange("Pickupable", toPosition, kFindWeaponRange)
		local closestWeapon = nil
		local closestDistance = Math.infinity
		
		local pickupPriority = { [kTechId.Flamethrower] = 1, [kTechId.GrenadeLauncher] = 2, [kTechId.Shotgun] = 3 }
		
		local currentWeapon = self:GetWeaponInHUDSlot(1)
		local bestPriority = currentWeapon and ( pickupPriority[currentWeapon:GetTechId()] or 0 ) or -1
		
		for i, nearbyWeapon in ipairs(nearbyWeapons) do
		
			local pickupSlot = nearbyWeapon:isa("Weapon") and nearbyWeapon:GetHUDSlot()
			local isEmptySlot = (self:GetWeaponInHUDSlot(pickupSlot) == nil) or (self:GetWeaponInHUDSlot(pickupSlot):isa("Axe"))
		
			if nearbyWeapon:isa("Weapon") and nearbyWeapon:GetIsValidRecipient(self) and isEmptySlot and self.autoPickup then
			
				local nearbyWeaponDistance = (nearbyWeapon:GetOrigin() - toPosition):GetLengthSquared()
				if nearbyWeaponDistance < closestDistance then
				
					closestWeapon = nearbyWeapon
					closestDistance = nearbyWeaponDistance
				
				end
				
			elseif nearbyWeapon:isa("Weapon") and nearbyWeapon:GetIsValidRecipient(self) and pickupSlot == 1 and self.autoPickupBetter then

				local techId = nearbyWeapon:GetTechId()
				local curPriority = pickupPriority[techId] or 0

				if curPriority > bestPriority then
					bestPriority = curPriority
					closestWeapon = nearbyWeapon
				end
			end
			
		end
		
		return closestWeapon
	
	end)
	
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
	
		self.autoPickup = true
		self.autoPickupBetter = false
	
		if Client then
			local message = { }
			message.autoPickup = CHUDGetOption("autopickup")
			message.autoPickupBetter = CHUDGetOption("autopickupbetter")
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

		local autoPickup = self:FindNearbyAutoPickupWeapon() and bit.band(input.commands, Move.Drop) == 0
        if (bit.band(input.commands, Move.Drop) ~= 0 or autoPickup) and not self:GetIsVortexed() then
        
            if Server then
            
                // First check for a nearby weapon to pickup.
                local nearbyDroppedWeapon = ConditionalValue(autoPickup, self:FindNearbyAutoPickupWeapon(), self:GetNearbyPickupableWeapon())

                if nearbyDroppedWeapon then

					local lastActiveHUD = self:GetActiveWeapon():GetHUDSlot()
                
                    if self.lastDroppedWeapon ~= nearbyDroppedWeapon or Shared.GetTime() > self.timeOfLastPickUpWeapon + kPickupWeaponTimeLimit then
                    
                        if nearbyDroppedWeapon.GetReplacementWeaponMapName then
                        
                            local replacement = nearbyDroppedWeapon:GetReplacementWeaponMapName()
                            local toReplace = self:GetWeapon(replacement)
                            if toReplace then
                            
                                self:RemoveWeapon(toReplace)
                                DestroyEntity(toReplace)
                                
                            end
                            
                        end
                        
						local active = not self.autoPickup or nearbyDroppedWeapon:GetHUDSlot() == 1 or bit.band(input.commands, Move.Drop) ~= 0
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
                
					local activeWeapon = self:GetActiveWeapon()
					
					// No nearby weapon, drop our current weapon.
                    if self:Drop() then						
						self.lastDroppedWeapon = activeWeapon                    
						self.timeOfLastPickUpWeapon = Shared.GetTime()
					end
					
					
                    
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
				if message ~= nil then
					player:SetCHUDAutopickup(message)
				end
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
		
	local originalClipWeaponDropped
	originalClipWeaponDropped = Class_ReplaceMethod( "ClipWeapon", "Dropped",
		function(self, prevOwner)

			local ammopackMapName = self:GetAmmoPackMapName()
			
			if ammopackMapName and self.ammo ~= 0 then
			
				local ammoPack = CreateEntity(ammopackMapName, self:GetOrigin(), self:GetTeamNumber())
				ammoPack:SetAmmoPackSize(self.ammo)
				self.ammo = 0
				
				ammoPack.weapon = self:GetId()
				
			end
			
			// Since self.ammo will be 0 it shouldn't be creating a second ammo pack when we call the original func
			originalClipWeaponDropped(self, prevOwner)
		end)
		
	local originalDropPackOnUpdate
	originalDropPackOnUpdate = Class_ReplaceMethod( "DropPack", "OnUpdate",
		function(self, deltaTime)
			local weapon = self.weapon and Shared.GetEntity(self.weapon)
			
			originalDropPackOnUpdate(self, deltaTime)
			
			// Give it an outline
			if Client then
				EquipmentOutline_UpdateModel(self)
			end
			
			// If the ammo entity has an associated weapon set that as our origin
			// Makes ammo packs from dropped weapons sit next to the weapons
			if weapon ~= nil and weapon.weaponWorldState == true then
				if self:GetOrigin() ~= weapon:GetOrigin() then
					// With this set to nil the original update accepts its fate and succumbs to my power
					self.onGroundPoint = nil
					self:SetOrigin(weapon:GetOrigin())
				end
			// When the weapon gets picked up, move the ammo to the floor so it can get picked up
			// Prevents magical floating ammo when you pick up weapons mid-air
			elseif self.weapon then
				local trace = Shared.TraceRay(self:GetOrigin() + kUpVector * 0.025, self:GetOrigin() - kUpVector * 20, CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOneAndIsa(self, "Player"))
				self:SetOrigin(Vector(trace.endPoint))
				
				// Remember to nullify the self.weapon or when you drop the weapon somewhere else the ammo will follow!
				self.weapon = nil
			end
		
		end)
end


if Client then
	local function SortByGreatestCost(item1, item2)

		local cost1 = HasMixin(item1, "Tech") and LookupTechData(item1:GetTechId(), kTechDataCostKey, 0) or 0
		local cost2 = HasMixin(item2, "Tech") and LookupTechData(item2:GetTechId(), kTechDataCostKey, 0) or 0

		return cost1 < cost2

	end


	local function NewFindNearbyWeapon(self, toPosition )

		local autoPickupEnabled = CHUDGetOption("autopickup")
				
		local nearbyWeapons = GetEntitiesWithMixinWithinRange("Pickupable", toPosition, kFindWeaponRange)
		table.sort(nearbyWeapons, SortByGreatestCost )
		
		for i, nearbyWeapon in ipairs(nearbyWeapons) do
		
			if nearbyWeapon:isa("Weapon") and nearbyWeapon:GetIsValidRecipient(self) then
				
				local foundWeapon = true
				
				local techId = HasMixin(nearbyWeapon, "Tech") and nearbyWeapon:GetTechId() or 0
				if autoPickupEnabled then
					
					if kTechId.LayMines or techId == kTechId.Pistol then
						local pickupSlot = nearbyWeapon:GetHUDSlot()
						local isEmptySlot = (self:GetWeaponInHUDSlot(pickupSlot) == nil) or (self:GetWeaponInHUDSlot(pickupSlot):isa("Axe"))
						if isEmptySlot then
							foundWeapon = false
						end
					elseif techId == kTechId.Welder then
						foundWeapon = false						
					end
					
				end
				
				if foundWeapon then
					return nearbyWeapon
				end
				
			end
			
		end
		
		return nil

	end

	ReplaceUpValue( MarineActionFinderMixin.OnProcessMove, "FindNearbyWeapon", NewFindNearbyWeapon )
end