Script.Load("lua/PhaseGate.lua")

function PhaseGate:GetUnitNameOverride(viewer)

	local function GetDestinationLocationName(self)

		local locationEndId = self:GetDestLocationId()
		local location = Shared.GetEntity(locationEndId)
		
		if location then
			return location:GetName()
		end

	end

	local unitName = GetDisplayName(self)

	if not GetAreEnemies(self, viewer) then
	
		local destinationName = GetDestinationLocationName(self)        
		if destinationName then
			unitName = unitName .. " to " .. destinationName
			if CHUDGetOption("minnps") then
				unitName = destinationName
			end
		end
	end

	return unitName

end

Script.Load("lua/TunnelEntrance.lua")
function TunnelEntrance:GetUnitNameOverride(viewer)

	local function GetDestinationLocationName(self)

		local location = Shared.GetEntity(self.destLocationId)
		
		if location then
			return location:GetName()
		end

	end

	local unitName = GetDisplayName(self)

	if not GetAreEnemies(self, viewer) then
	
		local destinationName = GetDestinationLocationName(self)        
		if destinationName then
			unitName = unitName .. " to " .. destinationName
			if CHUDGetOption("minnps") then
				unitName = destinationName
			end
		end
		
	end

	return unitName

end

// This is a 5/10 hack according to Dragon
// I love it, I'd give it a 7 at least.
originalGetUnitHint = UnitStatusMixin.GetUnitHint
function UnitStatusMixin:GetUnitHint(forEntity)
	
	local hint = originalGetUnitHint(self, forEntity)
	
	if not Client.GetOptionBoolean("showHints", true) then
		hint = ""
	end
	
	local player = Client.GetLocalPlayer()
	
	
	if HasMixin(self, "Live") and (not self.GetShowHealthFor or self:GetShowHealthFor(player)) and CHUDHint then
	
		local description = self:GetUnitName(player)
		local marineWeapon
		
		if self:isa("Player") and self:isa("Marine") and HasMixin(self, "WeaponOwner") then
			local validWeapons = { "rifle", "shotgun", "flamethrower", "grenadelauncher" }
			local primaryWeapon = self:GetWeaponInHUDSlot(1)
			if primaryWeapon and primaryWeapon:isa("ClipWeapon") and table.contains(validWeapons, primaryWeapon:GetMapName()) then
				marineWeapon = primaryWeapon:GetMapName()
			end
		end
		
		if CHUDGetOption("minnps") and not player:isa("Commander") then
			hint = string.format("%d/%d",math.ceil(self:GetHealth()),math.ceil(self:GetArmor()))
			if self:isa("Exo") then
				hint = string.format("%d",math.ceil(self:GetArmor()))
			end
		end
		
		if (self:GetMapName() ~= TechPoint.kMapName and self:GetMapName() ~= ResourcePoint.kPointMapName) and not player:isa("Commander") then
			if CHUDGetOption("minnps") and (not self:isa("Player") or (self:isa("Embryo") and GetAreEnemies(player, self))) then
				if ((self:GetMapName() == PhaseGate.kMapName and player:isa("Marine")) or (self:GetMapName() == TunnelEntrance.kMapName and player:isa("Alien"))) then
					description = string.format("%s (%d%%)",description, math.ceil(self:GetHealthScalar()*100))
				else
					description = string.format("%d%%",math.ceil(self:GetHealthScalar()*100))
				end
			end
		end
	
		local hintTable = 
		{
			Description = description,
			Percentage = self:GetHealthScalar()*100,
			Health = self:GetHealth(),
			Armor = self:GetArmor(),
			MarineWeapon = marineWeapon,
			Hint = hint,
			IsSteamFriend = (self:isa("Player") and self:GetIsSteamFriend() or false) and CHUDGetOption("friends"),
			IsParasited = HasMixin(self, "ParasiteAble") and self:GetIsParasited(),
		}
		
		if self:isa("InfantryPortal") then
			if self.queuedPlayerId ~= Entity.invalidId then			
				local playerName = "";
				for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
					if playerInfo.playerId == self.queuedPlayerId then
						playerName = playerInfo.playerName;
						break;
					end
				end
				
				hintTable.IsSpawning = true;
				hintTable.PlayerName = playerName;
				hintTable.SpawnFraction = Clamp((Shared.GetTime() - self.timeSpinStarted) / kMarineRespawnTime, 0, 1);				
			end
		end
		
		return hintTable
	end
	
	return hint
end