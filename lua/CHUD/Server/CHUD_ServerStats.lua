local mapnameToWeaponStatsLookup =
{
	[Spit.kMapName] = kTechId.Spit,
	[Grenade.kMapName] = kTechId.GrenadeLauncher,
	[Flame.kMapName] = kTechId.Flamethrower,
	[ClusterGrenade.kMapName] = kTechId.ClusterGrenade,
	[ClusterFragment.kMapName] = kTechId.ClusterGrenade,
	[NerveGasCloud.kMapName] = kTechId.GasGrenade,
	[PulseGrenade.kMapName] = kTechId.PulseGrenadeProjectile,
	[SporeCloud.kMapName] = kTechId.Spores,
	[Shockwave.kMapName] = kTechId.Stomp,
	[DotMarker.kMapName] = kTechId.BileBomb,
	[WhipBomb.kMapName] = kTechId.Whip,
}

local dmgMsgQ = {}
local CHUDClientStats = {}

// Function name 2 stronk
local function MaybeInitCHUDClientStats(steamId, wTechId, teamNumber)
	if not CHUDClientStats[steamId] or (teamNumber ~= nil and CHUDClientStats[steamId].teamNumber ~= teamNumber) then
		CHUDClientStats[steamId] = {}
		CHUDClientStats[steamId].pdmg = 0
		CHUDClientStats[steamId].sdmg = 0
		CHUDClientStats[steamId].teamNumber = teamNumber
		CHUDClientStats[steamId]["last"] = {}
		CHUDClientStats[steamId]["last"].pdmg = 0
		CHUDClientStats[steamId]["last"].sdmg = 0
		CHUDClientStats[steamId]["last"].hits = 0
		CHUDClientStats[steamId]["last"].misses = 0
		CHUDClientStats[steamId]["weapons"] = {}
	end
	
	if wTechId and not CHUDClientStats[steamId]["weapons"][wTechId] then
		CHUDClientStats[steamId]["weapons"][wTechId] = {}
		CHUDClientStats[steamId]["weapons"][wTechId].hits = 0
		CHUDClientStats[steamId]["weapons"][wTechId].onosHits = 0
		CHUDClientStats[steamId]["weapons"][wTechId].misses = 0
	end
end

local function ResetCHUDLastLifeStats(steamId)
	MaybeInitCHUDClientStats(steamId)
	
	CHUDClientStats[steamId]["last"] = {}
	CHUDClientStats[steamId]["last"].pdmg = 0
	CHUDClientStats[steamId]["last"].sdmg = 0
	CHUDClientStats[steamId]["last"].hits = 0
	CHUDClientStats[steamId]["last"].misses = 0
end

local function AddAccuracyStat(steamId, wTechId, wasHit, isOnos, teamNumber)
	if GetGamerules():GetGameStarted() then
		MaybeInitCHUDClientStats(steamId, wTechId, teamNumber)
		
		local stat = CHUDClientStats[steamId]["weapons"][wTechId]
		local lastStat = CHUDClientStats[steamId]["last"]
		
		if wasHit then
			stat.hits = stat.hits + 1
			lastStat.hits = lastStat.hits + 1
			if isOnos then
				stat.onosHits = stat.onosHits + 1
			end
		else
			stat.misses = stat.misses + 1
			lastStat.misses = lastStat.misses + 1
		end
	end
end

local function AddDamageStat(steamId, damage, isPlayer)
	if GetGamerules():GetGameStarted() then
		MaybeInitCHUDClientStats(steamId)
		
		local stat = CHUDClientStats[steamId]
		local lastStat = CHUDClientStats[steamId]["last"]
		
		if isPlayer then
			stat.pdmg = stat.pdmg + damage
			lastStat.pdmg = lastStat.pdmg + damage
		else
			stat.sdmg = stat.sdmg + damage
			lastStat.sdmg = lastStat.sdmg + damage
		end
	end
end

function CHUD_CHUDDamageMessage_Queue( target, name, data, reliable, only_accum )
	-- Try to accumulate
	local msg
	for i=1,#dmgMsgQ do
		
		msg = dmgMsgQ[i]
			
		if  msg.name == name and 
			msg.target == target and 
			msg.reliable == reliable and
			msg.data.targetId == data.targetId and
			( name ~= "CHUDDamage2" or msg.data.mode == data.mode ) 
		then
			msg.data.posx = data.posx
			msg.data.posy = data.posy
			msg.data.posz = data.posz
			msg.data.amount = math.min( msg.data.amount + data.amount, kCHUDDamageMaxDamage )
			if name == "CHUDDamage" then
				msg.data.overkill = math.min( msg.data.overkill + data.overkill, kCHUDDamageMaxDamage )
			--	msg.saved = ( msg.saved or 0 ) + 16 
			elseif name == "CHUDDamage2" then
				msg.data.overkill = math.min( msg.data.overkill + data.overkill, kCHUDDamageMaxDamage )
				msg.data.hitcount = math.min( msg.data.hitcount + 1, kCHUDDamage2MessageMaxHitCount )
			--	msg.saved = ( msg.saved or 0 ) + 18
			else
			--	msg.saved = ( msg.saved or 0 ) + 12
			end
			
			return
		end
		
	end
	
	-- Nothing to accumulate, add new to queue
	if not only_accum then
		dmgMsgQ[#dmgMsgQ+1] = 
		{
			target = target;
			name = name;
			data = data;
			reliable = reliable;
		}
	else
	--	EPrint( "Skipping event '%s' saved %d bytes", name, 16 )
	end
end

function CHUD_CHUDDamageMessage_Dispatch()
	local msg
	for i=1,#dmgMsgQ do
		msg = dmgMsgQ[i]
		Server.SendNetworkMessage( msg.target, msg.name, msg.data, msg.reliable )
		if msg.saved then
		--	EPrint( "Accumulating event '%s' saved %d bytes", msg.name, msg.saved )
		end
	end
	dmgMsgQ = {}
end	

Event.Hook("UpdateServer", CHUD_CHUDDamageMessage_Dispatch)

function DamageMixin:DoDamage(damage, target, point, direction, surface, altMode, showtracer)

	if Shine then
		Shine.Hook.Call( "OnDamageDealt", self, damage, target, point, direction, surface, altMode, showtracer )
	end
	
	// No prediction if the Client is spectating another player.
	if Client and not Client.GetIsControllingPlayer() then
		return false
	end

	local killedFromDamage = false
	local doer = self
	local weapon

	// attacker is always a player, doer is 'self'
	local attacker = nil
	local parentVortexed = false

	if target and target:isa("Ragdoll") then
		return false
	end

	if self:isa("Player") then
		attacker = self
	else

		if self:GetParent() and self:GetParent():isa("Player") then
			attacker = self:GetParent()
			parentVortexed = GetIsVortexed(attacker)

			// CHUD_Stats: Get weapon player is holding
			weapon = self:GetTechId()

		elseif HasMixin(self, "Owner") and self:GetOwner() and self:GetOwner():isa("Player") then
			attacker = self:GetOwner()

			// CHUD_Stats: Map to their proper weapons so we don't need to perform voodoo magic
			weapon = 
			mapnameToWeaponStatsLookup[ self:GetMapName() ] or
			self.techId ~= nil and self.techId > 1 and self:GetTechId() or
			1

		end  

	end

	// CHUD_Stats: Secondary attack on alien weapons (lerk spikes, gorge healspray)
	if (self.secondaryAttacking or self.shootingSpikes) and attacker:isa("Alien") then
		weapon = attacker:GetActiveWeapon():GetSecondaryTechId()
	end

	if not attacker then
		attacker = doer
	end

	if attacker then

		// Get damage type from source
		local damageType = kDamageType.Normal
		if self.GetDamageType then
			damageType = self:GetDamageType()
		elseif HasMixin(self, "Tech") then
			damageType = LookupTechData(self:GetTechId(), kTechDataDamageType, kDamageType.Normal)
		end

		local armorUsed = 0
		local healthUsed = 0
		local damageDone = 0

		if target and HasMixin(target, "Live") and damage > 0 then  

			damage, armorUsed, healthUsed = GetDamageByType(target, attacker, doer, damage, damageType, point)

			// check once the damage
			if not direction then
				direction = Vector(0, 0, 1)
			end

			killedFromDamage, damageDone = target:TakeDamage(damage, attacker, doer, point, direction, armorUsed, healthUsed, damageType)

			if damage > 0 then

				// Many types of damage events are server-only, such as grenades.
				// Send the player a message so they get feedback about what damage they've done.
				// We use messages to handle multiple-hits per frame, such as splash damage from grenades.
				if Server and attacker:isa("Player") then

					if GetAreEnemies( attacker, target ) then
						
						local steamId = GetSteamIdForClientIndex(attacker:GetClientIndex())
						if steamId and not (target:isa("Hallucination") or target.isHallucination) then
							AddDamageStat(steamId, damageDone or 0, target:isa("Player"))
						end

						local amount = (target:GetIsAlive() or killedFromDamage) and damageDone or 0
						local overkill = healthUsed + armorUsed * 2
						
						if kCHUDStatsTrackAccLookup[weapon] then
							local msg = BuildCHUDDamage2Message( target, amount, point, overkill, weapon )
							CHUD_CHUDDamageMessage_Queue( attacker, "CHUDDamage2", msg, true )
						else
							local msg = BuildCHUDDamageMessage( target, amount, point, overkill )
							CHUD_CHUDDamageMessage_Queue( attacker, "CHUDDamage", msg, true, amount == 0 )
						end	

						local msg = BuildCHUDDamageMessage( target, amount, point, overkill )
						for _, spectator in ientitylist(Shared.GetEntitiesWithClassname("Spectator")) do

							if attacker == Server.GetOwner(spectator):GetSpectatingPlayer() then
								CHUD_CHUDDamageMessage_Queue( spectator, "CHUDDamage", msg, false, amount == 0 )
							end

						end
					end

					// This makes the cross hair turn red. Show it when hitting enemies only
					if (not doer.GetShowHitIndicator or doer:GetShowHitIndicator()) and GetAreEnemies(attacker, target) then
						attacker.giveDamageTime = Shared.GetTime()
					end

				end

				if self.OnDamageDone then
					self:OnDamageDone(doer, target)
				end

				if attacker and attacker.OnDamageDone then
					attacker:OnDamageDone(doer, target)
				end

			end

		end

		// trigger damage effects (damage, deflect) with correct surface
		if surface ~= "none" then

			local armorMultiplier = ConditionalValue(damageType == kDamageType.Light, 4, 2)
			armorMultiplier = ConditionalValue(damageType == kDamageType.Heavy, 1, armorMultiplier)

			local playArmorEffect = armorUsed * armorMultiplier > healthUsed

			if parentVortexed or GetIsVortexed(self) or GetIsVortexed(target) then            
				surface = "ethereal"

			elseif HasMixin(target, "NanoShieldAble") and target:GetIsNanoShielded() then    
				surface = "nanoshield"

			elseif HasMixin(target, "Fire") and target:GetIsOnFire() then
				surface = "flame"

			elseif not target then

				if GetIsPointOnInfestation(point) then
					surface = "infestation"
				end

				if not surface or surface == "" then
					surface = "metal"
				end

			elseif not surface or surface == "" then

				surface = GetIsAlienUnit(target) and "organic" or "metal"

				// define metal_thin, rock, or other
				if target.GetSurfaceOverride then
					surface = target:GetSurfaceOverride(damageDone) or surface

					if surface == "none" then
						return killedFromDamage
					end

				elseif GetAreEnemies(self, target) then

					if target:isa("Alien") then
						surface = "organic"
					elseif target:isa("Marine") then
						surface = "flesh"
					else

						if HasMixin(target, "Team") then

							if target:GetTeamType() == kAlienTeamType then
								surface = "organic"
							else
								surface = "metal"
							end

						end

					end

				end

			end

			// send to all players in range, except to attacking player, he will predict the hit effect
			if Server then

				if GetShouldSendHitEffect() then

					local directionVectorIndex = 1
					if direction then
						directionVectorIndex = GetIndexFromVector(direction)
					end

					local message = BuildHitEffectMessage(point, doer, surface, target, showtracer, altMode, damage, directionVectorIndex)

					local toPlayers = GetEntitiesWithinRange("Player", point, kHitEffectRelevancyDistance)                    
					for _, spectator in ientitylist(Shared.GetEntitiesWithClassname("Spectator")) do

						if table.contains(toPlayers, Server.GetOwner(spectator):GetSpectatingPlayer()) then
							table.insertunique(toPlayers, spectator)
						end

					end

					-- No need to send to the attacker if this is a child of the attacker.
					-- Children such as weapons are simulated on the Client as well so they will
					-- already see the hit effect.
					if attacker and self:GetParent() == attacker then
						table.removevalue(toPlayers, attacker)
					end

					for _, player in ipairs(toPlayers) do
						Server.SendNetworkMessage(player, "HitEffect", message, false) 
					end

				end

			elseif Client then

				HandleHitEffect(point, doer, surface, target, showtracer, altMode, damage, direction)

				// If we are far away from our target, trigger a private sound so we can hear we hit something
				if target then

					if (point - attacker:GetOrigin()):GetLength() > 5 then
						attacker:TriggerEffects("hit_effect_local")
					end

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

	CHUDCommStats = {}
	CHUDClientStats = {}
	
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
		
		for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
			local client = Server.GetClientById(playerInfo.clientId)
			
			// Player stats
			if CHUDClientStats[playerInfo.steamId] and client then
				local stats = CHUDClientStats[playerInfo.steamId]
				
				local overallAccuracy = 0
				local overallOnosAccuracy = -1
				local overallHits = 0
				local overallMisses = 0
				local overallOnosHits = 0

				for wTechId, wStats in pairs(stats["weapons"]) do
					local accuracy = 0
					local accuracyOnos = ConditionalValue(wStats.onosHits == 0, -1, 0)
					
					overallHits = overallHits + wStats.hits
					overallMisses = overallMisses + wStats.misses
					overallOnosHits = overallOnosHits + wStats.onosHits
					
					if wStats.hits > 0 or wStats.misses > 0 then
						accuracy = wStats.hits/(wStats.hits+wStats.misses)*100
						if wStats.onosHits > 0 and wStats.hits ~= wStats.onosHits then
							accuracyOnos = (wStats.hits-wStats.onosHits)/((wStats.hits-wStats.onosHits)+wStats.misses)*100
						end
					end
					
					local msg = {}
					msg.wTechId = wTechId
					msg.accuracy = accuracy
					msg.accuracyOnos = accuracyOnos
					
					Server.SendNetworkMessage(client, "CHUDEndStatsWeapon", msg, true)
				end
				
				if overallHits > 0 or overallMisses > 0 then
					overallAccuracy = overallHits/(overallHits+overallMisses)*100
					if overallOnosHits > 0 and overallHits ~= overallOnosHits then
						overallOnosAccuracy = (overallHits-overallOnosHits)/((overallHits-overallOnosHits)+overallMisses)*100
					end
				end
				
				local msg = {}
				msg.accuracy = overallAccuracy
				msg.accuracyOnos = overallOnosAccuracy
				msg.pdmg = stats.pdmg
				msg.sdmg = stats.sdmg
				
				Server.SendNetworkMessage(client, "CHUDEndStatsOverall", msg, true)
			end
			
			// Commander stats
			if CHUDCommStats[playerInfo.steamId] and client then
				for index, stats in pairs(CHUDCommStats[playerInfo.steamId]) do
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
		
		end
		
	end)

local originalPlayerOnKill
originalPlayerOnKill = Class_ReplaceMethod("Player", "OnKill",
	function (self, killer, doer, point, direction)
		originalPlayerOnKill(self, killer, doer, point, direction)
		
		local steamId = GetSteamIdForClientIndex(self:GetClientIndex())
		if steamId then
			if CHUDClientStats[steamId] then
				local lastStat = CHUDClientStats[steamId]["last"]
				local totalStats = CHUDClientStats[steamId]["weapons"]
				local msg = {}
				local lastAcc = 0
				local currentAcc = 0
				local hitssum = 0
				local missessum = 0
				
				for _, wStats in pairs(totalStats) do
					hitssum = hitssum + wStats.hits
					missessum = missessum + wStats.misses
				end
				
				if lastStat.hits > 0 or lastStat.misses > 0 then
					lastAcc = lastStat.hits/(lastStat.hits+lastStat.misses)*100
				end
				
				if hitssum > 0 or missessum > 0 then
					currentAcc = hitssum/(hitssum+missessum)*100
				end
				
				if lastStat.hits > 0 or lastStat.misses > 0 or lastStat.pdmg > 0 or lastStat.sdmg > 0 then
					msg.lastAcc = lastAcc
					msg.currentAcc = currentAcc
					msg.pdmg = lastStat.pdmg
					msg.sdmg = lastStat.sdmg
					
					Server.SendNetworkMessage(Server.GetOwner(self), "CHUDDeathStats", msg, true)
				end
			end
			ResetCHUDLastLifeStats(steamId)
		end
		
		// Save position of last death only if we didn't die to a DeathTrigger
		// Also save if the player killed himself
		if (killer and not killer:isa("DeathTrigger")) or (doer and not doer:isa("DeathTrigger")) or (not killer and not doer) then
			self.lastDeathPos = self:GetOrigin()
		end
		
		self.lastClass = self:GetMapName()
		
	end)

-- Make FireMixin use the message accumulation stuff

function LiveMixin:DeductHealth(damage, attacker, doer, healthOnly, armorOnly, preventAlert)

    local armorUsed = 0
    local healthUsed = damage
    
    if self.healthIgnored or armorOnly then
    
        armorUsed = damage
        healthUsed = 0
        
    elseif not healthOnly then
    
        armorUsed = math.min(self:GetArmor() * kHealthPointsPerArmor, (damage * kBaseArmorUseFraction) / kHealthPointsPerArmor )
        healthUsed = healthUsed - armorUsed
        
    end

    local engagePoint = HasMixin(self, "Target") and self:GetEngagementPoint() or self:GetOrigin()
    return self:TakeDamage(damage, attacker, doer, engagePoint, nil, armorUsed, healthUsed, kDamageType.Normal, preventAlert)
    
end


local kBurnUpdateRate
local function NewFireMixinSharedUpdate(self, deltaTime)

    if Client then
        UpdateFireMaterial(self)
        self:_UpdateClientFireEffects()
    end

    if not self:GetIsOnFire() then
        return
    end
    
    if Server then
    
        if self:GetIsAlive() and (not self.timeLastFireDamageUpdate or self.timeLastFireDamageUpdate + kBurnUpdateRate <= Shared.GetTime()) then
    
            local damageOverTime = kBurnUpdateRate * kBurnDamagePerSecond
            if self.GetIsFlameAble and self:GetIsFlameAble() then
                damageOverTime = damageOverTime * kFlameableMultiplier
            end
            
            local attacker = nil
            if self.fireAttackerId ~= Entity.invalidId then
                attacker = Shared.GetEntity(self.fireAttackerId)
            end

            local doer = nil
            if self.fireDoerId ~= Entity.invalidId then
                doer = Shared.GetEntity(self.fireDoerId)
            end
            
            local killedFromDamage, damageDone = self:DeductHealth(damageOverTime, attacker, doer)

            if attacker then
            
                local msg = BuildCHUDDamageMessage(self, damageDone, self:GetOrigin(), damageOverTime)
                CHUD_CHUDDamageMessage_Queue(attacker, "CHUDDamage", msg, false)
                
                for _, spectator in ientitylist(Shared.GetEntitiesWithClassname("Spectator")) do
                
                    if attacker == Server.GetOwner(spectator):GetSpectatingPlayer() then
                        CHUD_CHUDDamageMessage_Queue(spectator, "CHUDDamage", msg, false)
                    end
                    
                end
            
            end
            
            self.timeLastFireDamageUpdate = Shared.GetTime()
            
        end
        
        // See if we put ourselves out
        if Shared.GetTime() - self.timeBurnInit > kFlamethrowerBurnDuration then
            self:SetGameEffectMask(kGameEffect.OnFire, false)
        end
        
    end
    
end
ReplaceUpValue( FireMixin.OnUpdate, "SharedUpdate", NewFireMixinSharedUpdate, { LocateRecurse = true; CopyUpValues = true; } )


-- Make poison show damage numbers	
local oldPlayerOnProcessMove
oldPlayerOnProcessMove = Class_ReplaceMethod( "Player", "OnProcessMove",
	function( self, input )
		oldPlayerOnProcessMove( self, input )
		CHUD_CHUDDamageMessage_Dispatch()
	end)


local oldMarineOnProcessMove = Marine.OnProcessMove
function Marine:OnProcessMove(input)
	local oldDeductHealth = self.DeductHealth 
	self.DeductHealth =  
		function ( self, damage, attacker, doer, healthOnly )
				
			oldDeductHealth( self, damage, attacker, doer, healthOnly )
			
			if attacker then
				local msg = BuildCHUDDamageMessage(self, damage, self:GetOrigin(), damage)
				CHUD_CHUDDamageMessage_Queue(attacker, "CHUDDamage", msg, true )
				
				for _, spectator in ientitylist(Shared.GetEntitiesWithClassname("Spectator")) do
				
					if attacker == Server.GetOwner(spectator):GetSpectatingPlayer() then
						CHUD_CHUDDamageMessage_Queue(spectator, "CHUDDamage", msg, false )
					end
					
				end
			end
			
		end

	oldMarineOnProcessMove( self, input )
	
	self.DeductHealth = oldDeductHealth
	
end

// Attack counters for every single fucking thing in the game
// ClipWeapon covers FT, GL, pistol, rifle and SG
local originalClipWeaponFirePrimary
originalClipWeaponFirePrimary = Class_ReplaceMethod( "ClipWeapon", "FirePrimary",
	function(self, player)
		PROFILE("FireBullets")

		local viewAngles = player:GetViewAngles()
		local shootCoords = viewAngles:GetCoords()
		
		// Filter ourself out of the trace so that we don't hit ourselves.
		local filter = EntityFilterTwo(player, self)
		local range = self:GetRange()
		
		if GetIsVortexed(player) then
			range = 5
		end
		
		local numberBullets = self:GetBulletsPerShot()
		local startPoint = player:GetEyePos()
		local bulletSize = self:GetBulletSize()
		
		for bullet = 1, numberBullets do
		
			local spreadDirection = self:CalculateSpreadDirection(shootCoords, player)
			
			local endPoint = startPoint + spreadDirection * range
			local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, bulletSize, filter)        
			local damage = self:GetBulletDamage()

			/*
			// Check prediction
			local values = GetPredictionValues(startPoint, endPoint, trace)
			if not CheckPredictionData( string.format("attack%d", bullet), true, values ) then
				Server.PlayPrivateSound(player, "sound/NS2.fev/marine/voiceovers/game_start", player, 1.0, Vector(0, 0, 0))
			end
			*/

			local direction = (trace.endPoint - startPoint):GetUnit()
			local hitOffset = direction * kHitEffectOffset
			local impactPoint = trace.endPoint - hitOffset
			local effectFrequency = self:GetTracerEffectFrequency()
			local showTracer = math.random() < effectFrequency

			local numTargets = #targets
			
			if numTargets == 0 then
				self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
				local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
				if steamId then
					AddAccuracyStat(steamId, self:GetTechId(), false, nil, self:GetParent():GetTeamNumber())
				end
			end
			
			if Client and showTracer then
				TriggerFirstPersonTracer(self, impactPoint)
			end
			
			local isPlayer = false
			local statsTarget = nil
			
			for i = 1, numTargets do

				local target = targets[i]
				local hitPoint = hitPoints[i]
				
				if target and target:isa("Player") then
					isPlayer = true
					// In theory ClipWeapon can only hit a single player target at a time
					statsTarget = target
				end

				self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, damage, "", showTracer and i == numTargets)
				
				local client = Server and player:GetClient() or Client
				if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
					RegisterHitEvent(player, bullet, startPoint, trace, damage)
				end
			
			end

			// Drifters, buildings and teammates don't count towards accuracy as hits or misses
			if isPlayer and GetAreEnemies(self:GetParent(), statsTarget) then
				local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
				if steamId then
					AddAccuracyStat(steamId, self:GetTechId(), true, statsTarget and statsTarget:isa("Onos"), self:GetParent():GetTeamNumber())
				end
			end
			
		end
	end)

local originalShotgunFirePrimary, kSpreadVectors, kStartOffset, kBulletSize
originalShotgunFirePrimary = Class_ReplaceMethod( "Shotgun", "FirePrimary",
	function(self, player)
		local viewAngles = player:GetViewAngles()
		viewAngles.roll = NetworkRandom() * math.pi * 2

		local shootCoords = viewAngles:GetCoords()

		// Filter ourself out of the trace so that we don't hit ourselves.
		local filter = EntityFilterTwo(player, self)
		local range = self:GetRange()
		
		if GetIsVortexed(player) then
			range = 5
		end
		
		local numberBullets = self:GetBulletsPerShot()
		local startPoint = player:GetEyePos()
		
		self:TriggerEffects("shotgun_attack_sound")
		self:TriggerEffects("shotgun_attack")
		
		for bullet = 1, math.min(numberBullets, #kSpreadVectors) do
		
			if not kSpreadVectors[bullet] then
				break
			end    
		
			local spreadDirection = shootCoords:TransformVector(kSpreadVectors[bullet])

			local endPoint = startPoint + spreadDirection * range
			startPoint = player:GetEyePos() + shootCoords.xAxis * kSpreadVectors[bullet].x * kStartOffset + shootCoords.yAxis * kSpreadVectors[bullet].y * kStartOffset
			
			local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, kBulletSize, filter)
			
			local damage = 0

			/*
			// Check prediction
			local values = GetPredictionValues(startPoint, endPoint, trace)
			if not CheckPredictionData( string.format("attack%d", bullet), true, values ) then
				Server.PlayPrivateSound(player, "sound/NS2.fev/marine/voiceovers/game_start", player, 1.0, Vector(0, 0, 0))
			end
			*/
				
			local direction = (trace.endPoint - startPoint):GetUnit()
			local hitOffset = direction * kHitEffectOffset
			local impactPoint = trace.endPoint - hitOffset
			local effectFrequency = self:GetTracerEffectFrequency()
			local showTracer = bullet % effectFrequency == 0
			
			local numTargets = #targets
			
			if numTargets == 0 then
				self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
				local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
				if steamId then
					AddAccuracyStat(steamId, self:GetTechId(), false, nil, self:GetParent():GetTeamNumber())
				end
			end
			
			if Client and showTracer then
				TriggerFirstPersonTracer(self, impactPoint)
			end

			local isPlayer = false
			local statsTarget = nil

			for i = 1, numTargets do

				local target = targets[i]
				local hitPoint = hitPoints[i]
				
				if target and target:isa("Player") then
					isPlayer = true
					// In theory ClipWeapon can only hit a single player target at a time
					statsTarget = target
				end

				self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, kShotgunDamage, "", showTracer and i == numTargets)
				
				local client = Server and player:GetClient() or Client
				if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
					RegisterHitEvent(player, bullet, startPoint, trace, damage)
				end
			
			end
			
			// Drifters, buildings and teammates don't count towards accuracy as hits or misses
			if isPlayer and GetAreEnemies(self:GetParent(), statsTarget) then
				local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
				if steamId then
					AddAccuracyStat(steamId, self:GetTechId(), true, statsTarget and statsTarget:isa("Onos"), self:GetParent():GetTeamNumber())
				end
			end
			
		end
		
		TEST_EVENT("Shotgun primary attack")
	end)
CopyUpValues( Shotgun.FirePrimary, originalShotgunFirePrimary )
	
local originalRiflebuttAttack, kButtRange
originalRiflebuttAttack = Class_ReplaceMethod( "Rifle", "PerformMeleeAttack",
	function(self, player)
		player:TriggerEffects("rifle_alt_attack")
		
		local _, target = AttackMeleeCapsule(self, player, kRifleMeleeDamage, kButtRange, nil, true)
		
		if (target and target:isa("Player") and GetAreEnemies(self:GetParent(), target)) or target == nil then
			local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
			if steamId then
				AddAccuracyStat(steamId, self:GetTechId(), target ~= nil, target and target:isa("Onos"), self:GetParent():GetTeamNumber())
			end
		end
	end)
CopyUpValues( Rifle.PerformMeleeAttack, originalRiflebuttAttack )

local originalAxeOnTag
originalAxeOnTag = Class_ReplaceMethod( "Axe", "OnTag",
	function(self, tagName)
		if tagName == "hit" then
			local player = self:GetParent()
			
			if player then
				local _, target = AttackMeleeCapsule(self, player, kAxeDamage, self:GetRange())
				
				if (target and target:isa("Player") and GetAreEnemies(self:GetParent(), target)) or target == nil then
					local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
					if steamId then
						AddAccuracyStat(steamId, self:GetTechId(), target ~= nil, target and target:isa("Onos"), self:GetParent():GetTeamNumber())
					end
				end
			end
		else
			originalAxeOnTag(self, tagName)
		end
	end)

local originalClawOnTag, kClawRange
originalClawOnTag = Class_ReplaceMethod( "Claw", "OnTag",
	function(self, tagName)
		if tagName == "hit" then
			local player = self:GetParent()
			if player then
				local _, target = AttackMeleeCapsule(self, player, kClawDamage, kClawRange)
				
				if (target and target:isa("Player") and GetAreEnemies(self:GetParent(), target)) or target == nil then
					local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
					if steamId then
						AddAccuracyStat(steamId, self:GetTechId(), target ~= nil, target and target:isa("Onos"), self:GetParent():GetTeamNumber())
					end
				end
			end
		else
			originalClawOnTag(self, tagName)
		end
	end)
CopyUpValues( Claw.OnTag, originalClawOnTag )

local kMinigunSpread, kMinigunRange, kBulletSize
local function NewMinigunShoot(self, leftSide)
	
		local player = self:GetParent()
		
		// We can get a shoot tag even when the clip is empty if the frame rate is low
		// and the animation loops before we have time to change the state.
		if self.minigunAttacking and player then
		
			if Server and not self.spinSound:GetIsPlaying() then
				self.spinSound:Start()
			end    
		
			local viewAngles = player:GetViewAngles()
			local shootCoords = viewAngles:GetCoords()
			
			// Filter ourself out of the trace so that we don't hit ourselves.
			local filter = EntityFilterTwo(player, self)
			local startPoint = player:GetEyePos()
			
			local spreadDirection = CalculateSpread(shootCoords, kMinigunSpread, NetworkRandom)
			
			local range = kMinigunRange
			if GetIsVortexed(player) then
				range = 5
			end
			
			local endPoint = startPoint + spreadDirection * range
			
			local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, kBulletSize, filter) 
			
			local direction = (trace.endPoint - startPoint):GetUnit()
			local hitOffset = direction * kHitEffectOffset
			local impactPoint = trace.endPoint - hitOffset
			local surfaceName = trace.surface
			local effectFrequency = self:GetTracerEffectFrequency()
			local showTracer = ConditionalValue(GetIsVortexed(player), false, math.random() < effectFrequency)
			
			local numTargets = #targets
			
			if numTargets == 0 then
				self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
				local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
				if steamId then
					AddAccuracyStat(steamId, self:GetTechId(), false, nil, self:GetParent():GetTeamNumber())
				end
			end
			
			if Client and showTracer then
				TriggerFirstPersonTracer(self, trace.endPoint)
			end
			
			local isPlayer = false
			local statsTarget = nil
			
			for i = 1, numTargets do

				local target = targets[i]
				local hitPoint = hitPoints[i]
				
				if target and target:isa("Player") then
					isPlayer = true
					// In theory ClipWeapon can only hit a single player target at a time
					statsTarget = target
				end

				self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, kMinigunDamage, "", showTracer and i == numTargets)
				
				local client = Server and player:GetClient() or Client
				if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
					RegisterHitEvent(player, bullet, startPoint, trace, damage)
				end
			
			end

			// Drifters, buildings and teammates don't count towards accuracy as hits or misses
			if isPlayer and GetAreEnemies(self:GetParent(), statsTarget) then
				local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
				if steamId then
					AddAccuracyStat(steamId, self:GetTechId(), true, statsTarget and statsTarget:isa("Onos"), self:GetParent():GetTeamNumber())
				end
			end
			
			self.shooting = true
			
		end
		
end
ReplaceUpValue(Minigun.OnTag, "Shoot", NewMinigunShoot, { LocateRecurse = true; CopyUpValues = true; })

local kChargeTime, kBulletSize
local function NewExecuteShot(self, startPoint, endPoint, player)
	// Filter ourself out of the trace so that we don't hit ourselves.
	local filter = EntityFilterTwo(player, self)
	local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))
	local hitPointOffset = trace.normal * 0.3
	local direction = (endPoint - startPoint):GetUnit()
	local damage = kRailgunDamage + math.min(1, (Shared.GetTime() - self.timeChargeStarted) / kChargeTime) * kRailgunChargeDamage
	
	local extents = GetDirectedExtentsForDiameter(direction, kBulletSize)
	
	if trace.fraction < 1 then
	
		// do a max of 10 capsule traces, should be sufficient
		local hitEntities = {}
		local isPlayer = false
		local playerTargets = 0
		local foundOnos = false
		
		for i = 1, 20 do
		
			local capsuleTrace = Shared.TraceBox(extents, startPoint, trace.endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
			if capsuleTrace.entity then
			
				if not table.find(hitEntities, capsuleTrace.entity) then
				
					if capsuleTrace.entity:isa("Player") and GetAreEnemies(self:GetParent(), capsuleTrace.entity) then
						isPlayer = true
						playerTargets = playerTargets + 1
						if capsuleTrace.entity:isa("Onos") then
							foundOnos = true
						end
					end
				
					table.insert(hitEntities, capsuleTrace.entity)
					self:DoDamage(damage, capsuleTrace.entity, capsuleTrace.endPoint + hitPointOffset, direction, capsuleTrace.surface, false, false)
				
				end
				
			end    
				
			if (capsuleTrace.endPoint - trace.endPoint):GetLength() <= extents.x then
				break
			end
			
			// use new start point
			startPoint = Vector(capsuleTrace.endPoint) + direction * extents.x * 3
		
		end

		// Drifters, buildings and teammates don't count towards accuracy as hits or misses
		if #hitEntities == 0 or (#hitEntities > 0 and isPlayer) then
			local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
			if steamId then
				AddAccuracyStat(steamId, self:GetTechId(), #hitEntities > 0, playerTargets == 1 and foundOnos, self:GetParent():GetTeamNumber())
			end
		end
		
		// for tracer
		local effectFrequency = self:GetTracerEffectFrequency()
		local showTracer = ConditionalValue(GetIsVortexed(player), false, math.random() < effectFrequency)
		self:DoDamage(0, nil, trace.endPoint + hitPointOffset, direction, trace.surface, false, showTracer)
		
		if Client and showTracer then
			TriggerFirstPersonTracer(self, trace.endPoint)
		end
	
	end
end
ReplaceUpValue(Railgun.OnTag, "ExecuteShot", NewExecuteShot, { LocateRecurse = true; CopyUpValues = true; })

local originalBiteOnTag, kEnzymedRange, kRange
originalBiteOnTag = Class_ReplaceMethod( "BiteLeap", "OnTag",
	function(self, tagName)
		if tagName == "hit" then
			local player = self:GetParent()
			
			if player then
			
				local range = (player.GetIsEnzymed and player:GetIsEnzymed()) and kEnzymedRange or kRange
			
				local didHit, target, endPoint = AttackMeleeCapsule(self, player, kBiteDamage, range, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
				
				if (target and target:isa("Player") and GetAreEnemies(self:GetParent(), target)) or target == nil then
					local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
					if steamId then
						AddAccuracyStat(steamId, self:GetTechId(), target ~= nil, target and target:isa("Onos"), self:GetParent():GetTeamNumber())
					end
				end
				
				if Client and didHit then
					self:TriggerFirstPersonHitEffects(player, target)  
				end
				
				if target and HasMixin(target, "Live") and not target:GetIsAlive() then
					self:TriggerEffects("bite_kill")
				elseif Server and target and target.TriggerEffects and GetReceivesStructuralDamage(target) and (not HasMixin(target, "Live") or target:GetCanTakeDamage()) then
					target:TriggerEffects("bite_structure", {effecthostcoords = Coords.GetTranslation(endPoint), isalien = GetIsAlienUnit(target)})
				end
				
				player:DeductAbilityEnergy(self:GetEnergyCost())
				self:TriggerEffects("bite_attack")
				
			end
		else
			originalBiteOnTag(self, tagName)
		end
	end)
CopyUpValues( BiteLeap.OnTag, originalBiteOnTag )
	
local originalGoreAttack, GetGoreAttackRange
originalGoreAttack = Class_ReplaceMethod( "Gore", "Attack",
	function(self, player)
		local didHit = false
		local impactPoint = nil
		local target = nil
		local attackType = self.attackType
		
		if Server then
			attackType = self.lastAttackType
		end
		
		local range = GetGoreAttackRange(player:GetViewCoords())
		didHit, target, impactPoint = AttackMeleeCapsule(self, player, kGoreDamage, range)
		
		if (target and target:isa("Player") and GetAreEnemies(self:GetParent(), target)) or target == nil then
			local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
			if steamId then
				AddAccuracyStat(steamId, self:GetTechId(), target ~= nil, target and target:isa("Onos"), self:GetParent():GetTeamNumber())
			end
		end

		player:DeductAbilityEnergy(self:GetEnergyCost(player))
		
		return didHit, impactPoint, target
	end)
CopyUpValues( Gore.Attack, originalGoreAttack )
	
local originalLerkBiteOnTag, kRange
originalLerkBiteOnTag = Class_ReplaceMethod( "LerkBite", "OnTag",
	function(self, tagName)
		if tagName == "hit" then
			local player = self:GetParent()
			
			if player then  
			
				player:DeductAbilityEnergy(self:GetEnergyCost())            
				self:TriggerEffects("lerkbite_attack")
				
				self.spiked = false
			
				local didHit, target, endPoint, surface = AttackMeleeCapsule(self, player, kLerkBiteDamage, kRange, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
				
				if (target and target:isa("Player") and GetAreEnemies(self:GetParent(), target)) or target == nil then
					local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
					if steamId then
						AddAccuracyStat(steamId, self:GetTechId(), target ~= nil, target and target:isa("Onos"), self:GetParent():GetTeamNumber())
					end
				end
				
				if didHit and target then
				
					if Server then
						if not player.isHallucination and target:isa("Marine") and target:GetCanTakeDamage() then
							target:SetPoisoned(player)
						end
					elseif Client then
						self:TriggerFirstPersonHitEffects(player, target)
					end
				
				end
				
				if target and HasMixin(target, "Live") and not target:GetIsAlive() then
					self:TriggerEffects("bite_kill")
				end
				
			end
		else
			originalLerkBiteOnTag(self, tagName)
		end
	end)
CopyUpValues( LerkBite.OnTag, originalLerkBiteOnTag )
	
local originalParasiteAttack, kRange, kParasiteSize
originalParasiteAttack = Class_ReplaceMethod( "Parasite", "PerformPrimaryAttack",
	function(self, player)
		self.activity = Parasite.kActivity.Primary
		self.primaryAttacking = true
		
		local success = false

		if not self.blocked then
		
			self.blocked = true
			
			success = true
			
			self:TriggerEffects("parasite_attack")
			
			// Trace ahead to see if hit enemy player or structure

			local viewCoords = player:GetViewAngles():GetCoords()
			local startPoint = player:GetEyePos()
		
			// double trace; first as a ray to allow us to hit through narrow openings, then as a fat box if the first one misses
			local trace = Shared.TraceRay(startPoint, startPoint + viewCoords.zAxis * kRange, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
			if not trace.entity then
				local extents = GetDirectedExtentsForDiameter(viewCoords.zAxis, kParasiteSize)
				trace = Shared.TraceBox(extents, startPoint, startPoint + viewCoords.zAxis * kRange, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
			end
			
			if trace.fraction < 1 then
			
				local hitObject = trace.entity
				local direction = GetNormalizedVector(trace.endPoint - startPoint)
				local impactPoint = trace.endPoint - direction * kHitEffectOffset
				
				if (hitObject and hitObject:isa("Player") and GetAreEnemies(self:GetParent(), hitObject)) then
					local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
					if steamId then
						AddAccuracyStat(steamId, self:GetTechId(), true, hitObject and hitObject:isa("Onos"), self:GetParent():GetTeamNumber())
					end
				end
				
				self:DoDamage(kParasiteDamage, hitObject, impactPoint, direction)
				
			end
			
			if not trace.entity then
				local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
				if steamId then
					AddAccuracyStat(steamId, self:GetTechId(), false, nil, self:GetParent():GetTeamNumber())
				end
			end
			
		end
		
		return success
	end)
CopyUpValues( Parasite.PerformPrimaryAttack, originalParasiteAttack )
	
local kSpread, kSpikeSize
local function NewFireSpikes(self)
	local player = self:GetParent()    
	local viewAngles = player:GetViewAngles()
	viewAngles.roll = NetworkRandom() * math.pi * 2
	local shootCoords = viewAngles:GetCoords()
	
	// Filter ourself out of the trace so that we don't hit ourselves.
	local filter = EntityFilterOneAndIsa(player, "Babbler")
	local range = kSpikesRange
	
	local numSpikes = kSpikesPerShot
	local startPoint = player:GetEyePos()
	
	local viewCoords = player:GetViewCoords()
	
	self.spiked = true
	self.silenced = GetHasSilenceUpgrade(player)
	
	for spike = 1, numSpikes do

		// Calculate spread for each shot, in case they differ    
		local spreadDirection = CalculateSpread(viewCoords, kSpread, NetworkRandom) 

		local endPoint = startPoint + spreadDirection * range
		startPoint = player:GetEyePos()
		
		local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
		if not trace.entity then
			local extents = GetDirectedExtentsForDiameter(spreadDirection, kSpikeSize)
			trace = Shared.TraceBox(extents, startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
		end
		
		local distToTarget = (trace.endPoint - startPoint):GetLength()
		
		if trace.fraction < 1 then

			// Have damage increase to reward close combat
			local damageDistScalar = Clamp(1 - (distToTarget / kSpikeMinDamageRange), 0, 1)
			local damage = kSpikeMinDamage + damageDistScalar * (kSpikeMaxDamage - kSpikeMinDamage)
			local direction = (trace.endPoint - startPoint):GetUnit()
			
			if (trace.entity and trace.entity:isa("Player") and GetAreEnemies(self:GetParent(), trace.entity)) then
				local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
				if steamId then
					AddAccuracyStat(steamId, self:GetSecondaryTechId(), true, trace.entity and trace.entity:isa("Onos"), self:GetParent():GetTeamNumber())
				end
			end
			
			self:DoDamage(damage, trace.entity, trace.endPoint - direction * kHitEffectOffset, direction, trace.surface, true, math.random() < 0.75)
				
		end
		
		if not trace.entity then
			local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
			if steamId then
				AddAccuracyStat(steamId, self:GetSecondaryTechId(), false, nil, self:GetParent():GetTeamNumber())
			end
		end
		
	end
end
ReplaceUpValue(SpikesMixin.OnTag, "FireSpikes", NewFireSpikes, { LocateRecurse = true; CopyUpValues = true; })

local originalStabOnTag, kRange
originalStabOnTag = Class_ReplaceMethod( "StabBlink", "OnTag",
	function(self, tagName)
		if tagName == "hit" and self.stabbing then
			self:TriggerEffects("stab_hit")
			self.stabbing = false
		
			local player = self:GetParent()
			if player then

				local _, target = AttackMeleeCapsule(self, player, kStabDamage, kRange, nil, false, EntityFilterOneAndIsa(player, "Babbler"))            
				self:ConsumeVortex(player)
			
				if (target and target:isa("Player") and GetAreEnemies(self:GetParent(), target)) or target == nil then
					local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
					if steamId then
						AddAccuracyStat(steamId, self:GetTechId(), target ~= nil, target and target:isa("Onos"), self:GetParent():GetTeamNumber())
					end
				end
			
			end
		else
			originalStabOnTag(self, tagName)
		end
	end)
CopyUpValues( StabBlink.OnTag, originalStabOnTag )
	
local originalSwipeAttack
originalSwipeAttack = Class_ReplaceMethod( "SwipeBlink", "PerformMeleeAttack",
	function(self)
		local player = self:GetParent()

		if player then
			local _, target = AttackMeleeCapsule(self, player, SwipeBlink.kDamage, SwipeBlink.kRange, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
			
			if (target and target:isa("Player") and GetAreEnemies(self:GetParent(), target)) or target == nil then
				local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
				if steamId then
					AddAccuracyStat(steamId, self:GetTechId(), target ~= nil, target and target:isa("Onos"), self:GetParent():GetTeamNumber())
				end
			end
		end

	end)
