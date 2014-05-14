local originalUpdateScore = PlayerInfoEntity.UpdateScore
function PlayerInfoEntity:UpdateScore()

	originalUpdateScore(self)

if not Shine then
	local player = Shared.GetEntity( self.playerId )  
		if not player then return end

	local client = player:GetClient()
		if not client then return end

	local score = player.score or 0

	local name = player.GetName and player:GetName() or "Unknown"

	Server.UpdatePlayerInfo( client, name, score )
end
	
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