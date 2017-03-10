-- CompMod v3 compat.
if rawget( kTechId, "HeavyMachineGun" ) then
    Marine.kPickupPriority[kTechId.HeavyMachineGun] = 3
end

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

local function PickupWeapon(self, weapon, wasAutoPickup)
    
    -- some weapons completely replace other weapons (welder > axe).
    local replacement = weapon.GetReplacementWeaponMapName and weapon:GetReplacementWeaponMapName()
    local obsoleteWep = replacement and self:GetWeapon(replacement)
    if obsoleteWep then
        self:RemoveWeapon(obsoleteWep)
        DestroyEntity(obsoleteWep)
    end
    
    -- find the weapon that is about to be dropped to make room for this one
    local slot = weapon:GetHUDSlot()
    local oldWep = self:GetWeaponInHUDSlot(slot)
    
    -- perform the actual weapon pickup (also drops weapon in the slot)
    self:AddWeapon(weapon, not wasAutoPickup or slot == 1) -- change from vanilla is here. this prevents e.g. autoswitching to welder if you autopick it up
    StartSoundEffectAtOrigin(Marine.kGunPickupSound, self:GetOrigin())
    
    if not wasAutoPickup then
        self:SetHUDSlotActive(weapon:GetHUDSlot())
    end
    
    self.timeOfLastPickUpWeapon = Shared.GetTime()
    self.lastDroppedWeapon = oldWep
    
end

ReplaceUpValue(Marine.HandleButtons, "PickupWeapon", PickupWeapon, { LocateRecurse = true; CopyUpValues = true })

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