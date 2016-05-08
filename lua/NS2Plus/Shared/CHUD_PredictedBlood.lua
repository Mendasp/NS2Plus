if Client then
	local oldDamageMixinDoDamage = DamageMixin.DoDamage
	local oldHandleHitEffect = HandleHitEffect
	function DamageMixin:DoDamage(damage, target, point, direction, surface, altMode, showtracer)        
		if not CHUDGetOption("serverblood") or not target then         
			return oldDamageMixinDoDamage(self, damage, target, point, direction, surface, altMode, showtracer)
		else
			HandleHitEffect = function()end
			local killedFromDamage = oldDamageMixinDoDamage(self, damage, target, point, direction, surface, altMode, showtracer)
			HandleHitEffect = oldHandleHitEffect
			return killedFromDamage
		end
	end
elseif Server then
	local function OnSetCHUDServerBlood(client, message)

		if client then
			local player = client:GetControllingPlayer()
			if player and message ~= nil then
				player.serverblood = message.serverblood
			end
		end

	end

	Server.HookNetworkMessage("SetCHUDServerBlood", OnSetCHUDServerBlood)

	local oldBuildHitEffectMessage = BuildHitEffectMessage
	
	function BuildHitEffectMessage(position, doer, surface, target, showtracer, altMode, damage, direction)
		local attacker = doer
		
		if doer:isa("Player") then
			attacker = doer
		elseif doer:GetParent() and doer:GetParent():isa("Player") then
			attacker = doer:GetParent()
		elseif HasMixin(doer, "Owner") and doer:GetOwner() and doer:GetOwner():isa("Player") then
			attacker = doer:GetOwner()
		end
		
		if attacker and attacker.serverblood == true and doer:GetParent() == attacker and target then
			local message = oldBuildHitEffectMessage(position, doer, surface, target, false, altMode, damage, direction)
			Server.SendNetworkMessage(attacker, "HitEffect", message, false)
		end
		
		return oldBuildHitEffectMessage(position, doer, surface, target, showtracer, altMode, damage, direction)
	end

end