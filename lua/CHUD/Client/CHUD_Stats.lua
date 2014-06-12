local function SendDamageNumberWorldMessage( target, damage, overkill, hitpos )
	if target and damage > 0 then
		local amount = CHUDGetOption("overkilldamagenumbers") and overkill or damage
		Client.AddWorldMessage(kWorldTextMessageType.Damage, amount, hitpos, target:GetId())
	end
end


function OnCHUDDamage( damageTable )
	
	local target,damage,hitpos = ParseDamageMessage( damageTable )
	local overkill = damageTable.overkill
	
	-- Make damage markers and such
	SendDamageNumberWorldMessage( target, damage, overkill, hitpos )

end


function OnCHUDDamage2( damageTable )
		
	local target,damage,hitpos = ParseDamageMessage( damageTable )
	local overkill,hitcount,mode = damageTable.overkill, damageTable.hitcount, damageTable.mode
	
	-- Make damage markers and such
	SendDamageNumberWorldMessage( target, damage, overkill, hitpos )
	
	-- Play Hit Sounds
	if target and target:isa("Player") and not target:isa("Embryo") and CHUDGetOption("hitsounds") > 0 and not Client.GetLocalPlayer():isa("Commander") then
		// Lazy!!!!!!
		// 0 = normal/low, 1 = mid, 2 = high
		local hitsound = 0
		
		if mode == kHitsoundMode.Hitcount then
			if hitcount >= 6 and hitcount <= 13 then
				hitsound = 1
			elseif hitcount > 13 then
				hitsound = 2
			end
		elseif mode == kHitsoundMode.Overkill then
			if overkill >= 75 and overkill <= 150 then
				hitsound = 1
			elseif overkill > 150 then
				hitsound = 2
			end
		end
		
		PlayHitsound(hitsound)
	end
end

Client.HookNetworkMessage("CHUDDamage", OnCHUDDamage)
Client.HookNetworkMessage("CHUDDamage2", OnCHUDDamage2)