local kHitSoundMessage =
{
    hitsound = "integer (1 to 3)",
}

function BuildHitSoundMessage( hitsound )
    
    local t = {}
    t.hitsound = hitsound
    return t
    
end

function ParseHitSoundMessage(message)
    return message.hitsound
end

Shared.RegisterNetworkMessage( "HitSound", kHitSoundMessage )


if Client then
	function HitSounds_PlayHitsound()
	end

	function OnCommandHitSound(hitSoundTable)

		local sound = ParseHitSoundMessage(hitSoundTable)
		HitSounds_PlayHitsound( sound )
		
	end

	Client.HookNetworkMessage("HitSound", OnCommandHitSound)
	
end

if Server then

	-- From 267's DamageTypes.lua
	function NS2Gamerules_GetUpgradedDamageScalar( attacker )

		if GetHasTech(attacker, kTechId.Weapons3, true) then            
			return kWeapons3DamageScalar                
		elseif GetHasTech(attacker, kTechId.Weapons2, true) then            
			return kWeapons2DamageScalar                
		elseif GetHasTech(attacker, kTechId.Weapons1, true) then            
			return kWeapons1DamageScalar                
		end
		
		return 1.0

	end
	--
	
	-- From 267's NetworkMessages.lua
	function SendDamageMessage( attacker, target, amount, point, overkill )
		
		if amount > 0 then
		
			local msg = BuildDamageMessage(target, amount, point)
			
			// damage reports must always be reliable when not spectating
			Server.SendNetworkMessage(attacker, "Damage", msg, true)
			
			for _, spectator in ientitylist(Shared.GetEntitiesWithClassname("Spectator")) do
			
				if attacker == Server.GetOwner(spectator):GetSpectatingPlayer() then
					Server.SendNetworkMessage(spectator, "Damage", msg, false)
				end
				
			end
			
		end
	   
	end
	--

    local hits = {}
    
    // Percentages used for weapons with variable damage
    local kHitSoundHigh = 0.9
    local kHitSoundMid = 0.5
    
    local kHitSoundHighShotgunHitCount = 14
    local kHitSoundMidShotgunHitCount = 6
    
    local kHitSoundHighXenoHitCount = 4     
    local kHitSoundMidXenoHitCount = 2
    
    local kHitSoundEnabledForWeapon =
        set {
            kTechId.Axe, kTechId.Welder, kTechId.Pistol, kTechId.Rifle, kTechId.Shotgun, kTechId.Flamethrower, kTechId.GrenadeLauncher,
            kTechId.Claw, kTechId.Minigun, kTechId.Railgun, 
            kTechId.Bite, kTechId.Parasite, kTechId.Xenocide, 
            kTechId.Spit, 
            kTechId.LerkBite, kTechId.Spikes, 
            kTechId.Swipe, kTechId.Stab, 
            kTechId.Gore,
        }
        
        
    function HitSound_IsEnabledForWeapon( techId )
        return techId and kHitSoundEnabledForWeapon[techId]
    end
    
    function HitSound_RecordHit( attacker, target, amount, point, overkill, weapon )
        local hit
        for i=1,#hits do
            hit = hits[i]
            if hit.attacker == attacker and hit.target == target and hit.weapon == weapon then
                if amount > 0 then
                    hit.point = point // always use the last point that caused damage
                end
                hit.amount = hit.amount + amount
                hit.overkill = hit.overkill + overkill
                hit.hitcount = hit.hitcount + 1
                return
            end
        end
        
        if amount > 0 then
            hits[#hits+1] =
            {
                attacker = attacker,
                target = target,
                amount = amount,
                point = point,
                overkill = overkill,
                weapon = weapon,
                hitcount = 1
            }
        end
        
    end
    
    function HitSound_DispatchHits()
        local hitsounds = {}
        local xenocounts = {}
        
        local hit,sound,attacker
        for i=1,#hits do
            hit = hits[i]
            attacker = hit.attacker
            target = hit.target 
            
            if target and target:isa("Player") and not target:isa("Embryo") then
                
                sound = 1
                if hit.weapon == kTechId.Railgun then
                    // Railgun hitsound is based on charge amount
                    local chargeAmount = ( ( hit.overkill / NS2Gamerules_GetUpgradedDamageScalar( attacker ) ) - kRailgunDamage ) / kRailgunChargeDamage
                    if kHitSoundHigh <= chargeAmount then
                        sound = 3
                    elseif kHitSoundMid <= chargeAmount then
                        sound = 2
                    end
                elseif hit.weapon == kTechId.GrenadeLauncher then
                    // Grenade Launcher is not affected by weapon upgrades
                    local damageAmount = hit.overkill / kGrenadeLauncherGrenadeDamage
                    if kHitSoundHigh <= damageAmount then
                        sound = 3
                    elseif kHitSoundMid <= damageAmount then
                        sound = 2
                    end
                elseif hit.weapon == kTechId.Xenocide then
                    // Xenocide hitsound is based on number of people hit
                    xenocounts[attacker] = ( xenocounts[attacker] or 0 ) + 1
                elseif hit.weapon == kTechId.Shotgun then
                    // Shotgun hitsound is based on number of pellets that hit a single target
                    if kHitSoundHighShotgunHitCount <= hit.hitcount then
                        sound = 3
                    elseif kHitSoundMidShotgunHitCount <= hit.hitcount then
                        sound = 2
                    end
                end
                
                // Prefer sending an event only for the best hit
                hitsounds[attacker] = math.max( hitsounds[attacker] or 0, sound )
            end
            
            // Send the accumulated damage message
            SendDamageMessage( attacker, hit.target, hit.amount, hit.point, hit.overkill )
            
        end
        
        // Xenocide hitsound is based on number of people hit
        for attacker,xenocount in pairs(xenocounts) do
            
            if kHitSoundHighXenoHitCount <= xenocount then
                sound = 3
            elseif kHitSoundMidXenoHitCount <= xenocount then
                sound = 2
            else
                sound = 1
            end
            
            // Prefer sending an event only for the best hit
            hitsounds[attacker] = math.max( hitsounds[attacker] or 0, sound )
            
        end
        
        for attacker,sound in pairs(hitsounds) do
            
            local msg = BuildHitSoundMessage(sound)
            
            // damage reports must be reliable when not spectating
            Server.SendNetworkMessage(attacker, "HitSound", msg, true)
            
        end
        
        // Clear the record
        hits = {}
    end
    
    // Hook the UpdateServer event just in case Player.OnProcessMove wasn't called or was overridden
    Event.Hook("UpdateServer", HitSound_DispatchHits)
end