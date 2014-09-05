
local CHUDClientStats = {}

// Function name 2 stronk
local function MaybeInitCHUDClientStats(steamId, wTechId, teamNumber)
	if not CHUDClientStats[steamId] or (teamNumber ~= nil and CHUDClientStats[steamId].teamNumber ~= teamNumber) then
		CHUDClientStats[steamId] = {}
		CHUDClientStats[steamId].pdmg = 0
		CHUDClientStats[steamId].sdmg = 0
		CHUDClientStats[steamId].killstreak = 0
		CHUDClientStats[steamId].teamNumber = teamNumber
		CHUDClientStats[steamId]["last"] = {}
		CHUDClientStats[steamId]["last"].pdmg = 0
		CHUDClientStats[steamId]["last"].sdmg = 0
		CHUDClientStats[steamId]["last"].hits = 0
		CHUDClientStats[steamId]["last"].misses = 0
		CHUDClientStats[steamId]["last"].kills = 0
		CHUDClientStats[steamId]["weapons"] = {}
	end
	
	if wTechId and not CHUDClientStats[steamId]["weapons"][wTechId] then
		CHUDClientStats[steamId]["weapons"][wTechId] = {}
		CHUDClientStats[steamId]["weapons"][wTechId].hits = 0
		CHUDClientStats[steamId]["weapons"][wTechId].onosHits = 0
		CHUDClientStats[steamId]["weapons"][wTechId].misses = 0
		CHUDClientStats[steamId]["weapons"][wTechId].kills = 0
	end
end

local function ResetCHUDLastLifeStats(steamId)
	MaybeInitCHUDClientStats(steamId)
	
	CHUDClientStats[steamId]["last"] = {}
	CHUDClientStats[steamId]["last"].pdmg = 0
	CHUDClientStats[steamId]["last"].sdmg = 0
	CHUDClientStats[steamId]["last"].hits = 0
	CHUDClientStats[steamId]["last"].misses = 0
	CHUDClientStats[steamId]["last"].kills = 0
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

local function AddWeaponKill(steamId, wTechId, teamNumber)
	if GetGamerules():GetGameStarted() then
		MaybeInitCHUDClientStats(steamId, wTechId, teamNumber)
		
		local rootStat = CHUDClientStats[steamId]
		local weaponStat = CHUDClientStats[steamId]["weapons"][wTechId]
		local lastStat = CHUDClientStats[steamId]["last"]
		
		weaponStat.kills = weaponStat.kills + 1
		lastStat.kills = lastStat.kills + 1
		
		if lastStat.kills > rootStat.killstreak then
			rootStat.killstreak = lastStat.kills
		end
	end
end

local function OnSetCHUDOverkill(client, message)

	if client then
	
		local player = client:GetControllingPlayer()
		if player and message ~= nil then
			player.overkill = message.overkill
		end
		
	end
	
end

Server.HookNetworkMessage("SetCHUDOverkill", OnSetCHUDOverkill)

local oldSendDamageMessage = SendDamageMessage
function SendDamageMessage( attacker, target, amount, point, overkill )
		
	local steamId = GetSteamIdForClientIndex(attacker:GetClientIndex())
	if steamId then
		AddDamageStat(steamId, amount or 0, target and target:isa("Player") and not (target:isa("Hallucination") or target.isHallucination))
	end
	
	if attacker.overkill == true then
		amount = overkill
	end
	
	oldSendDamageMessage( attacker, target, amount, point, overkill )
	
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
			if ConditionalValue(self.expireTime == 0, Shared.GetTime(), self.expireTime - kItemStayTime) + 0.025 > Shared.GetTime() then
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
			
			// Commander stats
			if CHUDCommStats[playerInfo.steamId] and client then
				local msg = {}
				msg.medpackAccuracy = 0
				msg.medpackResUsed = 0
				msg.medpackResExpired = 0
				msg.medpackEfficiency = 0
				msg.medpackRefill = 0
				msg.ammopackResUsed = 0
				msg.ammopackResExpired = 0
				msg.ammopackEfficiency = 0
				msg.ammopackRefill = 0
				msg.catpackResUsed = 0
				msg.catpackResExpired = 0
				msg.catpackEfficiency = 0
				
				for index, stats in pairs(CHUDCommStats[playerInfo.steamId]) do
					if stats.hits > 0 or stats.misses > 0 then
						if index == "medpack" then
							msg.medpackAccuracy = (stats.hits/(stats.hits+stats.misses))*100 or 0
							msg.medpackResUsed = stats.picks*kMedPackCost
							msg.medpackResExpired = stats.misses*kMedPackCost
							msg.medpackEfficiency = (stats.picks/(stats.picks+stats.misses))*100 or 0
							msg.medpackRefill = stats.refilled
						elseif index == "ammopack" then
							msg.ammopackResUsed = stats.hits*kAmmoPackCost
							msg.ammopackResExpired = stats.misses*kAmmoPackCost
							msg.ammopackEfficiency = (stats.hits/(stats.hits+stats.misses))*100 or 0
							msg.ammopackRefill = stats.refilled
						elseif index == "catpack" then
							msg.catpackResUsed = stats.hits*kCatPackCost
							msg.catpackResExpired = stats.misses*kCatPackCost
							msg.catpackEfficiency = (stats.hits/(stats.hits+stats.misses))*100 or 0
						end
					end
				end
				
				Server.SendNetworkMessage(client, "CHUDMarineCommStats", msg, true)
			end
			
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
					msg.kills = wStats.kills
					
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
				msg.killstreak = stats.killstreak
				
				Server.SendNetworkMessage(client, "CHUDEndStatsOverall", msg, true)
			end
		
		end
		
	end)

local originalPlayerOnKill
originalPlayerOnKill = Class_ReplaceMethod("Player", "OnKill",
	function (self, killer, doer, point, direction)
		originalPlayerOnKill(self, killer, doer, point, direction)

		-- Send stats to the player on death
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
		
		-- Now save the attacker weapon
		local killerTeam = killer and killer:isa("Player") and killer:GetTeamNumber()
		local killerSteamId = killer and killer:isa("Player") and GetSteamIdForClientIndex(killer:GetClientIndex())
		local killerWeapon = doer and doer:isa("Weapon") and doer:GetTechId()
		
		if doer:GetParent() and doer:GetParent():isa("Player") then
			if killer:isa("Alien") and (doer.secondaryAttacking or doer.shootingSpikes) then
				killerWeapon = killer:GetActiveWeapon():GetSecondaryTechId()
			else
				killerWeapon = doer:GetTechId()
			end
			
		elseif HasMixin(doer, "Owner") and doer:GetOwner() and doer:GetOwner():isa("Player") then
			if doer.GetWeaponTechId then
				killerWeapon = doer:GetWeaponTechId()
			end
		end
		
		if killerSteamId then
			AddWeaponKill(killerSteamId, killerWeapon or kTechId.None, killerTeam)
		end
		
	end)

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

local originalSpitProcessHit
originalSpitProcessHit = Class_ReplaceMethod( "Spit", "ProcessHit",
	function(self, targetHit, surface, normal, hitPoint)

		local player = self:GetOwner()
		if player == targetHit then
			targetHit = nil
			local eyePos = player:GetEyePos()        
			local viewCoords = player:GetViewCoords()
			local trace = Shared.TraceRay(eyePos, eyePos + viewCoords.zAxis * 1.5, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
			if trace.fraction ~= 1 then
				targetHit = trace.entity
			end
		end
		
		if (targetHit and targetHit:isa("Player") and GetAreEnemies(player, targetHit)) or targetHit == nil then
			local steamId = GetSteamIdForClientIndex(player:GetClientIndex())
			if steamId then
				AddAccuracyStat(steamId, self:GetWeaponTechId(), targetHit ~= nil, targetHit and targetHit:isa("Onos"), player:GetTeamNumber())
			end
		end
		
		-- An actual attack I can hook semi-properly :_)
		originalSpitProcessHit(self, targetHit, surface, normal, hitPoint)

	end)

local originalSpitTimeUp
originalSpitTimeUp = Class_ReplaceMethod( "Spit", "TimeUp",
	function(self)
		local player = self:GetOwner()
		local steamId = GetSteamIdForClientIndex(player:GetClientIndex())
		if steamId then
			AddAccuracyStat(steamId, self:GetWeaponTechId(), false, false, player:GetTeamNumber())
		end
	
		originalSpitTimeUp(self)
	end)