Script.Load("lua/Shared/CHUD_Utility.lua")
Script.Load("lua/Shared/CHUD_GameInfo.lua")

CHUDTagBitmask = {
	mcr = 0x1,
	ambient = 0x2,
	mapparticles = 0x4,
	nsllights = 0x8,
	deathstats = 0x0,
}

local kCHUDStatsMessage =
{
    isPlayer = "boolean",
    weapon = "enum kTechId",
    targetId = "entityid",
    damage = "float",
}

local kCHUDOptionMessage =
{
	disabledOption = "string (32)"
}

local playerInfoNetworkVars =
{
	extraTech = "string (128)",
	isParasited = "boolean",
}

local embryoNetworkVars =
{
    evolvePercentage = "float",
}

local kCHUDAutopickupMessage =
{
	autoPickup = "boolean",
}

if Server then

	local originalUpdateScore = PlayerInfoEntity.UpdateScore
	function PlayerInfoEntity:UpdateScore()
	
		originalUpdateScore(self)
		
		local scorePlayer = Shared.GetEntity(self.playerId)
		local playerEntity = Shared.GetEntity(self.entityId)

		if scorePlayer then
			local upgrades = ""
			if playerEntity:isa("Alien") then
				for _, upgrade in pairs (Shared.GetEntity(self.entityId):GetUpgrades()) do
					if upgrades == "" then
						upgrades = tostring(upgrade)
					else
						upgrades = upgrades .. " " .. tostring(upgrade)
					end
				end
				extraInfo = upgrades
			elseif playerEntity:isa("Marine") then
				self.isParasited = playerEntity:GetIsParasited()

				if playerEntity:isa("JetpackMarine") then
					upgrades = tostring(kTechId.Jetpack)
				end
				
				local displayWeapons = { { Welder.kMapName, kTechId.Welder },
					{ ClusterGrenade.kMapName, kTechId.ClusterGrenade },
					{ PulseGrenade.kMapName, kTechId.PulseGrenade },
					{ GasGrenade.kMapName, kTechId.GasGrenade },
					{ Mine.kMapName, kTechId.Mine} }
				
				for _, weapon in pairs(displayWeapons) do
					if playerEntity:GetWeapon(weapon[1]) ~= nil then
						if upgrades == "" then
							upgrades = tostring(weapon[2])
						else
							upgrades = upgrades .. " " .. tostring(weapon[2])
						end
					end
				end

			end
			
			self.extraTech = upgrades

		end
		
		return true

	end

end

Class_Reload("PlayerInfoEntity", playerInfoNetworkVars)
Class_Reload("Embryo", embryoNetworkVars)

Shared.RegisterNetworkMessage( "CHUDStats", kCHUDStatsMessage )
Shared.RegisterNetworkMessage( "CHUDOption", kCHUDOptionMessage )
Shared.RegisterNetworkMessage( "SetCHUDAutopickup", kCHUDAutopickupMessage)
