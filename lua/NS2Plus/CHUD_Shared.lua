kCHUDElixerVersion = 1.72
Script.Load("lua/NS2Plus/Elixer_Utility.lua")
Elixer.UseVersion( kCHUDElixerVersion ) 

-- Remove with 267
Script.Load("lua/NS2Plus/CHUD_Shared266.lua")

kCHUDStatsTrackAccLookup =
	set {
		kTechId.Pistol, kTechId.Rifle, kTechId.Minigun, kTechId.Railgun, kTechId.Shotgun,
		kTechId.Axe, kTechId.Bite, kTechId.Parasite, kTechId.Spit, kTechId.Swipe, kTechId.Gore,
		kTechId.LerkBite, kTechId.Spikes, kTechId.Stab
	}

// CompMod v3 compat.
if rawget( kTechId, "HeavyMachineGun" ) then
	kCHUDStatsTrackAccLookup[kTechId.HeavyMachineGun] = true
end


kHitsoundMode = enum { 'Hitcount', 'Overkill' }
kCHUDDamageMaxDamage = 4095
kCHUDDamage2MessageMaxHitCount = 14

local kCHUDDamageMessage =
{
	posx = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
	posy = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
	posz = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
	targetId = "entityid",
	amount = string.format("integer (0 to %d)", kCHUDDamageMaxDamage ),
	overkill = string.format("integer (0 to %d)", kCHUDDamageMaxDamage ),
}

local kCHUDDeathStatsMessage =
{
	lastAcc = "float (0 to 100 by 0.01)",
	currentAcc = "float (0 to 100 by 0.01)",
	pdmg = "float (0 to 524288 by 0.01)",
	sdmg = "float (0 to 524288 by 0.01)",
}

local kCHUDEndStatsWeaponMessage =
{
	wTechId = "enum kTechId",
	accuracy = "float (0 to 100 by 0.01)",
	accuracyOnos = "float (-1 to 100 by 0.01)",
}

local kCHUDEndStatsOverallMessage =
{
	accuracy = "float (0 to 100 by 0.01)",
	accuracyOnos = "float (-1 to 100 by 0.01)",
	pdmg = "float (0 to 524288 by 0.01)",
	sdmg = "float (0 to 524288 by 0.01)",
}

local kCHUDMarineCommStatsMessage =
{
	medpackAccuracy = "float (0 to 100 by 0.01)",
	medpackResUsed = "integer (0 to 65536)",
	medpackResExpired = "integer (0 to 65536)",
	medpackEfficiency = "float (0 to 100 by 0.01)",
	medpackRefill = "integer (0 to 262144)",
	ammopackResUsed = "integer (0 to 65536)",
	ammopackResExpired = "integer (0 to 65536)",
	ammopackEfficiency = "float (0 to 100 by 0.01)",
	ammopackRefill = "integer (0 to 262144)",
	catpackResUsed = "integer (0 to 65536)",
	catpackResExpired = "integer (0 to 65536)",
	catpackEfficiency = "float (0 to 100 by 0.01)",
}

local kCHUDOptionMessage =
{
	disabledOption = "string (32)"
}

local kCHUDAutopickupMessage =
{
	autoPickup = "boolean",
	autoPickupBetter = "boolean",
}

function BuildCHUDDamageMessage( target, amount, hitpos, overkill )
	
    local t = {}
    t.posx = hitpos.x
    t.posy = hitpos.y
    t.posz = hitpos.z
    t.amount = math.min( math.max( amount, 0 ), 4095 )
	t.overkill = math.min( math.max( overkill, 0 ), kCHUDDamageMaxDamage )
    t.targetId = (target and target:GetId()) or Entity.invalidId
    return t
	
end

function ParseCHUDDamageMessage(message)
    local position = Vector(message.posx, message.posy, message.posz)
    return Shared.GetEntity(message.targetId), message.amount, position, message.overkill
end

Shared.RegisterNetworkMessage( "CHUDDamage", kCHUDDamageMessage )
Shared.RegisterNetworkMessage( "CHUDOption", kCHUDOptionMessage )
Shared.RegisterNetworkMessage( "SetCHUDAutopickup", kCHUDAutopickupMessage)
Shared.RegisterNetworkMessage( "CHUDDeathStats", kCHUDDeathStatsMessage)
Shared.RegisterNetworkMessage( "CHUDEndStatsWeapon", kCHUDEndStatsWeaponMessage)
Shared.RegisterNetworkMessage( "CHUDEndStatsOverall", kCHUDEndStatsOverallMessage)
Shared.RegisterNetworkMessage( "CHUDMarineCommStats", kCHUDMarineCommStatsMessage)

Script.Load("lua/NS2Plus/Shared/CHUD_Utility.lua")
Script.Load("lua/NS2Plus/Shared/CHUD_Autopickup.lua")
Script.Load("lua/NS2Plus/Shared/CHUD_CommanderSelection.lua")
Script.Load("lua/NS2Plus/Shared/CHUD_LayMines.lua")
Script.Load("lua/NS2Plus/Shared/CHUD_AmmoPack.lua")
Script.Load("lua/NS2Plus/Shared/CHUD_Grenade.lua")
Script.Load("lua/NS2Plus/Shared/CHUD_BoneWall.lua")
Script.Load("lua/NS2Plus/Shared/CHUD_LerkBite.lua")
Script.Load("lua/NS2Plus/Shared/CHUD_BlueprintPowerPoint.lua")
Script.Load("lua/NS2Plus/Shared/CHUD_Autoreload.lua")
Script.Load("lua/NS2Plus/Shared/CHUD_Weapon.lua")
Script.Load("lua/NS2Plus/Shared/CHUD_TriggerMixin.lua")

Script.Load("lua/NS2Plus/Shared/CHUD_ReadyRoom.lua")

CHUDTagBitmask = {
	mcr = 0x1,
	ambient = 0x2,
	mapparticles = 0x4,
	nsllights = 0x8,
	deathstats = 0x0,
}

local embryoNetworkVars =
{
	evolvePercentage = "float",
}

local pickupableNetworkVars =
{
	expireTime = "time (by 0.1)",
}

local catpackNetworkVars =
{
	catpackboost = "boolean",
}

Class_Reload("Embryo", embryoNetworkVars)
Class_Reload("Weapon", pickupableNetworkVars)
Class_Reload("DropPack", pickupableNetworkVars)
Class_Reload("Marine", catpackNetworkVars)
Class_Reload("Exo", catpackNetworkVars)
