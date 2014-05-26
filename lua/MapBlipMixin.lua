// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\MapBlipMixin.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com) 
//    Modified by: Mats Olsson (mats.olsson@matsotech.se)   
//    
// Creates a mapblip for an entity that may have one. 
//
// Also marks a mapblip as dirty for later updates if it changes, by
// listening on SetLocation, SetAngles and SetSighted calls.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

MapBlipMixin = CreateMixin( MapBlipMixin )
MapBlipMixin.type = "MapBlip"

//
// Listen on the state that the mapblip depends on
//
MapBlipMixin.expectedCallbacks =
{
    SetOrigin = "Sets the location of an entity",
    SetAngles = "Sets the angles of an entity",
    SetCoords = "Sets both both location and angles"
}

MapBlipMixin.optionalCallbacks =
{
    GetDestroyMapBlipOnKill = "Return true to destroy map blip when units is killed.",
	OnGetMapBlipInfo = "Override for getting the Map Blip Info",
}


// What entities have become dirty.
// Flushed in the UpdateServer hook by MapBlipMixin.OnUpdateServer
local mapBlipMixinDirtyTable = { }

/**
 * Update all dirty mapblips
 */
local function MapBlipMixinOnUpdateServer()

    PROFILE("MapBlipMixin:OnUpdateServer")
    
    for entityId, _ in pairs(mapBlipMixinDirtyTable) do
    
        local entity = Shared.GetEntity(entityId)
        local mapBlip = entity and entity.mapBlipId and Shared.GetEntity(entity.mapBlipId)
        
        if mapBlip then
            mapBlip:Update()
        end
        
    end
    
    mapBlipMixinDirtyTable = { }
    
end

local function CreateMapBlip(self, blipType, blipTeam, isInCombat)

    local mapName = self:isa("Player") and PlayerMapBlip.kMapName or MapBlip.kMapName

    local mapBlip = Server.CreateEntity(mapName)
    // This may fail if there are too many entities.
    if mapBlip then
    
        mapBlip:SetOwner(self:GetId(), blipType, blipTeam)
        self.mapBlipId = mapBlip:GetId()
        
    end
    
end

function MapBlipMixin:__initmixin()

    assert(Server)
    
    // Check if the new entity should have a map blip to represent it.
    local success, blipType, blipTeam, isInCombat = self:GetMapBlipInfo()
    if success then
        CreateMapBlip(self, blipType, blipTeam, isInCombat)
    end
    
end

/**
 * Intercept the functions that changes the state the mapblip depends on
 */
function MapBlipMixin:SetOrigin(origin)
    mapBlipMixinDirtyTable[self:GetId()] = true
end

function MapBlipMixin:SetAngles(angles)
    mapBlipMixinDirtyTable[self:GetId()] = true
end

function MapBlipMixin:SetCoords(coords)
    mapBlipMixinDirtyTable[self:GetId()] = true
end

function MapBlipMixin:OnEnterCombat()
    mapBlipMixinDirtyTable[self:GetId()] = true
end

function MapBlipMixin:OnLeaveCombat()
    mapBlipMixinDirtyTable[self:GetId()] = true
end

function MapBlipMixin:MarkBlipDirty()
    mapBlipMixinDirtyTable[self:GetId()] = true
end

function MapBlipMixin:OnConstructionComplete()
    mapBlipMixinDirtyTable[self:GetId()] = true
end

function MapBlipMixin:OnPowerOn()
    mapBlipMixinDirtyTable[self:GetId()] = true
end

function MapBlipMixin:OnPowerOff()
    mapBlipMixinDirtyTable[self:GetId()] = true
end

function MapBlipMixin:OnSighted(sighted)

    // because sighted is always set during each LOS calc, we need to keep track of
    // what the previous value was so we don't mark it dirty unnecessarily
    if self.previousSighted ~= sighted then
        self.previousSighted = sighted
        mapBlipMixinDirtyTable[self:GetId()] = true
    end
    
end

function MapBlipMixin:GetMapBlipInfo()

	if self.OnGetMapBlipInfo then
		return self:OnGetMapBlipInfo()
	end
	
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
	local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
	local isParasited = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
    
    // World entities
    if self:isa("Door") then
        blipType = kMinimapBlipType.Door
    elseif self:isa("ResourcePoint") then
        blipType = kMinimapBlipType.ResourcePoint
    elseif self:isa("TechPoint") then
        blipType = kMinimapBlipType.TechPoint
    // Don't display PowerPoints unless they are in an unpowered state.
    elseif self:isa("PowerPoint") then
    
        blipType = ConditionalValue( self:GetIsDisabled(), kMinimapBlipType.DestroyedPowerPoint, kMinimapBlipType.PowerPoint)
        blipTeam = self:GetTeamNumber()
        
    elseif self:isa("Cyst") then
    
        blipType = kMinimapBlipType.Infestation
        
        if not self:GetIsConnected() then
            blipType = kMinimapBlipType.InfestationDying
        end
        
        blipTeam = self:GetTeamNumber()
        isAttacked = false
        
    elseif self:isa("Hallucination") then

        local hallucinatedTechId = self:GetAssignedTechId()
 
        if hallucinatedTechId == kTechId.Drifter then
            blipType = kMinimapBlipType.Drifter
        elseif hallucinatedTechId == kTechId.Hive then
            blipType = kMinimapBlipType.Hive
        elseif hallucinatedTechId == kTechId.Harvester then
            blipType = kMinimapBlipType.Harvester
        end   

        blipTeam = self:GetTeamNumber()
        
    // Everything else that is supported by kMinimapBlipType.
    elseif self:GetIsVisible() then
    
        if rawget( kMinimapBlipType, self:GetClassName() ) ~= nil then
            blipType = kMinimapBlipType[self:GetClassName()]
		else
			Shared.Message( "Element '"..tostring(self:GetClassName()).."' doesn't exist in the kMinimapBlipType enum" )
        end
        
        blipTeam = HasMixin(self, "Team") and self:GetTeamNumber() or kTeamReadyRoom  
        
    end
    
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, isParasited
    
end

function MapBlipMixin:DestroyBlip()

    if self.mapBlipId and Shared.GetEntity(self.mapBlipId) then
    
        DestroyEntity(Shared.GetEntity(self.mapBlipId))
        self.mapBlipId = nil
        
    end
    
end

function MapBlipMixin:OnKill()

    if not self.GetDestroyMapBlipOnKill or self:GetDestroyMapBlipOnKill() then
        self:DestroyBlip()
    end
    
end

function MapBlipMixin:OnDestroy()
    self:DestroyBlip()
end

Event.Hook("UpdateServer", MapBlipMixinOnUpdateServer)