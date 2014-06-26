
local oldOnTakeDamage = CombatMixin.OnTakeDamage
function CombatMixin:OnTakeDamage(damage, attacker, doer, point, direction, damageType, preventAlert)
	if attacker and damage > 0 then
		self.lastAttackerId = attacker:GetId()  
		self.lastAttackerDidDamageTime = Shared.GetTime()
	end
	oldOnTakeDamage( self, damage, attacker, doer, point, direction, damageType, preventAlert )
end


function CombatMixin:OnEntityChange(oldId, newId)

    if self.lastAttackerId == oldId then
		if newId then
            self.lastAttackerId = newId
		else
			self.lastAttackerId = Entity.invalidId
		end
    end

    if self.lastTargetId == oldId then
        self.lastTargetId = Entity.invalidId
    end   

end


local oldGetDeathMessage = TeamDeathMessageMixin.GetDeathMessage
function TeamDeathMessageMixin:GetDeathMessage( killer, doerIconIndex, targetEntity )
	if not killer then
		local requiresInfestation = ConditionalValue(targetEntity:isa("Whip"), false, LookupTechData(targetEntity:GetTechId(), kTechDataRequiresInfestation))
		if requiresInfestation and targetEntity.lastAttackerDidDamageTime and Shared.GetTime() < targetEntity.lastAttackerDidDamageTime + 60 then
			killer = targetEntity:GetLastAttacker()
		end
	end
	return oldGetDeathMessage( self, killer, doerIconIndex, targetEntity )		
end
	