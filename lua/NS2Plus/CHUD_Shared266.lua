-- Remove with 267

Script.Load( "lua/HitSounds.lua" )

Shared.RegisterNetworkMessage( "CHUDGameEnd", { win = "integer (0 to 2)" } )

kGameEndAutoConcedeCheckInterval = 0.75
kDrawGameWindow = 0.75

if Client then
	AddClientUIScriptForTeam("all","GUIGameEnd")
end
	
if Server then
	Class_AddMethod( "Spit", "GetWeaponTechId",
		function()
			return kTechId.Spit
		end)

	local oldPlayerOnProcessMove
	oldPlayerOnProcessMove = Class_ReplaceMethod( "Player", "OnProcessMove",
		function( self, input )
			oldPlayerOnProcessMove( self, input )
			
			if Server then
				HitSound_DispatchHits()
			end
		end)
    
    local function CheckAutoConcede(self)

        PROFILE("NS2Gamerules:CheckAutoConcede")
        // This is an optional end condition based on the teams being unbalanced.
        local endGameOnUnbalancedAmount = Server.GetConfigSetting("end_round_on_team_unbalance")
        if endGameOnUnbalancedAmount and endGameOnUnbalancedAmount > 0 then

            local gameLength = Shared.GetTime() - self:GetGameStartTime()
            // Don't start checking for auto-concede until the game has started for some time.
            local checkAutoConcedeAfterTime = Server.GetConfigSetting("end_round_on_team_unbalance_check_after_time") or 300
            if gameLength > checkAutoConcedeAfterTime then

                local team1Players = self.team1:GetNumPlayers()
                local team2Players = self.team2:GetNumPlayers()
                local totalCount = team1Players + team2Players
                // Don't consider unbalanced game end until enough people are playing.

                if totalCount > 6 then
                
                    local team1ShouldLose = false
                    local team2ShouldLose = false
                    
                    if (1 - (team1Players / team2Players)) >= endGameOnUnbalancedAmount then

                        team1ShouldLose = true
                    elseif (1 - (team2Players / team1Players)) >= endGameOnUnbalancedAmount then

                        team2ShouldLose = true
                    end
                    
                    if team1ShouldLose or team2ShouldLose then
                    
                        // Send a warning before ending the game.
                        local warningTime = Server.GetConfigSetting("end_round_on_team_unbalance_after_warning_time") or 30
                        if self.sentAutoConcedeWarningAtTime and Shared.GetTime() - self.sentAutoConcedeWarningAtTime >= warningTime then
                            return team1ShouldLose, team2ShouldLose
                        elseif not self.sentAutoConcedeWarningAtTime then
                        
                            Shared.Message((team1ShouldLose and "Marine" or "Alien") .. " team auto-concede in " .. warningTime .. " seconds")
                            Server.SendNetworkMessage("AutoConcedeWarning", { time = warningTime, team1Conceding = team1ShouldLose }, true)
                            self.sentAutoConcedeWarningAtTime = Shared.GetTime()
                            
                        end
                        
                    else
                        self.sentAutoConcedeWarningAtTime = nil
                    end
                    
                end
                
            else
                self.sentAutoConcedeWarningAtTime = nil
            end
            
        end
        
        return false, false
        
    end
	
	Class_ReplaceMethod( "PlayingTeam", "GetHasTeamLost", 
		function( self )

            PROFILE("PlayingTeam:GetHasTeamLost")
            if GetGamerules():GetGameStarted() and not Shared.GetCheatsEnabled() then
            
                // Team can't respawn or last Command Station or Hive destroyed
                local activePlayers = self:GetHasActivePlayers()
                local abilityToRespawn = self:GetHasAbilityToRespawn()
                local numAliveCommandStructures = self:GetNumAliveCommandStructures()
                
                if  (not activePlayers and not abilityToRespawn) or
                    (numAliveCommandStructures == 0) or
                    (self:GetNumPlayers() == 0) or 
                    self:GetHasConceded() then
                    
                    local reasons = {}
                    if (not activePlayers and not abilityToRespawn) then
                        reasons[#reasons+1] = "Can't spawn"
                    end
                    if (numAliveCommandStructures == 0) then
                        reasons[#reasons+1] = "No command structure"
                    end
                    if (self:GetNumPlayers() == 0) then
                        reasons[#reasons+1] = "No players"
                    end
                    if (self:GetHasConceded()) then
                        reasons[#reasons+1] = "Gave up"
                    end
                    self.loseReason = string.format( "%s [%f]", table.concat( reasons, ", " ), Shared.GetTime() )
                    
                    return true
                    
                end
                
            end
            
            self.loseReason = nil
            
            return false
            
        end)

    function NS2Gamerules:CheckGameEnd()

        PROFILE("NS2Gamerules:CheckGameEnd")
        
        if self:GetGameStarted() and self.timeGameEnded == nil and not Shared.GetCheatsEnabled() and not self.preventGameEnd then

            local time = Shared.GetTime()
            if not self.timeDrawWindowEnds or time < self.timeDrawWindowEnds then

                local team1Lost = self.team1Lost or self.team1:GetHasTeamLost()
                local team2Lost = self.team2Lost or self.team2:GetHasTeamLost()

                if team1Lost or team2Lost then
            
                    -- After a team has entered a loss condition, they can not recover
                    self.team1Lost = team1Lost
                    self.team2Lost = team2Lost

                    -- Continue checking for a draw for kDrawGameWindow seconds
                    if not self.timeDrawWindowEnds then
                        EPrint( "DrawWindowOpen" )
                        self.timeDrawWindowEnds = time + kDrawGameWindow
                    end
                    
                else
                    -- Check for auto-concede if neither team lost.
                    if not self.timeNextAutoConcedeCheck or self.timeNextAutoConcedeCheck < time then
                        
                        team1Lost, team2Lost = CheckAutoConcede(self)
                        if team2Lost then
                            self.team2.loseReason = "Auto concede"
                            self:EndGame( self.team1 )
                        elseif team1Lost then
                            self.team1.loseReason = "Auto concede"
                            self:EndGame( self.team2 )
                        end
                        
                        self.timeNextAutoConcedeCheck = time + kGameEndAutoConcedeCheckInterval
                    end
                    
                end

            else

                        EPrint( "DrawWindowClosed" )
                if self.team2Lost and self.team1Lost then
                    
                    -- It's a draw
                    self:EndGame( nil )
                    
                elseif self.team2Lost then

                    -- Still no draw after kDrawGameWindow, count the win
                    self:EndGame( self.team1 )

                elseif self.team1Lost then

                    -- Still no draw after kDrawGameWindow, count the win
                    self:EndGame( self.team2 )
                    
                end

            end

        end

    end

    function NS2Gamerules:EndGame(winningTeam)
    
        if self:GetGameState() == kGameState.Started then
        
            if self.autoTeamBalanceEnabled then
                TEST_EVENT("Auto-team balance, game ended")
            end
            
            winningTeamType = winningTeam and winningTeam:GetTeamType() or kNeutralTeamType
            
            if winningTeamType == kMarineTeamType then

                self:SetGameState(kGameState.Team1Won)
                PostGameViz("Marines Win!")
                Shared.Message("Marines Win!")
                
            elseif winningTeamType == kAlienTeamType then

                self:SetGameState(kGameState.Team2Won)
                PostGameViz("Aliens Win!")
                Shared.Message("Aliens Win!")

            else

                self:SetGameState(kGameState.Draw)
                PostGameViz("Draw Game!")
                Shared.Message("Draw Game!")
                
            end
        
            EPrint( "Marine loss reason: %s", tostring( self.team1.loseReason ) )
            EPrint( "Alien loss reason: %s", tostring( self.team2.loseReason ) )
            
            Server.SendNetworkMessage( "CHUDGameEnd", { win = winningTeamType }, true)
            
            self.team1:ClearRespawnQueue()
            self.team2:ClearRespawnQueue()

            // Clear out Draw Game window handling
            self.team1Lost = nil
            self.team2Lost = nil
            self.timeDrawWindowEnds = nil
            
            // Automatically end any performance logging when the round has ended.
            Shared.ConsoleCommand("p_endlog")

            if winningTeam then
                self.sponitor:OnEndMatch(winningTeam)
                self.playerRanking:EndGame(winningTeam)
            end
            TournamentModeOnGameEnd()

        end
        
    end
	
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

		// attacker is always a player, doer is 'self'
		local attacker = nil
		local weapon = nil
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
				
				if attacker:isa("Alien") and ( self.secondaryAttacking or self.shootingSpikes) then
					weapon = attacker:GetActiveWeapon():GetSecondaryTechId()
				else
					weapon = self:GetTechId()
				end
				
			elseif HasMixin(self, "Owner") and self:GetOwner() and self:GetOwner():isa("Player") then
				
				attacker = self:GetOwner()
				
				if self.GetWeaponTechId then
					weapon = self:GetWeaponTechId()
				end
			end

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
							
							local amount = (target:GetIsAlive() or killedFromDamage) and damageDone or 0 // actual damage done
							local overkill = healthUsed + armorUsed * 2 // the full amount of potential damage, including overkill
							
							if HitSound_IsEnabledForWeapon( weapon ) then
								// Damage message will be sent at the end of OnProcessMove by the HitSound system
								HitSound_RecordHit( attacker, target, amount, point, overkill, weapon )                            
							else
								SendDamageMessage( attacker, target, amount, point, overkill )
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
	
end