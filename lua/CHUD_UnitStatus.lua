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
			if CHUDSettings["minnps"] then
				unitName = destinationName
			end
		elseif CHUDSettings["minnps"] and not viewer:isa("Commander") then
			unitName = nil
		end
	
	else
		if CHUDSettings["minnps"] and not viewer:isa("Commander") then
			unitName = nil
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
			if CHUDSettings["minnps"] then
				unitName = destinationName
			end
		elseif CHUDSettings["minnps"] and not viewer:isa("Commander") then
			unitName = nil
		end
	
	else
		if CHUDSettings["minnps"] and not viewer:isa("Commander") then
			unitName = nil
		end
	end

	return unitName

end

Script.Load("lua/Player_Client.lua")
local function LocalIsFriendlyCommander(player, unit)
	return player:isa("Commander") and ( unit:isa("Player") or (HasMixin(unit, "Selectable") and unit:GetIsSelected(player:GetTeamNumber())) )
end

local kUnitStatusDisplayRange = 13
local kUnitStatusCommanderDisplayRange = 50
local kDefaultHealthOffset = 1.2

// I hate doing this, try to find a way to do this properly at some point (if possible)

function PlayerUI_GetUnitStatusInfo()

	local unitStates = { }
	
	local player = Client.GetLocalPlayer()
	
	if player and not player:GetBuyMenuIsDisplaying() and (not player.GetDisplayUnitStates or player:GetDisplayUnitStates()) then
	
		local eyePos = player:GetEyePos()
		local crossHairTarget = player:GetCrossHairTarget()
		
		local range = kUnitStatusDisplayRange
		
		if player:isa("Commander") then
			range = kUnitStatusCommanderDisplayRange
		end
		
		local healthOffsetDirection = player:isa("Commander") and Vector.xAxis or Vector.yAxis
	
		for index, unit in ipairs(GetEntitiesWithMixinWithinRange("UnitStatus", eyePos, range)) do
		
			// checks here if the model was rendered previous frame as well
			local status = unit:GetUnitStatus(player)
			if unit:GetShowUnitStatusFor(player) then       

				// Get direction to blip. If off-screen, don't render. Bad values are generated if 
				// Client.WorldToScreen is called on a point behind the camera.
				local origin = nil
				local getEngagementPoint = unit.GetEngagementPoint
				if getEngagementPoint then
					origin = getEngagementPoint(unit)
				else
					origin = unit:GetOrigin()
				end
				
				local normToEntityVec = GetNormalizedVector(origin - eyePos)
				local normViewVec = player:GetViewAngles():GetCoords().zAxis
			
				local dotProduct = normToEntityVec:DotProduct(normViewVec)
				
				if dotProduct > 0 then

					local statusFraction = unit:GetUnitStatusFraction(player)
					local description = unit:GetUnitName(player)
					local action = unit:GetActionName(player)
					local hint = unit:GetUnitHint(player)
					local distance = (origin - eyePos):GetLength()
					
					if CHUDSettings["minnps"] then
						hint = ""
					end
					
					local healthBarOffset = kDefaultHealthOffset
					
					local getHealthbarOffset = unit.GetHealthbarOffset
					if getHealthbarOffset then
						healthBarOffset = getHealthbarOffset(unit)
					end
					
					local healthBarOrigin = origin + healthOffsetDirection * healthBarOffset
					
					local worldOrigin = Vector(origin)
					origin = Client.WorldToScreen(origin)
					healthBarOrigin = Client.WorldToScreen(healthBarOrigin)
					
					if unit == crossHairTarget then
					
						healthBarOrigin.y = math.max(GUIScale(180), healthBarOrigin.y)
						healthBarOrigin.x = Clamp(healthBarOrigin.x, GUIScale(320), Client.GetScreenWidth() - GUIScale(320))
						
					end

					local health = 0
					local armor = 0

					local visibleToPlayer = true                        
					if HasMixin(unit, "Cloakable") and GetAreEnemies(player, unit) then
					
						if unit:GetIsCloaked() or (unit:isa("Player") and unit:GetCloakFraction() > 0.2) then                    
							visibleToPlayer = false
						end
						
					end
					
					// Don't show tech points or nozzles if they are attached
					if (unit:GetMapName() == TechPoint.kMapName or unit:GetMapName() == ResourcePoint.kPointMapName) and unit.GetAttached and (unit:GetAttached() ~= nil) then
						visibleToPlayer = false
					end
					
					if HasMixin(unit, "Live") and (not unit.GetShowHealthFor or unit:GetShowHealthFor(player)) then
					
						health = unit:GetHealthFraction()                
						if unit:GetArmor() == 0 then
							armor = 0
						else 
							armor = unit:GetArmorScalar()
						end

						if CHUDSettings["minnps"] and not player:isa("Commander") then				
							health = 0
							armor = 0
							hint = string.format("%d/%d",math.ceil(unit:GetHealth()),math.ceil(unit:GetArmor()))
							if unit:isa("Exo") then
								hint = string.format("%d",math.ceil(unit:GetArmor()))
							end
						end
						
					end
					
					local badgeTextures = ""
					
					if HasMixin(unit, "Player") then
						if unit.GetShowBadgeOverride and not unit:GetShowBadgeOverride() then
							badgeTextures = {}
						else
							badgeTextures = Badges_GetBadgeTextures(unit:GetClientIndex(), "unitstatus") or {}
						end
					end
					
					if (unit:GetMapName() ~= TechPoint.kMapName and unit:GetMapName() ~= ResourcePoint.kPointMapName) and not player:isa("Commander") then
						if CHUDSettings["minnps"] and not (unit:isa("Player") and not unit:isa("Embryo")) then
							if (unit:GetMapName() == PhaseGate.kMapName or unit:GetMapName() == TunnelEntrance.kMapName) and description ~= nil then
								description = string.format("%s (%d%%)",description, math.ceil(unit:GetHealthScalar()*100))
							else
								description = string.format("%d%%",math.ceil(unit:GetHealthScalar()*100))
							end
							health = 0
							armor = 0
							hint = string.format("%d/%d",math.ceil(unit:GetHealth()),math.ceil(unit:GetArmor()))
						end
					end
					
					local hasWelder = false 
					if distance < 10 then    
						hasWelder = unit:GetHasWelder(player)
					end
					
					local abilityFraction = 0
					if player:isa("Commander") then        
						abilityFraction = unit:GetAbilityFraction()
					end
										
					local unitState = {
						
						Position = origin,
						WorldOrigin = worldOrigin,
						HealthBarPosition = healthBarOrigin,
						Status = status,
						Name = description,
						Action = action,
						Hint = hint,
						StatusFraction = statusFraction,
						HealthFraction = health,
						ArmorFraction = armor,
						IsCrossHairTarget = (unit == crossHairTarget and visibleToPlayer) or LocalIsFriendlyCommander(player, unit),
						TeamType = kNeutralTeamType,
						ForceName = unit:isa("Player") and not GetAreEnemies(player, unit),
						BadgeTextures = badgeTextures,
						HasWelder = hasWelder,
						IsPlayer = unit:isa("Player"),
						IsSteamFriend = unit:isa("Player") and unit:GetIsSteamFriend() or false,
						AbilityFraction = abilityFraction,
						// (CHUD) Added parasite indicator
						IsParasited = HasMixin(unit, "ParasiteAble") and unit:GetIsParasited()
					
					}
					
					if unit.GetTeamNumber then
						unitState.IsFriend = (unit:GetTeamNumber() == player:GetTeamNumber())
					end
					
					if unit.GetTeamType then
						unitState.TeamType = unit:GetTeamType()
					end
					
					if not CHUDSettings["friends"] then
						unitState.IsSteamFriend = false
					end
					
					table.insert(unitStates, unitState)
				
				end
				
			end
		
		end
		
	end
	
	return unitStates

end

// Gotta do it with this new stuff too!
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
                    if steamId and CHUDSettings["friends"] then
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