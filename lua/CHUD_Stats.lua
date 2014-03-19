CHUDStats = { }
lastteamnr = 0
CHUD_pdmg = 0
CHUD_sdmg = 0
CHUDServer = false

function OnCHUDDamage(damageTable)

	local target = Shared.GetEntity(damageTable.targetId)
	local damage = damageTable.amount
	// Hack the planet
	if (damageTable.posx == 1 or damageTable.posx == 0) and damageTable.posz == kHitEffectMaxPosition-1 then
		local weapon = damageTable.posy
		local isPlayer = false
		if damageTable.posx == 1 then
			isPlayer = true
		end
		
		CHUDServer = true

		AddAttackStat(weapon, true, target, damage, isPlayer)
	else
		local position = Vector(damageTable.posx, damageTable.posy, damageTable.posz)
		if target then
			Client.AddWorldMessage(kWorldTextMessageType.Damage, damage, position, target:GetId())
		end
	end
end

function ShowClientStats(endRound)
	local text = ConditionalValue(endRound, "round", "life")
	local hitssum = 0
	local missessum = 0
	local pdmgsum = 0
	local sdmgsum = 0
	local onoshits = 0
	local onoshitssum = 0
	local overallacc = 0
	local overallacconos = 0
	
	// Weapons that contribute to accuracy
	local trackacc =
	{
		kTechId.Pistol, kTechId.Rifle, kTechId.Minigun, kTechId.Railgun, kTechId.Shotgun,
		kTechId.Axe, kTechId.Bite, kTechId.Parasite, kTechId.Spit, kTechId.Swipe, kTechId.Gore,
		kTechId.LerkBite, kTechId.Spikes, kTechId.Stab
	}
	
	if #CHUDStats > 0 and CHUDServer then
	
		Shared.Message("-----------------------")
		Shared.Message("Stats for this " .. text)
		Shared.Message("-----------------------")
		
		for i, wStats in pairs(CHUDStats) do
			if endRound then
				local accuracy = 0
				local accuracyOnos = 0
				local onoshits = 0
				local acc_message
				
				if wStats["lifeform"]["onos"] ~= nil and table.contains(trackacc, wStats["weapon"]) then
					onoshits = wStats["lifeform"]["onos"]
					onoshitssum = onoshitssum + onoshits
				end
				
				if wStats["hits"] > 0 or wStats["misses"] > 0 then
					accuracy = wStats["hits"]/(wStats["hits"]+wStats["misses"])*100
					if wStats["hits"] ~= onoshits then
						accuracyOnos = (wStats["hits"]-onoshits)/((wStats["hits"]-onoshits)+wStats["misses"])*100
					end
				end
				
				acc_message = string.format("Accuracy: %.2f%%", accuracy)
				
				if onoshits > 1 then
					acc_message = acc_message .. string.format(" / Without Onos hits: %.2f%%", accuracyOnos)
				end
				
				Shared.Message(wStats["weaponName"])
				if table.contains(trackacc, wStats["weapon"]) then
					Shared.Message(acc_message)
				end
				Shared.Message(string.format("Player damage: %d / Structure Damage: %d", math.ceil(wStats["pdmg"]), math.ceil(wStats["sdmg"])))
				pdmgsum = pdmgsum + wStats["pdmg"]
				sdmgsum = sdmgsum + wStats["sdmg"]
				Shared.Message("-----------------------")
			end
			if table.contains(trackacc, wStats["weapon"]) then
				hitssum = hitssum + wStats["hits"]
				missessum = missessum + wStats["misses"]
			end
		end

		if hitssum > 0 or missessum > 0 then
			overallacc = hitssum/(hitssum+missessum)*100
			if hitssum ~= onoshitssum then
				overallacconos = (hitssum-onoshitssum)/((hitssum-onoshitssum)+missessum)*100
			end
		end
		Shared.Message(string.format("Overall accuracy: %.2f%%", overallacc))
		if onoshitssum > 0 then
			Shared.Message(string.format("Without Onos hits: %.2f%%", overallacconos))
		end
		if endRound then
			Shared.Message(string.format("Total player damage: %d / Total structure damage %d", pdmgsum, sdmgsum))
		else
			Shared.Message(string.format("Player damage: %d / Structure damage %d", math.ceil(CHUD_pdmg), math.ceil(CHUD_sdmg)))
		end
		Shared.Message("-----------------------")
	end
	
end

originaldeath = DeathMsgUI_GetMessages
function DeathMsgUI_GetMessages()
	local deatharray = originaldeath()
	// We compare the 4th element (victim name) with the player name to see if it died
	// The problem with this is players can call themselves "Egg" and it will trigger this frequently
	// Oh well
	if deatharray[4] == Client.GetLocalPlayer():GetName() and Client.GetIsControllingPlayer() then
		ShowClientStats(false)
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
			ShowClientStats(true)
			CHUDStats = { }
			CHUD_pdmg = 0
			CHUD_sdmg = 0
		end
	end
end

function AddAttackStat(wTechId, wasHit, target, damageDealt, isPlayer)
	if Client.GetLocalPlayer():GetGameStarted() then
		local index
		if #CHUDStats > 0 and wTechId > 1 then
			for i, v in pairs(CHUDStats) do
				if v["weapon"] == wTechId then
					index = i
				end
			end
		else
			for i, v in pairs(CHUDStats) do
				if v["weaponName"] == "Others" then
					index = i
				end
			end
		end

		local sdmg = 0
		local pdmg = 0
		
		if damageDealt then	
			if isPlayer then
				pdmg = damageDealt
				CHUD_pdmg = CHUD_pdmg + damageDealt
			else
				sdmg = damageDealt
				CHUD_sdmg = CHUD_sdmg + damageDealt
			end
		end
		
		local weaponname
		
		// The Exo weapons all show the tooltip instead of the display name
		// Babblers shows up all in caps
		if wTechId > 1 then
			weaponname = GetDisplayNameForTechId(wTechId)
			if not weaponname or wTechId == kTechId.Minigun or wTechId == kTechId.Claw or wTechId == kTechId.Railgun or wTechId == kTechId.Babbler then
				weaponname = LookupTechData(wTechId, kTechDataMapName):gsub("^%l", string.upper)
			end
		else
			weaponname = "Others"
		end
		
		// Lerk's bite is called "Bite", just like the skulk bite, so clarify this
		if wTechId == kTechId.LerkBite then
			weaponname = "Lerk Bite"
		// This shows up as "Swipe Blink", just "Swipe"
		elseif wTechId == kTechId.Swipe then
			weaponname = "Swipe"
		end
		
		if index == nil then
			local stat = {
				weapon = wTechId,
				weaponName = weaponname,
				hits = ConditionalValue(wasHit, 1, 0),
				misses = ConditionalValue(wasHit, 0, 1),
				sdmg = sdmg,
				pdmg = pdmg,
				lifeform = { }
			}
			table.insert(CHUDStats, stat)
		else
			// To start off, we count every shot as a miss until the server confirms to us that it hit
			// So when we receive a hit we substract one miss
			if wasHit then
				// Shooting structures shouldn't be a hit, nor a miss
				if pdmg > 0 then
					CHUDStats[index]["hits"] = CHUDStats[index]["hits"] + 1
				end
				CHUDStats[index]["misses"] = CHUDStats[index]["misses"] - 1

				// If it was a hit, it has to have damage
				CHUDStats[index]["pdmg"] = CHUDStats[index]["pdmg"] + pdmg
				CHUDStats[index]["sdmg"] = CHUDStats[index]["sdmg"] + sdmg
				// Target damage stats
				if target and target:isa("Player") and target:isa("Alien") then
					local lifeform = CHUDStats[index]["lifeform"][target:GetMapName()]
					if lifeform ~= nil then
						CHUDStats[index]["lifeform"][target:GetMapName()] = lifeform + 1
					else
						CHUDStats[index]["lifeform"][target:GetMapName()] = 1
					end
				end
				
			else
				CHUDStats[index]["misses"] = CHUDStats[index]["misses"] + 1
			end
		end
	end
end

function CHUD_DebugStats()
	if Shared.GetCheatsEnabled() then
		/*AddAttackStat("rifle", true, target, damage)
		AddAttackStat("rifle", true, target, damage)
		AddAttackStat("rifle", false, target, damage)
		AddAttackStat("pistol", false, target, damage)
		AddAttackStat("pistol", true, target, damage)
		AddAttackStat("rifle", false, target, damage)*/
		Print("\n\n---------")
		for i, v in pairs(CHUDStats) do
			for k, value in pairs(v) do
				if k ~= "lifeform" then
					Print(k .. " " .. value)
				else
					for j, hits in pairs(value) do
						Print(j .. " " .. hits)
					end
				end
			end
			Print("---------")
		end
	end
end
Event.Hook("Console_chud_debugstats", CHUD_DebugStats)
// Attack counters for every single fucking thing in the game
// ClipWeapon covers FT, GL, pistol, rifle and SG
originalClipWeaponShoot = Class_ReplaceMethod( "ClipWeapon", "OnTag",
	function(self, tagName)
		if tagName == "shoot" and self.clip > 0 and Client.GetIsControllingPlayer() then
			for i=1,self:GetBulletsPerShot() do
				AddAttackStat(self:GetTechId(), false)
			end
		end
		originalClipWeaponShoot(self, tagName)
	end)
	
originalRiflebuttAttack = Class_ReplaceMethod( "Rifle", "PerformMeleeAttack",
	function(self, player)
		if Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalRiflebuttAttack(self, player)
	end)
	
originalAxeAttack = Class_ReplaceMethod( "Axe", "OnTag",
	function(self, tagName)
		if tagName == "swipe_sound" and Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalAxeAttack(self, tagName)
	end)

originalClawAttack = Class_ReplaceMethod( "Claw", "OnTag",
	function(self, tagName)
		if tagName == "claw_attack_start" and Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalClawAttack(self, tagName)
	end)
	
originalMinigunAttack = Class_ReplaceMethod( "Minigun", "OnTag",
	function(self, tagName)
		if (tagName == "l_shoot" or tagName == "r_shoot") and Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalMinigunAttack(self, tagName)
	end)
	
originalRailgunAttack = Class_ReplaceMethod( "Railgun", "OnTag",
	function(self, tagName)
		if ((tagName == "l_shoot" and self:GetIsLeftSlot()) or (tagName == "r_shoot" and not self:GetIsLeftSlot())) and Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalRailgunAttack(self, tagName)
	end)

originalBiteAttack = Class_ReplaceMethod( "BiteLeap", "OnTag",
	function(self, tagName)
		if tagName == "hit" and Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalBiteAttack(self, tagName)
	end)
	
originalGoreAttack = Class_ReplaceMethod( "Gore", "OnTag",
	function(self, tagName)
		if tagName == "hit" and Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalGoreAttack(self, tagName)
	end)
	
originalLerkBiteAttack = Class_ReplaceMethod( "LerkBite", "OnTag",
	function(self, tagName)
		if tagName == "hit" and Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalLerkBiteAttack(self, tagName)
	end)
	
originalParasiteAttack = Class_ReplaceMethod( "Parasite", "OnTag",
	function(self, tagName)
		if tagName == "hit" and Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalParasiteAttack(self, tagName)
	end)
	
originalSpikesAttack = SpikesMixin.OnTag
function SpikesMixin:OnTag(tagName)
	if tagName == "shoot" and Client.GetIsControllingPlayer() then
		AddAttackStat(Client.GetLocalPlayer():GetActiveWeapon():GetSecondaryTechId(), false)
	end
	originalSpikesAttack(self, tagName)
end

originalSpitAttack = Class_ReplaceMethod( "SpitSpray", "OnTag",
	function(self, tagName)
		if self.primaryAttacking and tagName == "shoot" and Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalSpitAttack(self, tagName)
	end)
	
originalStabAttack = Class_ReplaceMethod( "StabBlink", "OnTag",
	function(self, tagName)
		if tagName == "hit" and self.stabbing and Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalStabAttack(self, tagName)
	end)
	
originalSwipeAttack = Class_ReplaceMethod( "SwipeBlink", "OnTag",
	function(self, tagName)
		if tagName == "hit" and Client.GetIsControllingPlayer() then
			AddAttackStat(self:GetTechId(), false)
		end
		originalSwipeAttack(self, tagName)
	end)

Event.Hook("LocalPlayerChanged", CheckPlayerTeam)
Client.HookNetworkMessage("Damage", OnCHUDDamage)