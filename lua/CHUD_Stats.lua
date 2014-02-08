lastteamnr = 0
CHUD_pdmg_round = 0
CHUD_sdmg_round = 0
CHUD_pdmg = 0
CHUD_sdmg = 0
totalhits = { }
totalmiss = { }
onoshits = { }

local originaldmgmixin = DamageMixin.DoDamage
function DamageMixin:DoDamage(damage, target, point, direction, surface, altMode, showtracer)
	if Client and Client.GetLocalPlayer():GetGameStarted() then
		local weapon = self:GetMapName()
		
		if totalhits[weapon] == nil then
			totalhits[weapon] = 0
		end
		
		if totalmiss[weapon] == nil then
			totalmiss[weapon] = 0
		end
		
		if onoshits[weapon] == nil then
			onoshits[weapon] = 0
		end
		
		if target and HasMixin(target, "Live") and damage > 0 and GetAreEnemies(self,target) and target:GetHealthFraction() > 0 then
			if target:isa("Player") then
				totalhits[weapon] = totalhits[weapon] + 1
				CHUD_pdmg = CHUD_pdmg + damage
				CHUD_pdmg_round = CHUD_pdmg_round + damage
				if target:isa("Onos") then
					onoshits[weapon] = onoshits[weapon] + 1
				end
			else
				CHUD_sdmg = CHUD_sdmg + damage
				CHUD_sdmg_round = CHUD_sdmg_round + damage
			end
		else
			totalmiss[weapon] = totalmiss[weapon] + 1
		end
	end
	return originaldmgmixin(self, damage, target, point, direction, surface, altMode, showtracer)
end

function ShowClientStats(text, pdmg, sdmg)
	local hitsum = 0
	local misssum = 0
	local onoshitsum = 0
	
	if pdmg > 0 or sdmg > 0 then
		
		Shared.Message("-----------------------")
		Shared.Message("Stats for this " .. text)
		Shared.Message("-----------------------")
		Shared.Message("Player damage: " .. math.ceil(pdmg) .. " - Structure damage: " .. math.ceil(sdmg))
		Shared.Message("-----------------------")
		// Round end text
		if text == "round" then
			for k, v in pairs(totalhits) do
				if onoshits[k] > 0 then
					Shared.Message(string.format("%s accuracy: %.2f%% / Without Onos hits: %.2f%%", k:gsub("^%l", string.upper), (v/(v+totalmiss[k])*100), ((v-onoshits[k])/((v-onoshits[k])+totalmiss[k])*100)))
				else
					Shared.Message(string.format("%s accuracy: %.2f%%", k:gsub("^%l", string.upper), (v/(v+totalmiss[k])*100)))
				end
				hitsum = hitsum + v
				misssum = misssum + totalmiss[k]
				onoshitsum = onoshitsum + onoshits[k]
			end
			Shared.Message("-----------------------")
			Shared.Message(string.format("Overall accuracy: %.2f%%", (hitsum/(hitsum+misssum))*100))
			if onoshitsum > 0 then
				Shared.Message(string.format("Without Onos hits: %.2f%%", ((hitsum-onoshitsum)/((hitsum-onoshitsum)+misssum))*100))
			end
			Shared.Message("-----------------------")
		else
			for k, v in pairs(totalhits) do
				hitsum = hitsum + v
				misssum = misssum + totalmiss[k]
				onoshitsum = onoshitsum + onoshits[k]
			end
			Shared.Message(string.format("Current overall accuracy: %.2f%%", (hitsum/(hitsum+misssum))*100))
			if onoshitsum > 0 then
				Shared.Message(string.format("Without Onos hits: %.2f%%", ((hitsum-onoshitsum)/((hitsum-onoshitsum)+misssum))*100))
			end
			Shared.Message("-----------------------")
		end
		
	end
end

originaldeath = DeathMsgUI_GetMessages
function DeathMsgUI_GetMessages()
	local deatharray = originaldeath()
	// We compare the 4th element (victim name) with the player name to see if it died
	// The problem with this is players can call themselves "Egg" and it will trigger this frequently
	// Oh well
	if deatharray[4] == Client.GetLocalPlayer():GetName() then
		ShowClientStats("life", CHUD_pdmg, CHUD_sdmg)
		CHUD_pdmg = 0
		CHUD_sdmg = 0
	end
	return deatharray
end

function CheckPlayerTeam()
	local player = Client.GetLocalPlayer()
	local teamnr = player:GetTeamNumber()

	if teamnr ~= lastteamnr then
		lastteamnr = teamnr
		// If we moved to the RR, show stats & reset values
		if teamnr == 0 then
			ShowClientStats("round", CHUD_pdmg_round, CHUD_sdmg_round)
			CHUD_pdmg_round = 0
			CHUD_sdmg_round = 0
			CHUD_pdmg = 0
			CHUD_sdmg = 0
			totalhits = { }
			totalmiss = { }
			onoshits = { }
		end
	end
end

Event.Hook("LocalPlayerChanged", CheckPlayerTeam)