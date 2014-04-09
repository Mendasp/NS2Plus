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
		
		return hintTable
	else
		return hint
	end
end

local kMinimapBlipTeamAlien = kMinimapBlipTeam.Alien
local kMinimapBlipTeamMarine = kMinimapBlipTeam.Marine
local kMinimapBlipTeamFriendAlien = kMinimapBlipTeam.FriendAlien
local kMinimapBlipTeamFriendMarine = kMinimapBlipTeam.FriendMarine
local kMinimapBlipTeamInactiveAlien = kMinimapBlipTeam.InactiveAlien
local kMinimapBlipTeamInactiveMarine = kMinimapBlipTeam.InactiveMarine
local kMinimapBlipTeamFriendly = kMinimapBlipTeam.Friendly
local kMinimapBlipTeamEnemy = kMinimapBlipTeam.Enemy
local kMinimapBlipTeamNeutral = kMinimapBlipTeam.Neutral
function PlayerUI_GetStaticMapBlips()

    PROFILE("PlayerUI_GetStaticMapBlips")
    
    local player = Client.GetLocalPlayer()
    local blipsData = { }
    local numBlips = 0
    
    if player then
    
        local playerTeam = player:GetTeamNumber()
        local playerNoTeam = playerTeam == kRandomTeamType or playerTeam == kNeutralTeamType
        local playerEnemyTeam = GetEnemyTeamNumber(playerTeam)
        local playerId = player:GetId()
        
        local mapBlipList = Shared.GetEntitiesWithClassname("MapBlip")
        local GetEntityAtIndex = mapBlipList.GetEntityAtIndex
        local GetMapBlipTeamNumber = MapBlip.GetTeamNumber
        local GetMapBlipOrigin = MapBlip.GetOrigin
        local GetMapBlipRotation = MapBlip.GetRotation
        local GetMapBlipType = MapBlip.GetType
        local GetMapBlipIsInCombat = MapBlip.GetIsInCombat
        local GetIsSteamFriend = Client.GetIsSteamFriend
        local ClientIndexToSteamId = GetSteamIdForClientIndex
        local GetIsMapBlipActive = MapBlip.GetIsActive
        
        for index = 0, mapBlipList:GetSize() - 1 do
        
            local blip = GetEntityAtIndex(mapBlipList, index)
            if blip ~= nil and blip.ownerEntityId ~= playerId then
      
                local blipTeam = kMinimapBlipTeamNeutral
                local blipTeamNumber = GetMapBlipTeamNumber(blip)
                local isSteamFriend = false
                
                if blip.clientIndex and blip.clientIndex > 0 and blipTeamNumber ~= GetEnemyTeamNumber(playerTeam) then

                    local steamId = ClientIndexToSteamId(blip.clientIndex)
                    if steamId and CHUDGetOption("friends") then
                        isSteamFriend = GetIsSteamFriend(steamId)
                    end
                    
                end
                
                if not GetIsMapBlipActive(blip) then

                    if blipTeamNumber == kMarineTeamType then
                        blipTeam = kMinimapBlipTeamInactiveMarine
                    elseif blipTeamNumber== kAlienTeamType then
                        blipTeam = kMinimapBlipTeamInactiveAlien
                    end

                elseif isSteamFriend then
                
                    if blipTeamNumber == kMarineTeamType then
                        blipTeam = kMinimapBlipTeamFriendMarine
                    elseif blipTeamNumber== kAlienTeamType then
                        blipTeam = kMinimapBlipTeamFriendAlien
                    end
                
                else

                    if blipTeamNumber == kMarineTeamType then
                        blipTeam = kMinimapBlipTeamMarine
                    elseif blipTeamNumber== kAlienTeamType then
                        blipTeam = kMinimapBlipTeamAlien
                    end
                    
                end  
                
                local i = numBlips * 10
                local blipOrig = GetMapBlipOrigin(blip)
                blipsData[i + 1] = blipOrig.x
                blipsData[i + 2] = blipOrig.z
                blipsData[i + 3] = GetMapBlipRotation(blip)
                blipsData[i + 4] = 0
                blipsData[i + 5] = 0
                blipsData[i + 6] = GetMapBlipType(blip)
                blipsData[i + 7] = blipTeam
                blipsData[i + 8] = GetMapBlipIsInCombat(blip)
                blipsData[i + 9] = isSteamFriend
                blipsData[i + 10] = blip.isHallucination == true
                
                numBlips = numBlips + 1
                
            end
            
        end
        
        for index, blip in ientitylist(Shared.GetEntitiesWithClassname("SensorBlip")) do
        
            local blipOrigin = blip:GetOrigin()
            
            local i = numBlips * 10
            
            blipsData[i + 1] = blipOrigin.x
            blipsData[i + 2] = blipOrigin.z
            blipsData[i + 3] = 0
            blipsData[i + 4] = 0
            blipsData[i + 5] = 0
            blipsData[i + 6] = kMinimapBlipType.SensorBlip
            blipsData[i + 7] = kMinimapBlipTeamEnemy
            blipsData[i + 8] = false
            blipsData[i + 9] = false
            blipsData[i + 10] = false
            
            numBlips = numBlips + 1
            
        end
        
        local orders = GetRelevantOrdersForPlayer(player)
        for o = 1, #orders do
        
            local order = orders[o]
            local blipOrigin = order:GetLocation()
            
            local blipType = kMinimapBlipType.MoveOrder
            local orderType = order:GetType()
            if orderType == kTechId.Construct or orderType == kTechId.AutoConstruct then
                blipType = kMinimapBlipType.BuildOrder
            elseif orderType == kTechId.Attack then
                blipType = kMinimapBlipType.AttackOrder
            end
            
            local i = numBlips * 10
            
            blipsData[i + 1] = blipOrigin.x
            blipsData[i + 2] = blipOrigin.z
            blipsData[i + 3] = 0
            blipsData[i + 4] = 0
            blipsData[i + 5] = 0
            blipsData[i + 6] = blipType
            blipsData[i + 7] = kMinimapBlipTeamFriendly
            blipsData[i + 8] = false
            blipsData[i + 9] = false
            blipsData[i + 10] = false
            
            numBlips = numBlips + 1
            
        end
        
        if GetPlayerIsSpawning() then
        
            local spawnPosition = GetDesiredSpawnPosition()
            
            if spawnPosition then
            
                local i = numBlips * 10
            
                blipsData[i + 1] = spawnPosition.x
                blipsData[i + 2] = spawnPosition.z
                blipsData[i + 3] = 0
                blipsData[i + 4] = 0
                blipsData[i + 5] = 0
                blipsData[i + 6] = kMinimapBlipType.MoveOrder
                blipsData[i + 7] = kMinimapBlipTeamFriendly
                blipsData[i + 8] = false
                blipsData[i + 9] = false
                blipsData[i + 10] = false
                
                numBlips = numBlips + 1
            
            end
        
        end
        
        if player:isa("Fade") then
        
            local vortexAbility = player:GetWeapon(Vortex.kMapName)
            if vortexAbility then
            
                local gate = vortexAbility:GetEtherealGate()
                if gate then
                
                    local i = numBlips * 10
                
                    local blipOrig = gate:GetOrigin()
                
                    blipsData[i + 1] = blipOrig.x
                    blipsData[i + 2] = blipOrig.z
                    blipsData[i + 3] = 0
                    blipsData[i + 4] = 0
                    blipsData[i + 5] = 0
                    blipsData[i + 6] = kMinimapBlipType.EtherealGate
                    blipsData[i + 7] = kMinimapBlipTeam.Friendly
                    blipsData[i + 8] = false
                    blipsData[i + 9] = false
                    blipsData[i + 10] = false
                    
                    numBlips = numBlips + 1
                    
                end
            
            end
        
        end
        
        local highlightPos = GetHighlightPosition()
        if highlightPos then

                local i = numBlips * 10

                blipsData[i + 1] = highlightPos.x
                blipsData[i + 2] = highlightPos.z
                blipsData[i + 3] = 0
                blipsData[i + 4] = 0
                blipsData[i + 5] = 0
                blipsData[i + 6] = kMinimapBlipType.HighlightWorld
                blipsData[i + 7] = kMinimapBlipTeam.Friendly
                blipsData[i + 8] = false
                blipsData[i + 9] = false
                blipsData[i + 10] = false
                
                numBlips = numBlips + 1
            
        end
        
    end

    return blipsData
    
end