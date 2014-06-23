
function OnCHUDDamage( damageTable )
	
	local target,amount,hitpos,overkill = ParseCHUDDamageMessage( damageTable )
	
	if target and amount > 0 then
		local damage = CHUDGetOption("overkilldamagenumbers") and overkill or amount
		Client.AddWorldMessage(kWorldTextMessageType.Damage, damage, hitpos, target:GetId())
	end
	
end

Client.HookNetworkMessage("CHUDDamage", OnCHUDDamage)