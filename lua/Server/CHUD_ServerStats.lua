local originaldmgmixin = DamageMixin.DoDamage
function DamageMixin:DoDamage(damage, target, point, direction, surface, altMode, showtracer)
	local weapon
	
	if self:isa("Player") then
		attacker = self
	elseif self:GetParent() and self:GetParent():isa("Player") then
		attacker = self:GetParent()
		weapon = self:GetTechId()
	elseif HasMixin(self, "Owner") and self:GetOwner() and self:GetOwner():isa("Player") then
		attacker = self:GetOwner()
		
		if self.techId ~= nil and self.techId > 1 then
			weapon = self:GetTechId()
		end

		// Map to their proper weapons so we don't need to perform voodoo magic
		local mapname = self:GetMapName()
		
		if mapname == Spit.kMapName then
			weapon = kTechId.Spit
		elseif mapname == Grenade.kMapName then
			weapon = kTechId.GrenadeLauncher
		elseif mapname == Flame.kMapName then
			weapon = kTechId.Flamethrower
		elseif mapname == ClusterGrenade.kMapName or mapname == ClusterFragment.kMapName then
			weapon = kTechId.ClusterGrenade
		elseif mapname == NerveGasCloud.kMapName then
			weapon = kTechId.GasGrenade
		elseif mapname == PulseGrenade.kMapName then
			weapon = kTechId.PulseGrenadeProjectile
		elseif mapname == SporeCloud.kMapName then
			weapon = kTechId.Spores
		elseif mapname == Shockwave.kMapName then
			weapon = kTechId.Stomp
		elseif mapname == DotMarker.kMapName then
			weapon = kTechId.BileBomb
		elseif mapname == WhipBomb.kMapName then
			weapon = kTechId.Whip
		elseif weapon == nil then
			weapon = 1
		end
		//Print(weapon .. " " .. self:GetMapName())
	else
		return originaldmgmixin(self, damage, target, point, direction, surface, altMode, showtracer)
	end
	
	// Save the last damage time so we can revert to it later
	local oldDamageTime = attacker.giveDamageTime
	
	// Save target health before the hit
	local oldTargetHealth = 0
	local oldTargetArmor = 0
	
	if target and HasMixin(target, "Live") and damage > 0 and GetAreEnemies(attacker, target) then
		oldTargetHealth = target:GetHealth()
		oldTargetArmor = target:GetArmor()
	end
	
	// Save the result of the original so it updates all values
	local killedFromDamage = originaldmgmixin(self, damage, target, point, direction, surface, altMode, showtracer)
	
	// Secondary attack on alien weapons (lerk spikes, gorge healspray)
	if (self.secondaryAttacking or self.shootingSpikes) and attacker:isa("Alien") then
		weapon = attacker:GetActiveWeapon():GetSecondaryTechId()
	end
	
	local damageType = kDamageType.Normal
	if self.GetDamageType then
		damageType = self:GetDamageType()
	elseif HasMixin(self, "Tech") then
		damageType = LookupTechData(self:GetTechId(), kTechDataDamageType, kDamageType.Normal)
	end
	
	// Keep the old time and only update it if we hit enemies
	attacker.giveDamageTime = oldDamageTime
	
	if target and HasMixin(target, "Live") and damage > 0 and GetAreEnemies(attacker, target) then
		
		local damageDone = (oldTargetHealth - target.health + (oldTargetArmor - target.armor) * 2)
		
		local msg = { }
		msg.damage = damageDone
		msg.targetId = (target and target:GetId()) or Entity.invalidId
		msg.isPlayer = target:isa("Player")
		msg.weapon = weapon
		Server.SendNetworkMessage(attacker, "CHUDStats", msg, true)
		
		// Only show damage indicator if we're hitting enemies
		if not self.GetShowHitIndicator or self:GetShowHitIndicator() then
			attacker.giveDamageTime = Shared.GetTime()
		end
		
		// When the damage kills the target it doesn't send the last damage number message
		if killedFromDamage then
			local msg = BuildDamageMessage(target, damageDone, point)
			Server.SendNetworkMessage(attacker, "Damage", msg, false)
			
			for _, spectator in ientitylist(Shared.GetEntitiesWithClassname("Spectator")) do
			
				if attacker == Server.GetOwner(spectator):GetSpectatingPlayer() then
					Server.SendNetworkMessage(spectator, "Damage", msg, false)
				end
				
			end
		end
	end

	return killedFromDamage
end

local function CHUDResetCommStats(commSteamId)
	if not CHUDCommStats[commSteamId] then
		CHUDCommStats[commSteamId] = { }
		CHUDCommStats[commSteamId]["medpack"] = { }
		CHUDCommStats[commSteamId]["ammopack"] = { }
		CHUDCommStats[commSteamId]["catpack"] = { }
		
		for index, _ in pairs(CHUDCommStats[commSteamId]) do
			CHUDCommStats[commSteamId][index].hits = 0
			CHUDCommStats[commSteamId][index].misses = 0
			if index ~= "catpack" then
				CHUDCommStats[commSteamId][index].refilled = 0
			end
			if index == "medpack" then
				CHUDCommStats[commSteamId][index].picks = 0
			end
		end
	end
end

local resetGame = NS2Gamerules.ResetGame
function NS2Gamerules:ResetGame()
	resetGame(self)

	Server.SendCommand(nil, "resetstats")
	
	CHUDCommStats = { }
	
	// Do this so we can spawn items without a commander with cheats on
	CHUDResetCommStats(0)
	
	for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
	
		if playerInfo.teamNumber == kTeam1Index and playerInfo.isCommander then
			CHUDResetCommStats(playerInfo.steamId)
			break
		end
	
	end
	
end

CHUDCommStats = { }
CHUDMarineComm = 0

local originalCommandStructureLoginPlayer
originalCommandStructureLoginPlayer = Class_ReplaceMethod("CommandStructure", "LoginPlayer",
	function(self, player)
	
		originalCommandStructureLoginPlayer(self, player)
		
		if player:isa("Marine") then
			CHUDMarineComm = GetSteamIdForClientIndex(player.clientIndex)

			if not CHUDCommStats[CHUDMarineComm] then
				CHUDResetCommStats(CHUDMarineComm)
			end
		end
	
	end)
	

local originalMedPackOnTouch
originalMedPackOnTouch = Class_ReplaceMethod("MedPack", "OnTouch",
	function(self, recipient)
	
		local oldHealth = recipient:GetHealth()
		originalMedPackOnTouch(self, recipient)
		if oldHealth < recipient:GetHealth() then
			// If the medpack hits immediatly expireTime is 0
			if ConditionalValue(self.expireTime == 0, Shared.GetTime(), self.expireTime - kItemStayTime) + 0.1 > Shared.GetTime() then
				CHUDCommStats[CHUDMarineComm]["medpack"].misses = CHUDCommStats[CHUDMarineComm]["medpack"].misses - 1
				CHUDCommStats[CHUDMarineComm]["medpack"].hits = CHUDCommStats[CHUDMarineComm]["medpack"].hits + 1
			end
			CHUDCommStats[CHUDMarineComm]["medpack"].picks = CHUDCommStats[CHUDMarineComm]["medpack"].picks + 1
			CHUDCommStats[CHUDMarineComm]["medpack"].refilled = CHUDCommStats[CHUDMarineComm]["medpack"].refilled + recipient:GetHealth() - oldHealth
		end
	
	end)
	
local function GetAmmoCount(player)
	local ammoCount = 0
	
	for i = 0, player:GetNumChildren() - 1 do
		local child = player:GetChildAtIndex(i)
		if child:isa("ClipWeapon") then
			ammoCount = ammoCount + child:GetAmmo()
		end
	end
	
	return ammoCount
end
	
local originalAmmoPackOnTouch
originalAmmoPackOnTouch = Class_ReplaceMethod("AmmoPack", "OnTouch",
	function(self, recipient)
	
		local oldAmmo = GetAmmoCount(recipient)
		originalAmmoPackOnTouch(self, recipient)
		local newAmmo = GetAmmoCount(recipient)
		if oldAmmo < newAmmo then
			CHUDCommStats[CHUDMarineComm]["ammopack"].misses = CHUDCommStats[CHUDMarineComm]["ammopack"].misses - 1
			CHUDCommStats[CHUDMarineComm]["ammopack"].hits = CHUDCommStats[CHUDMarineComm]["ammopack"].hits + 1
			CHUDCommStats[CHUDMarineComm]["ammopack"].refilled = CHUDCommStats[CHUDMarineComm]["ammopack"].refilled + newAmmo - oldAmmo
		end
	
	end)
	
local originalCatPackOnTouch
originalCatPackOnTouch = Class_ReplaceMethod("CatPack", "OnTouch",
	function(self, recipient)
	
		originalCatPackOnTouch(self, recipient)
		CHUDCommStats[CHUDMarineComm]["catpack"].misses = CHUDCommStats[CHUDMarineComm]["catpack"].misses - 1
		CHUDCommStats[CHUDMarineComm]["catpack"].hits = CHUDCommStats[CHUDMarineComm]["catpack"].hits + 1
	
	end)
	
local originalNS2GamerulesEndGame
originalNS2GamerulesEndGame = Class_ReplaceMethod("NS2Gamerules", "EndGame",
	function(self, winningTeam)
	
		originalNS2GamerulesEndGame(self, winningTeam)
		
		for index, _ in pairs(CHUDCommStats) do
			for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
			
				if playerInfo.steamId == index then
					local client = Server.GetClientById(playerInfo.clientId)
						if client then
							for index, stats in pairs(CHUDCommStats[index]) do
								if stats.hits > 0 or stats.misses > 0 then
									CHUDServerAdminPrint(client, "-------------------------------------")
									CHUDServerAdminPrint(client, string.upper(index) .. " STATS")
									CHUDServerAdminPrint(client, "-------------------------------------")
									
									local refilledtext
									local cost = 0
									
									if index == "medpack" then
										local accuracy = (stats.hits/(stats.hits+stats.misses))*100 or 0
										CHUDServerAdminPrint(client, string.format("Accuracy: %.2f%%", accuracy))
										refilledtext = "Amount healed: "
										cost = kMedPackCost
									elseif index == "ammopack" then
										refilledtext = "Bullets refilled: "
										cost = kAmmoPackCost
									elseif index == "catpack" then
										cost = kCatPackCost
									end
									
									if refilledtext then
										CHUDServerAdminPrint(client, refilledtext .. stats.refilled)
									end
									
									local hits = ConditionalValue(index == "medpack", stats.picks, stats.hits)
									local efficiency = (hits/(hits+stats.misses))*100 or 0
									CHUDServerAdminPrint(client, "Res spent on used " .. index .. "s: " .. hits*cost)
									CHUDServerAdminPrint(client, "Res spent on expired " .. index .. "s: " .. stats.misses*cost)
									CHUDServerAdminPrint(client, string.format("Res efficiency: %.2f%%", efficiency))
								end
							end
						end
					break
				end
			
			end
		end
		
	end)