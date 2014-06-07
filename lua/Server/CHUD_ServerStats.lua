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

function CHUD_CHUDDamageMessage_Queue( target, name, data, reliable, only_accum )
	-- Try to accumulate
	local msg
	for i=1,#dmgMsgQ do
		
		msg = dmgMsgQ[i]
			
		if  msg.name == name and 
			msg.target == target and 
			msg.reliable == reliable and
			msg.data.targetId == data.targetId and
			( name ~= "CHUDDamageStat" or msg.data.weapon == data.weapon ) 
		then
			msg.data.posx = data.posx
			msg.data.posy = data.posy
			msg.data.posz = data.posz
			msg.data.amount = msg.data.amount + data.amount
			if name == "CHUDDamage" then
				msg.data.overkill = msg.data.overkill + data.overkill
			--	msg.saved = ( msg.saved or 0 ) + 16 
			elseif name == "CHUDDamageStat" then
				msg.data.overkill = msg.data.overkill + data.overkill
				msg.data.hitcount = math.min( msg.data.hitcount + 1, 32 )
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

						local amount = (target:GetIsAlive() or killedFromDamage) and damageDone or 0
						local overkill = healthUsed + armorUsed * 2
						
						if kCHUDStatsTrackAccLookup[weapon] then
							local msg = BuildCHUDDamageStatMessage( target, amount, point, overkill, weapon )
							CHUD_CHUDDamageMessage_Queue( attacker, "CHUDDamageStat", msg, true )	
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


-- Make FireMixin use the message accumulation stuff
local oldFireOnUpdate = FireMixin.OnUpdate
function FireMixin:OnUpdate(deltaTime)
	oldSendNetworkMessage = Server.SendNetworkMessage
	Server.SendNetworkMessage = 
		function ( target, name, data, reliable )
			data.overkill = data.amount
			CHUD_CHUDDamageMessage_Queue( target, "CHUDDamage", data, reliable )
		end
	oldFireOnUpdate( self, deltaTime )
	Server.SendNetworkMessage = oldSendNetworkMessage
end
local oldFireOnProcessMove = FireMixin.OnProcessMove
function FireMixin:OnProcessMove(deltaTime)
	oldSendNetworkMessage = Server.SendNetworkMessage
	Server.SendNetworkMessage = 
		function ( target, name, data, reliable )
			data.overkill = data.amount
			CHUD_CHUDDamageMessage_Queue( target, "CHUDDamage", data, reliable )
		end
	oldFireOnProcessMove( self, deltaTime )
	Server.SendNetworkMessage = oldSendNetworkMessage
end

-- Make poison show damage numbers	
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
