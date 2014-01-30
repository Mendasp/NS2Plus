Script.Load("lua/Player_Client.lua")
local function LocalIsFriendlyCommander(player, unit)
    return player:isa("Commander") and ( unit:isa("Player") or (HasMixin(unit, "Selectable") and unit:GetIsSelected(player:GetTeamNumber())) )
end

local kUnitStatusDisplayRange = 13
local kUnitStatusCommanderDisplayRange = 50
local kDefaultHealthOffset = 1.2

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
							description = string.format("%d%%",math.ceil(unit:GetHealthScalar()*100))
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
                        AbilityFraction = abilityFraction
                    
                    }
                    
                    if unit.GetTeamNumber then
                        unitState.IsFriend = (unit:GetTeamNumber() == player:GetTeamNumber())
                    end
                    
                    if unit.GetTeamType then
                        unitState.TeamType = unit:GetTeamType()
                    end
                    
                    table.insert(unitStates, unitState)
                
                end
                
            end
         
         end
        
    end
    
    return unitStates

end