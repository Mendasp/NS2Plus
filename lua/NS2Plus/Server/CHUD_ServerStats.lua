local CHUDClientStats = {}
local CHUDTeamStats = {}
local CHUDRTGraph = {}
local CHUDHiveSkillGraph = {}
local CHUDKillGraph = {}
local CHUDResearchTree = {}
local CHUDBuildingSummary = {}
local CHUDStartingTechPoints = {}
local CHUDExportResearch = {}
local CHUDExportBuilding = {}

local serverStatsPath = "NS2Plus\\Stats\\"
local lastRoundStats = {}
local locationsTable = {}
local locationsLookup = {}
local minimapExtents = {}
local function OnMapLoadEntity(className, groupName, values)
	if className == "minimap_extents" then
		minimapExtents.scale = tostring(values.scale)
		minimapExtents.origin = tostring(values.origin)
	elseif className == "location" and values.name and values.name ~= "" then
		if not locationsLookup[values.name] then
			locationsLookup[values.name] = #locationsTable+1
			table.insert(locationsTable, values.name)
		end
	end
end
Event.Hook("MapLoadEntity", OnMapLoadEntity)

function CHUDGetLastRoundStats()
	return lastRoundStats
end

local function CHUDGetGameStarted()
	return GetGamerules():GetGameStarted()
end

local function CHUDGetGameTime(inMinutes)
	local gamerules = GetGamerules()
	local gameTime
	if gamerules then
		gameTime = gamerules:GetGameTimeChanged()
	end
	
	if gameTime and inMinutes then
		gameTime = gameTime/60
	end
	
	return gameTime
end

local function AddExportBuilding(teamNumber, techId, built, destroyed, recycled, extraInfo)
	table.insert(CHUDExportBuilding, { teamNumber = teamNumber, techId = EnumToString(kTechId, techId), gameTime = CHUDGetGameTime(), built = built, destroyed = destroyed, recycled = recycled })
	if extraInfo then
		CHUDExportBuilding[#CHUDExportBuilding][extraInfo.name] = extraInfo.value
	end
end

local function AddRTStat(teamNumber, built, destroyed)
	if teamNumber == 1 or teamNumber == 2 then
		local rtsTable = CHUDTeamStats[teamNumber].rts
		local finishedBuilding = built and not destroyed
		
		if built then
			table.insert(CHUDRTGraph, {teamNumber = teamNumber, destroyed = destroyed, gameMinute = CHUDGetGameTime(true)})
		end
		
		-- The unfinished nodes will be computed on the overall built/lost data
		rtsTable.lost = rtsTable.lost + ConditionalValue(destroyed, 1, 0)
		rtsTable.built = rtsTable.built + ConditionalValue(finishedBuilding, 1, 0)
	end
end

local function AddTechStat(teamNumber, techId, built, destroyed, recycled)
	if (teamNumber == 1 or teamNumber == 2) and techId then
		local teamInfoEnt = GetTeamInfoEntity(teamNumber)
		
		-- Advanced armory displays both "Upgrade to advanced armory" and "Advanced weaponry", filter one
		if techId ~= kTechId.AdvancedWeaponry then
			table.insert(CHUDResearchTree, { teamNumber = teamNumber, techId = techId, finishedMinute = CHUDGetGameTime(true), activeRTs = teamInfoEnt:GetNumResourceTowers(), teamRes = teamInfoEnt:GetTeamResources(), destroyed = destroyed, built = built, recycled = recycled })
		end
	end
end

local function AddBuildingStat(teamNumber, techId, lost)
	if (teamNumber == 1 or teamNumber == 2) and techId then
		if techId == kTechId.DrifterEgg then
			techId = kTechId.Drifter
		elseif techId == kTechId.ARCRoboticsFactory then
			techId = kTechId.RoboticsFactory
		elseif techId == kTechId.AdvancedArmory then
			techId = kTechId.Armory
		elseif techId == kTechId.CragHive then
			techId = kTechId.Hive
		elseif techId == kTechId.ShiftHive then
			techId = kTechId.Hive
		elseif techId == kTechId.ShadeHive then
			techId = kTechId.Hive
		end
		
		local stat = CHUDBuildingSummary[teamNumber][techId]
		if not stat then
			CHUDBuildingSummary[teamNumber][techId] = {}
			CHUDBuildingSummary[teamNumber][techId].built = 0
			CHUDBuildingSummary[teamNumber][techId].lost = 0
			stat = CHUDBuildingSummary[teamNumber][techId]
		end
		
		if lost then
			stat.lost = stat.lost + 1
		else
			stat.built = stat.built + 1
		end
	end
end

local notLoggedBuildings = set {
	"PowerPoint",
	"Cyst",
	"TunnelEntrance",
	"TunnelExit",
	"Hydra",
	"Clog",
	"Web",
	"Babbler",
	"BabblerEgg",
	"Egg",
	"BoneWall",
	"Hallucination",
	"Mine",
}

local techLoggedAsBuilding = set {
	kTechId.ARC,
	kTechId.MAC,
}

local techLogBuildings = set {
	"ArmsLab",
	"PrototypeLab",
	"Observatory",
	"CommandStation",
	"Veil",
	"Shell",
	"Spur",
	"Hive",
}

local oldJoinTeam
oldJoinTeam = Class_ReplaceMethod("NS2Gamerules", "JoinTeam",
	function(self, player, newTeamNumber, ...)
		local oldTeamNumber = player:GetTeamNumber()
		local success, newPlayer, c, d, e, f = oldJoinTeam(self, player, newTeamNumber, ...)

		if success and CHUDGetGameStarted() then
			CHUDTeamStats[1].maxPlayers = math.max(CHUDTeamStats[1].maxPlayers, self.team1:GetNumPlayers())
			CHUDTeamStats[2].maxPlayers = math.max(CHUDTeamStats[2].maxPlayers, self.team2:GetNumPlayers())

			local function isPlayingTeam(tn)
				return tn == kTeam1Index or tn == kTeam2Index
			end

			local joined = isPlayingTeam(newTeamNumber)
			local left = isPlayingTeam(oldTeamNumber)
			if joined or left then
				local steamId = newPlayer:GetSteamId()
				local affectedTeamNumber = ConditionalValue(joined, newTeamNumber, oldTeamNumber)
				table.insert(CHUDHiveSkillGraph, { gameMinute = CHUDGetGameTime(true), joined = joined, teamNumber = affectedTeamNumber, steamId = steamId } )
			end
		end
		
		return success, newPlayer, c, d, e, f
	end)

local oldTechResearched = ResearchMixin.TechResearched
function ResearchMixin:TechResearched(structure, researchId)
	oldTechResearched(self, structure, researchId)
	
	if structure and structure:GetId() == self:GetId() then
		if researchId == kTechId.Recycle then
			AddExportBuilding(structure:GetTeamNumber(), structure.GetTechId and structure:GetTechId(), structure:GetIsBuilt(), true, true) -- Recycling ?11
			
			if structure:isa("ResourceTower") then
				AddRTStat(structure:GetTeamNumber(), structure:GetIsBuilt(), true, true, tostring(structure:GetOrigin()), structure:GetLocationName())
			elseif structure.GetClassName and techLogBuildings[structure:GetClassName()] then
				AddTechStat(structure:GetTeamNumber(), structure.GetTechId and structure:GetTechId(), structure:GetIsBuilt(), true, true)
				AddBuildingStat(structure:GetTeamNumber(), structure.GetTechId and structure:GetTechId(), true)
			end
		elseif techLoggedAsBuilding[researchId] then
			AddBuildingStat(structure:GetTeamNumber(), researchId, false)
			
			AddExportBuilding(structure:GetTeamNumber(), researchId, true, false, false) --  Tech Researched 100
		else
			-- Don't add recycles to the tech log
			AddTechStat(structure:GetTeamNumber(), researchId, true, false, false)
			
			table.insert(CHUDExportResearch, {teamNumber = structure:GetTeamNumber(), researchId = EnumToString(kTechId, researchId), gameTime = CHUDGetGameTime()})
		end
	end
end

local oldConstructionComplete = ConstructMixin.OnConstructionComplete
function ConstructMixin:OnConstructionComplete(builder)
	oldConstructionComplete(self, builder)
	
	AddExportBuilding(self:GetTeamNumber(), self.GetTechId and self:GetTechId(), true, false, false) -- Construction Complete 100
	
	if self:isa("ResourceTower") then
		AddRTStat(self:GetTeamNumber(), true, false, false, tostring(self:GetOrigin()), self:GetLocationName())
	elseif self.GetClassName and techLogBuildings[self:GetClassName()] then
		AddTechStat(self:GetTeamNumber(), self.GetTechId and self:GetTechId(), true, false, false)
		AddBuildingStat(self:GetTeamNumber(), self.GetTechId and self:GetTechId(), false)
	elseif self.GetClassName and not notLoggedBuildings[self:GetClassName()] then
		AddBuildingStat(self:GetTeamNumber(), self.GetTechId and self:GetTechId(), false)
	end
end

local function ResetCHUDLastLifeStats(steamId)
	if steamId > 0 and CHUDClientStats[steamId] then
		CHUDClientStats[steamId]["last"] = {}
		CHUDClientStats[steamId]["last"].pdmg = 0
		CHUDClientStats[steamId]["last"].sdmg = 0
		CHUDClientStats[steamId]["last"].hits = 0
		CHUDClientStats[steamId]["last"].onosHits = 0
		CHUDClientStats[steamId]["last"].misses = 0
		CHUDClientStats[steamId]["last"].kills = 0
	end
end

-- Function name 2 stronk
local function MaybeInitCHUDClientStats(steamId, wTechId, teamNumber)
	if steamId > 0 and (teamNumber == 1 or teamNumber == 2) then
		if not CHUDClientStats[steamId] then
			CHUDClientStats[steamId] = {}
			CHUDClientStats[steamId][1] = {}
			CHUDClientStats[steamId][2] = {}
			for _, entry in ipairs(CHUDClientStats[steamId]) do
				entry.kills = 0
				entry.assists = 0
				entry.deaths = 0
				entry.score = 0
				entry.pdmg = 0
				entry.sdmg = 0
				entry.hits = 0
				entry.onosHits = 0
				entry.misses = 0
				entry.killstreak = 0
				entry.timeBuilding = 0
				entry.timePlayed = 0
				entry.commanderTime = 0
			end
			
			-- These are team independent
			CHUDClientStats[steamId].playerName = "NSPlayer"
			CHUDClientStats[steamId].hiveSkill = -1
			CHUDClientStats[steamId].isRookie = false
			CHUDClientStats[steamId].lastTeam = teamNumber
			
			-- Initialize the last life stats
			ResetCHUDLastLifeStats(steamId)
			
			CHUDClientStats[steamId]["weapons"] = {}
			CHUDClientStats[steamId]["status"] = {}
		elseif (teamNumber ~= nil and CHUDClientStats[steamId].lastTeam ~= teamNumber) then
			CHUDClientStats[steamId].lastTeam = teamNumber
			
			-- Clear the last life stats if the player switches teams
			ResetCHUDLastLifeStats(steamId)
		end
		
		if wTechId and not CHUDClientStats[steamId]["weapons"][wTechId] and (teamNumber == 1 or teamNumber == 2) then
			CHUDClientStats[steamId]["weapons"][wTechId] = {}
			CHUDClientStats[steamId]["weapons"][wTechId].hits = 0
			CHUDClientStats[steamId]["weapons"][wTechId].onosHits = 0
			CHUDClientStats[steamId]["weapons"][wTechId].misses = 0
			CHUDClientStats[steamId]["weapons"][wTechId].kills = 0
			CHUDClientStats[steamId]["weapons"][wTechId].pdmg = 0
			CHUDClientStats[steamId]["weapons"][wTechId].sdmg = 0
			CHUDClientStats[steamId]["weapons"][wTechId].teamNumber = teamNumber
		end
	end
end

local function AddAccuracyStat(steamId, wTechId, wasHit, isOnos, teamNumber)
	if CHUDGetGameStarted() and steamId > 0 and (teamNumber == 1 or teamNumber == 2) then
		MaybeInitCHUDClientStats(steamId, wTechId, teamNumber)
		
		if CHUDClientStats[steamId] then
			local overallStat = CHUDClientStats[steamId][teamNumber]
			local stat = CHUDClientStats[steamId]["weapons"][wTechId]
			local lastStat = CHUDClientStats[steamId]["last"]
			
			if wasHit then
				overallStat.hits = overallStat.hits + 1
				stat.hits = stat.hits + 1
				lastStat.hits = lastStat.hits + 1
				
				if teamNumber == 1 or teamNumber == 2 then
					CHUDTeamStats[teamNumber].hits = CHUDTeamStats[teamNumber].hits + 1
				end
				
				if isOnos then
					overallStat.onosHits = overallStat.onosHits + 1
					stat.onosHits = stat.onosHits + 1
					lastStat.onosHits = lastStat.onosHits + 1
					
					if teamNumber == 1 then
						CHUDTeamStats[1].onosHits = CHUDTeamStats[1].onosHits + 1
					end
				end
			else
				overallStat.misses = overallStat.misses + 1
				stat.misses = stat.misses + 1
				lastStat.misses = lastStat.misses + 1
				
				if teamNumber == 1 or teamNumber == 2 then
					CHUDTeamStats[teamNumber].misses = CHUDTeamStats[teamNumber].misses + 1
				end
			end
		end
	end
end

local function AddDamageStat(steamId, damage, isPlayer, wTechId, teamNumber)
	if CHUDGetGameStarted() and steamId > 0 and (teamNumber == 1 or teamNumber == 2) then
		MaybeInitCHUDClientStats(steamId, wTechId, teamNumber)
		
		if CHUDClientStats[steamId] then
			local stat = CHUDClientStats[steamId][teamNumber]
			local weaponStat = CHUDClientStats[steamId]["weapons"][wTechId]
			local lastStat = CHUDClientStats[steamId]["last"]
			
			if isPlayer then
				stat.pdmg = stat.pdmg + damage
				weaponStat.pdmg = weaponStat.pdmg + damage
				lastStat.pdmg = lastStat.pdmg + damage
			else
				stat.sdmg = stat.sdmg + damage
				weaponStat.sdmg = weaponStat.sdmg + damage
				lastStat.sdmg = lastStat.sdmg + damage
			end
		end
	end
end

local function AddWeaponKill(steamId, wTechId, teamNumber)
	if CHUDGetGameStarted() and steamId > 0 and (teamNumber == 1 or teamNumber == 2) then
		MaybeInitCHUDClientStats(steamId, wTechId, teamNumber)
		
		if CHUDClientStats[steamId] then
			local rootStat = CHUDClientStats[steamId][teamNumber]
			local weaponStat = CHUDClientStats[steamId]["weapons"][wTechId]
			local lastStat = CHUDClientStats[steamId]["last"]
			
			weaponStat.kills = weaponStat.kills + 1
			lastStat.kills = lastStat.kills + 1
			
			if lastStat.kills > rootStat.killstreak then
				rootStat.killstreak = lastStat.kills
			end
		end
	end
end

local function AddTeamGraphKill(teamNumber, killer, victim, weapon, doer)
	if teamNumber == 1 or teamNumber == 2 then
		local killerLocation = killer and killer:isa("Player") and locationsLookup[killer:GetLocationName()] or nil
		local killerPosition = killer and killer:isa("Player") and tostring(killer:GetOrigin()) or nil
		local killerClass = killer and killer:isa("Player") and EnumToString(kPlayerStatus, killer:GetPlayerStatusDesc()) or nil
		if not killerClass and doer and doer.GetClassName then
			killerClass = doer:GetClassName()
		end
		local doerLocation, doerPosition
		if doer and doer:isa("WhipBomb") and doer.shooter then
			doer = doer.shooter
		end
		-- Don't log doerLocation/Position for weapons that have parents (rifle, bite, etc)
		-- These are meant for things like mines, grenades, etc
		if doer and doer.GetParent and doer:GetParent() == nil then
			local origin = doer.GetOrigin and doer:GetOrigin()
			if origin then
				local location = GetLocationForPoint(origin)
				doerLocation = locationsLookup[location and location:GetName()]
				doerPosition = tostring(origin)
			end
		end
		local killerSteamID = killer and killer:isa("Player") and GetSteamIdForClientIndex(killer:GetClientIndex()) or nil
		local victimLocation = victim and victim:isa("Player") and locationsLookup[victim:GetLocationName()] or nil
		local victimPosition = victim and victim:isa("Player") and tostring(victim:GetOrigin()) or nil
		local victimClass = victim and victim:isa("Player") and EnumToString(kPlayerStatus, victim:GetPlayerStatusDesc()) or nil
		local victimSteamID = victim and victim:isa("Player") and GetSteamIdForClientIndex(victim:GetClientIndex()) or nil
		local weapon = EnumToString(kTechId, weapon) or nil
		
		table.insert(CHUDKillGraph, {gameTime = CHUDGetGameTime(), gameMinute = CHUDGetGameTime(true), killerTeamNumber = teamNumber, killerWeapon = weapon, killerPosition = killerPosition, killerLocation = killerLocation, killerClass = killerClass, killerSteamID = killerSteamID, victimPosition = victimPosition, victimLocation = victimLocation, victimClass = victimClass, victimSteamID = victimSteamID, doerLocation = doerLocation, doerPosition = doerPosition})
	end
end

local function AddBuildTime(steamId, buildTime, teamNumber)
	if CHUDGetGameStarted() and steamId > 0 and (teamNumber == 1 or teamNumber == 2) then
		MaybeInitCHUDClientStats(steamId, nil, teamNumber)
		
		if CHUDClientStats[steamId] then
			local stat = CHUDClientStats[steamId][teamNumber]
			stat.timeBuilding = stat.timeBuilding + buildTime
		end
	end
end

local classNameToTechId = {}
classNameToTechId["SporeCloud"] = kTechId.Spores
classNameToTechId["NerveGasCloud"] = kTechId.GasGrenade
classNameToTechId["WhipBomb"] = kTechId.WhipBomb
classNameToTechId["DotMarker"] = kTechId.BileBomb
classNameToTechId["Shockwave"] = kTechId.Stomp

local function GetAttackerWeapon(attacker, doer)

		local attackerTeam = attacker and attacker:isa("Player") and attacker:GetTeamNumber() or nil
		local attackerSteamId = attacker and attacker:isa("Player") and GetSteamIdForClientIndex(attacker:GetClientIndex()) or nil
		local attackerWeapon = doer and doer:isa("Weapon") and doer:GetTechId() or kTechId.None
		
		if attacker and doer then
			if doer.GetClassName and classNameToTechId[doer:GetClassName()] then
				attackerWeapon = classNameToTechId[doer:GetClassName()]
			elseif doer:GetParent() and doer:GetParent():isa("Player") then
				if attacker:isa("Alien") and ((attacker:isa("Gorge") and doer.secondaryAttacking) or doer.shootingSpikes) then
					attackerWeapon = attacker:GetActiveWeapon():GetSecondaryTechId()
				else
					attackerWeapon = doer:GetTechId()
				end
			elseif HasMixin(doer, "Owner") then
				if doer.GetWeaponTechId then
					attackerWeapon = doer:GetWeaponTechId()
				elseif doer.techId then
					local deathIcon = nil
					attackerWeapon = doer.techId
					deathIcon = doer.GetDeathIconIndex and doer:GetDeathIconIndex() or nil
					
					-- Translate the deathicon into a techid we can use for the end-game stats
					if deathIcon == kDeathMessageIcon.Mine then
						attackerWeapon = kTechId.LayMines
					elseif deathIcon == kDeathMessageIcon.PulseGrenade then
						attackerWeapon = kTechId.PulseGrenade
					elseif deathIcon == kDeathMessageIcon.ClusterGrenade then
						attackerWeapon = kTechId.ClusterGrenade
					elseif deathIcon == kDeathMessageIcon.Flamethrower then
						attackerWeapon = kTechId.Flamethrower
					elseif deathIcon == kDeathMessageIcon.EMPBlast then
						attackerWeapon = kTechId.PowerSurge
					end
				end
			end
		end
		
		return attackerSteamId, attackerWeapon, attackerTeam

end

local originalUpdateScore
originalUpdateScore = Class_ReplaceMethod("PlayerInfoEntity", "UpdateScore",
	function(self)
		originalUpdateScore(self)
		
		MaybeInitCHUDClientStats(self.steamId, nil, self.teamNumber)
		local stat = CHUDClientStats[self.steamId]
		
		if stat then
			stat.playerName = self.playerName
			stat.hiveSkill = self.playerSkill
			stat.isRookie = self.isRookie
		end
		
		return true
	end)
	
local statusGrouping = {}
statusGrouping[kPlayerStatus.SkulkEgg] = kPlayerStatus.Embryo
statusGrouping[kPlayerStatus.GorgeEgg] = kPlayerStatus.Embryo
statusGrouping[kPlayerStatus.LerkEgg] = kPlayerStatus.Embryo
statusGrouping[kPlayerStatus.FadeEgg] = kPlayerStatus.Embryo
statusGrouping[kPlayerStatus.OnosEgg] = kPlayerStatus.Embryo
statusGrouping[kPlayerStatus.Evolving] = kPlayerStatus.Embryo

-- Add commander playing teams separate per team
-- Vanilla only tracks overall commanding time
local ScoringSharedUpdate = debug.getupvaluex(ScoringMixin.OnProcessMove, "SharedUpdate")
local function newScoringSharedUpdate(self, deltaTime)
	ScoringSharedUpdate(self, deltaTime)
	
	if self.clientIndex and self.clientIndex > 0 then
		local steamId = GetSteamIdForClientIndex(self.clientIndex)
		local teamNumber = self:GetTeamNumber()
		local paused = GetIsGamePaused and GetIsGamePaused()
		if not paused and steamId and steamId > 0 and (teamNumber == 1 or teamNumber == 2) and CHUDClientStats[steamId] then
			local statusPlayer = CHUDClientStats[steamId]
			local statusRoot = CHUDClientStats[steamId]["status"]
			local stat = CHUDClientStats[steamId][teamNumber]
			-- This function gets called sometimes twice for the same player in the same frame
			-- It also happens that sometimes the times are in the past
			-- So just check that the time looks correct
			if self:GetIsPlaying() and (not statusPlayer.lastUpdate or statusPlayer.lastUpdate < Shared.GetTime()) then
				statusPlayer.lastUpdate = Shared.GetTime()
				if self:isa("Commander") then
					stat.commanderTime = stat.commanderTime + deltaTime
				end
				stat.timePlayed = stat.timePlayed + deltaTime
				local status = statusGrouping[self:GetPlayerStatusDesc()] ~= nil and statusGrouping[self:GetPlayerStatusDesc()] or self:GetPlayerStatusDesc()
				
				if statusRoot[status] == nil then
					statusRoot[status] = 0
				end
				statusRoot[status] = statusRoot[status] + deltaTime
			end
		end
	end
end
debug.replaceupvalue(ScoringMixin.OnProcessMove, "SharedUpdate", newScoringSharedUpdate, true)

local originalScoringAddKill = ScoringMixin.AddKill
function ScoringMixin:AddKill()
	originalScoringAddKill(self)
	
	if self.clientIndex and self.clientIndex > 0 then
		local steamId = GetSteamIdForClientIndex(self.clientIndex)
		local teamNumber = self:GetTeamNumber()
		MaybeInitCHUDClientStats(steamId, nil, teamNumber)
		local stat = CHUDClientStats[steamId] and CHUDClientStats[steamId][teamNumber]
		
		if stat then
			stat.kills = Clamp(stat.kills + 1, 0, kMaxKills)
		end
	end
end
	
local originalScoringAddAssist = ScoringMixin.AddAssistKill
function ScoringMixin:AddAssistKill()
	originalScoringAddAssist(self)
	
	if self.clientIndex and self.clientIndex > 0 then
		local steamId = GetSteamIdForClientIndex(self.clientIndex)
		local teamNumber = self:GetTeamNumber()
		MaybeInitCHUDClientStats(steamId, nil, teamNumber)
		local stat = CHUDClientStats[steamId] and CHUDClientStats[steamId][teamNumber]
		
		if stat then
			stat.assists = Clamp(stat.assists + 1, 0, kMaxKills)
		end
	end
end

local originalScoringAddDeath = ScoringMixin.AddDeaths
function ScoringMixin:AddDeaths()
	originalScoringAddDeath(self)
	
	if self.clientIndex and self.clientIndex > 0 then
		local steamId = GetSteamIdForClientIndex(self.clientIndex)
		local teamNumber = self:GetTeamNumber()
		MaybeInitCHUDClientStats(steamId, nil, teamNumber)
		local stat = CHUDClientStats[steamId] and CHUDClientStats[steamId][teamNumber]
		
		if stat then
			stat.deaths = Clamp(stat.deaths + 1, 0, kMaxDeaths)
		end
	end
end

local originalScoringAddScore = ScoringMixin.AddScore
function ScoringMixin:AddScore(points, res, wasKill)
	originalScoringAddScore(self, points, res, wasKill)
	
	if points ~= nil and self.clientIndex and self.clientIndex > 0 then
		local steamId = GetSteamIdForClientIndex(self.clientIndex)
		local teamNumber = self:GetTeamNumber()
		MaybeInitCHUDClientStats(steamId, nil, teamNumber)
		local stat = CHUDClientStats[steamId] and CHUDClientStats[steamId][teamNumber]
		
		if stat then
			stat.score = Clamp(stat.score + points, 0, kMaxScore)
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
		
	if attacker.overkill == true then
		amount = overkill
	end
	
	oldSendDamageMessage( attacker, target, amount, point, overkill )
	
end

local kBioMassTechIds = enum({ kTechId.BioMassOne, kTechId.BioMassTwo, kTechId.BioMassThree,
						kTechId.BioMassFour, kTechId.BioMassFive, kTechId.BioMassSix,
						kTechId.BioMassSeven, kTechId.BioMassEight, kTechId.BioMassNine })
local oldTakeDamage = LiveMixin.TakeDamage
function LiveMixin:TakeDamage(damage, attacker, doer, point, direction, armorUsed, healthUsed, damageType, preventAlert)
		-- If a Hive dies, we'll log the biomass level
		local className
		local biomassLevel
		if self.GetClassName then
			className = self:GetClassName()
			if className == "Hive" then
				biomassLevel = self:GetTeam():GetBioMassLevel()-self:GetBioMassLevel()
			end
		end
		
		killedFromDamage, damageDone = oldTakeDamage(self, damage, attacker, doer, point, direction, armorUsed, healthUsed, damageType, preventAlert)
		
		local targetTeam = self:GetTeamNumber()
		
		if killedFromDamage then
			if self:isa("ResourceTower") then
				AddRTStat(targetTeam, self:GetIsBuilt(), true, false, tostring(self:GetOrigin()), self:GetLocationName())
			elseif not self:isa("Player") and not self:isa("Weapon") then
				if techLoggedAsBuilding[self.GetTechId and self:GetTechId()] or className == "Drifter" then
					AddExportBuilding(self:GetTeamNumber(), self.GetTechId and self:GetTechId(), true, true, false) -- Destroyed drifter/tech 110
				end
				if className then
					if not notLoggedBuildings[className] then
						AddBuildingStat(targetTeam, self.GetTechId and self:GetTechId(), true)
					end
					if techLogBuildings[className] then
						AddTechStat(self:GetTeamNumber(), self.GetTechId and self:GetTechId(), self:GetIsBuilt(), true, false)
						-- If a hive died, we add the biomass level to the tech log
						-- If all hives died, we show biomass 1 as lost
						-- This makes it possible to see the biomass level during the game
						if biomassLevel then
							AddTechStat(self:GetTeamNumber(), kBioMassTechIds[Clamp(biomassLevel, 1, 9)], true, biomassLevel == 0, false)
						end
					end
				end
			end
		end
		
		local attackerSteamId, attackerWeapon, attackerTeam = GetAttackerWeapon(attacker, doer)
		if attackerSteamId then
			-- Don't count friendly fire towards damage counts
			-- Check if there is a doer, because when alien structures are off infestation
			-- it will count as an attack for the last person that shot it, only log actual attacks
			if attackerTeam ~= targetTeam and damageDone and damageDone > 0 and doer then
				AddDamageStat(attackerSteamId, damageDone or 0, self and self:isa("Player") and not (self:isa("Hallucination") or self.isHallucination), attackerWeapon, attackerTeam)
			end
		end
		
		return killedFromDamage, damageDone
end

local function CHUDResetCommStats(commSteamId)
	if not CHUDCommStats[commSteamId] then
		CHUDCommStats[commSteamId] = { }
		CHUDCommStats[commSteamId]["medpack"] = { }
		CHUDCommStats[commSteamId]["ammopack"] = { }
		CHUDCommStats[commSteamId]["catpack"] = { }
		
		for index, _ in pairs(CHUDCommStats[commSteamId]) do
			CHUDCommStats[commSteamId][index].picks = 0
			CHUDCommStats[commSteamId][index].misses = 0
			if index ~= "catpack" then
				CHUDCommStats[commSteamId][index].refilled = 0
			end
			if index == "medpack" then
				CHUDCommStats[commSteamId][index].hitsAcc = 0
			end
		end
	end
end

local function CHUDResetStats()
	CHUDCommStats = {}
	CHUDClientStats = {}
	
	CHUDRTGraph = {}
	CHUDKillGraph = {}
	
	CHUDTeamStats[1] = {}
	CHUDTeamStats[1].hits = 0
	CHUDTeamStats[1].onosHits = 0
	CHUDTeamStats[1].misses = 0
	CHUDTeamStats[1].rts = {lost = 0, built = 0}
	CHUDTeamStats[1].maxPlayers = 0
	-- Easier to read for servers parsing the jsons
	CHUDTeamStats[1].teamNumber = 1
	
	CHUDTeamStats[2] = {}
	CHUDTeamStats[2].hits = 0
	CHUDTeamStats[2].misses = 0
	CHUDTeamStats[2].rts = {lost = 0, built = 0}
	CHUDTeamStats[2].maxPlayers = 0
	-- Easier to read for servers parsing the jsons
	CHUDTeamStats[2].teamNumber = 2

	CHUDResearchTree = {}
	
	CHUDBuildingSummary = {}
	CHUDBuildingSummary[1] = {}
	CHUDBuildingSummary[2] = {}
	
	CHUDExportResearch = {}
	CHUDExportBuilding = {}
	
	-- Do this so we can spawn items without a commander with cheats on
	CHUDMarineComm = 0
	CHUDResetCommStats(0)

	CHUDHiveSkillGraph = {}
	
	for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do

		local teamNumber = playerInfo.teamNumber
		local steamId = playerInfo.steamId

		if playerInfo.isCommander then
			if teamNumber == kTeam1Index then
				CHUDMarineComm = steamId
				CHUDResetCommStats(steamId)
			end
			-- Init the commander player stats so they show up at the end-game stats
			MaybeInitCHUDClientStats(steamId, nil, teamNumber)
		end

		if teamNumber == kTeam1Index or teamNumber == kTeam2Index then
			table.insert(CHUDHiveSkillGraph, { gameMinute = 0, joined = true, teamNumber = teamNumber, steamId = steamId } )
		end

	end
end

local oldResetGame
oldResetGame = Class_ReplaceMethod("NS2Gamerules", "ResetGame",
	function(self)
		-- Reset the stats before the actual game so we can get the RT counts correctly
		CHUDResetStats()
		
		oldResetGame(self)
		
		-- Add the team player counts on game reset
		CHUDTeamStats[1].maxPlayers = math.max(0, self.team1:GetNumPlayers())
		CHUDTeamStats[2].maxPlayers = math.max(0, self.team2:GetNumPlayers())
		
		-- Starting tech points
		CHUDStartingTechPoints["1"] = locationsLookup[self.startingLocationNameTeam1]
		CHUDStartingTechPoints["2"] = locationsLookup[self.startingLocationNameTeam2]
	end)

local function CHUDGetAccuracy(hits, misses, onosHits)
	local accuracy = 0
	local accuracyOnos = ConditionalValue(onosHits == 0, -1, 0)
	
	if hits > 0 or misses > 0 then
		accuracy = hits/(hits+misses)*100
		if onosHits and onosHits > 0 and hits ~= onosHits then
			accuracyOnos = (hits-onosHits)/((hits-onosHits)+misses)*100
		end
	end
	
	return accuracy, accuracyOnos
end

local originalCommandStructureLoginPlayer
originalCommandStructureLoginPlayer = Class_ReplaceMethod("CommandStructure", "LoginPlayer",
	function(self, player, forced)
	
		originalCommandStructureLoginPlayer(self, player, forced)
		
		local teamNumber = player:isa("Marine") and 1 or player:isa("Alien") and 2 or -1
		
		-- Init the player stats in case they haven't attacked at all so they still show up in the stats
		MaybeInitCHUDClientStats(GetSteamIdForClientIndex(player.clientIndex), nil, teamNumber)
		
		if teamNumber == kTeam1Index then
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
			-- If the medpack hits immediatly expireTime is 0
			if ConditionalValue(self.expireTime == 0, Shared.GetTime(), self.expireTime - kItemStayTime) + 0.025 > Shared.GetTime() then
				CHUDCommStats[CHUDMarineComm]["medpack"].hitsAcc = CHUDCommStats[CHUDMarineComm]["medpack"].hitsAcc + 1
			end
			CHUDCommStats[CHUDMarineComm]["medpack"].misses = CHUDCommStats[CHUDMarineComm]["medpack"].misses - 1
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
			CHUDCommStats[CHUDMarineComm]["ammopack"].picks = CHUDCommStats[CHUDMarineComm]["ammopack"].picks + 1
			CHUDCommStats[CHUDMarineComm]["ammopack"].refilled = CHUDCommStats[CHUDMarineComm]["ammopack"].refilled + newAmmo - oldAmmo
		end
	
	end)
	
local originalCatPackOnTouch
originalCatPackOnTouch = Class_ReplaceMethod("CatPack", "OnTouch",
	function(self, recipient)
	
		originalCatPackOnTouch(self, recipient)
		CHUDCommStats[CHUDMarineComm]["catpack"].misses = CHUDCommStats[CHUDMarineComm]["catpack"].misses - 1
		CHUDCommStats[CHUDMarineComm]["catpack"].picks = CHUDCommStats[CHUDMarineComm]["catpack"].picks + 1
	
	end)
	
local originalDrifterEggHatch
originalDrifterEggHatch = Class_ReplaceMethod("DrifterEgg", "Hatch",
	function(self)
		originalDrifterEggHatch(self)
		
		AddBuildingStat(self:GetTeamNumber(), kTechId.Drifter, false)
		AddExportBuilding(self:GetTeamNumber(), kTechId.Drifter, true, false, false) -- Drifter Hatch 100
	end)
	
local originalNS2GamerulesEndGame
originalNS2GamerulesEndGame = Class_ReplaceMethod("NS2Gamerules", "EndGame",
	function(self, winningTeam)
		local newCommStatsTable = {}
		for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
			local client = Server.GetClientById(playerInfo.clientId)
			
			-- Commander stats
			if CHUDCommStats[playerInfo.steamId] and client then
				if playerInfo.steamId ~= 0 then
					newCommStatsTable[playerInfo.steamId] = CHUDCommStats[playerInfo.steamId]
				end
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
					if stats.picks and stats.picks > 0 or stats.misses and stats.misses > 0 then
						if index == "medpack" then
							-- Add medpacks that were picked up later to the misses count for accuracy
							msg.medpackAccuracy = CHUDGetAccuracy(stats.hitsAcc, (stats.picks-stats.hitsAcc)+stats.misses)
							msg.medpackResUsed = stats.picks*kMedPackCost
							msg.medpackResExpired = stats.misses*kMedPackCost
							msg.medpackEfficiency = CHUDGetAccuracy(stats.picks, stats.misses)
							msg.medpackRefill = stats.refilled
						elseif index == "ammopack" then
							msg.ammopackResUsed = stats.picks*kAmmoPackCost
							msg.ammopackResExpired = stats.misses*kAmmoPackCost
							msg.ammopackEfficiency = CHUDGetAccuracy(stats.picks, stats.misses)
							msg.ammopackRefill = stats.refilled
						elseif index == "catpack" then
							msg.catpackResUsed = stats.picks*kCatPackCost
							msg.catpackResExpired = stats.misses*kCatPackCost
							msg.catpackEfficiency = CHUDGetAccuracy(stats.picks, stats.misses)
						end
					end
				end
				
				Server.SendNetworkMessage(client, "CHUDMarineCommStats", msg, true)
			end
			
			-- Player stats
			if CHUDClientStats[playerInfo.steamId] and client then
				local stats = CHUDClientStats[playerInfo.steamId]
				
				-- Easier format for easy parsing server-side
				local newWeaponsTable = {}
				for wTechId, wStats in pairs(stats["weapons"]) do
					local accuracy, accuracyOnos = CHUDGetAccuracy(wStats.hits, wStats.misses, wStats.onosHits)
					
					local msg = {}
					msg.wTechId = wTechId
					msg.accuracy = accuracy
					msg.accuracyOnos = accuracyOnos
					msg.kills = wStats.kills
					msg.pdmg = wStats.pdmg
					msg.sdmg = wStats.sdmg
					msg.teamNumber = wStats.teamNumber
					--Log("NS2+ %s : %s -> %s", wTechId, wStats, msg ) 
					Server.SendNetworkMessage(client, "CHUDEndStatsWeapon", msg, true)
					
					-- Use more consistent naming for exported stats
					wStats.playerDamage = wStats.pdmg
					wStats.structureDamage = wStats.sdmg
					wStats.pdmg = nil
					wStats.sdmg = nil
					newWeaponsTable[EnumToString(kTechId, wTechId)] = wStats
				end
				stats["weapons"] = newWeaponsTable
				
				-- Easier format for easy parsing server-side
				local newStatusTable = {}
				for statusId, classTime in pairs(stats["status"]) do
					local msg = {}
					msg.statusId = statusId
					msg.timeMinutes = classTime/60
					
					table.insert(newStatusTable, {statusId = EnumToString(kPlayerStatus, statusId), classTime = classTime})
					Server.SendNetworkMessage(client, "CHUDEndStatsStatus", msg, true)
				end
				stats["status"] = newStatusTable
			end
		
		end

		local finalStats = {}
		finalStats[1] = {}
		finalStats[2] = {}
		
		for steamId, stats in pairs(CHUDClientStats) do
			local tmp = {}
			table.insert(tmp, stats[1])
			table.insert(tmp, stats[2])
			for teamNumber, entry in pairs(tmp) do
				if entry.timePlayed and entry.timePlayed > 0 then
					local statEntry = {}
					
					local accuracy, accuracyOnos = CHUDGetAccuracy(entry.hits, entry.misses, entry.onosHits)
					
					statEntry.isMarine = teamNumber == 1
					statEntry.playerName = stats.playerName
					statEntry.hiveSkill = stats.hiveSkill
					statEntry.kills = entry.kills
					statEntry.killstreak = entry.killstreak
					statEntry.assists = entry.assists
					statEntry.deaths = entry.deaths
					statEntry.score = entry.score
					statEntry.accuracy = accuracy
					statEntry.accuracyOnos = accuracyOnos
					statEntry.pdmg = entry.pdmg
					statEntry.sdmg = entry.sdmg
					statEntry.minutesBuilding = entry.timeBuilding/60
					statEntry.minutesPlaying = entry.timePlayed/60
					statEntry.minutesComm = entry.commanderTime/60
					statEntry.isRookie = entry.isRookie
					statEntry.steamId = steamId
					
					if teamNumber == 1 then
						table.insert(finalStats[1], statEntry)
					elseif teamNumber == 2 then
						table.insert(finalStats[2], statEntry)
					end
				end
				-- Use more consistent naming for exported stats
				entry.playerDamage = entry.pdmg
				entry.structureDamage = entry.sdmg
				entry.pdmg = nil
				entry.sdmg = nil
			end
			-- Remove last life stats and last update time from exported data
			stats.last = nil
			stats.lastUpdate = nil
		end
		
		local team1Accuracy, team1OnosAccuracy = CHUDGetAccuracy(CHUDTeamStats[1].hits, CHUDTeamStats[1].misses, CHUDTeamStats[1].onosHits)
		local team2Accuracy = CHUDGetAccuracy(CHUDTeamStats[2].hits, CHUDTeamStats[2].misses)
		
		local msg = {}
		msg.marineAcc = team1Accuracy
		msg.marineOnosAcc = team1OnosAccuracy
		msg.marineRTsBuilt = CHUDTeamStats[1]["rts"].built
		msg.marineRTsLost = CHUDTeamStats[1]["rts"].lost
		msg.alienAcc = team2Accuracy
		msg.alienRTsBuilt = CHUDTeamStats[2]["rts"].built
		msg.alienRTsLost = CHUDTeamStats[2]["rts"].lost
		msg.gameLengthMinutes = CHUDGetGameTime(true)
		
		-- Don't send the round data if there's no player data
		if #finalStats[1] > 0 or #finalStats[2] > 0 then
			Server.SendNetworkMessage("CHUDGameData", msg, true)
			
			for _, entry in ipairs(CHUDResearchTree) do
				-- Exclude the initial buildings (finishedMinute is 0 and teamRes is 0)
				if entry.finishedMinute > 0 or entry.teamRes > 0 then
					Server.SendNetworkMessage("CHUDTechLog", entry, true)
				end
			end
			
			for _, entry in ipairs(CHUDHiveSkillGraph) do
				Server.SendNetworkMessage("CHUDHiveSkillGraph", entry, true)
			end

			for _, entry in ipairs(CHUDRTGraph) do
				Server.SendNetworkMessage("CHUDRTGraph", entry, true)
			end
			
			for _, entry in ipairs(CHUDKillGraph) do
				Server.SendNetworkMessage("CHUDKillGraph", entry, true)
				-- Remove the game minute so it doesn't get exported
				entry.gameMinute = nil
			end
			
			local newBuildingSummaryTable = {}
			for teamNumber, team in pairs(CHUDBuildingSummary) do
				for techId, entry in pairs(team) do
						local msg = {}
						msg.teamNumber = teamNumber
						msg.techId = techId
						msg.built = entry.built
						msg.lost = entry.lost
						Server.SendNetworkMessage("CHUDBuildingSummary", msg, true)
						
						msg.techId = EnumToString(kTechId, techId)
						table.insert(newBuildingSummaryTable, msg)
				end
			end
			CHUDBuildingSummary = newBuildingSummaryTable
		end
		
		for _, finalStat in ipairs(finalStats) do
			for _, entry in ipairs(finalStat) do
				Server.SendNetworkMessage("CHUDPlayerStats", entry, true)
			end
		end
		
		local medpackHitsAcc = 0
		local medpackMisses = 0
		local medpackPicks = 0
		local medpackRefill = 0
		local ammopackPicks = 0
		local ammopackMisses = 0
		local ammopackRefill = 0
		local catpackPicks = 0
		local catpackMisses = 0
		local sendCommStats = false
		
		for _, playerStats in pairs(CHUDCommStats) do
			for index, stats in pairs(playerStats) do
				if stats.picks and stats.picks > 0 or stats.misses and stats.misses > 0 then
					sendCommStats = true
					if index == "medpack" then
						medpackHitsAcc = medpackHitsAcc + stats.hitsAcc
						medpackPicks = medpackPicks + stats.picks
						medpackMisses = medpackMisses + stats.misses
						medpackRefill = medpackRefill + stats.refilled
					elseif index == "ammopack" then
						ammopackPicks = ammopackPicks + stats.picks
						ammopackMisses = ammopackMisses + stats.misses
						ammopackRefill = ammopackRefill + stats.refilled
					elseif index == "catpack" then
						catpackPicks = catpackPicks + stats.picks
						catpackMisses = catpackMisses + stats.misses
					end
				end
			end
		end
		
		if sendCommStats then
			local msg = {}
			msg.medpackAccuracy = CHUDGetAccuracy(medpackHitsAcc, (medpackPicks-medpackHitsAcc)+medpackMisses)
			msg.medpackResUsed = medpackPicks
			msg.medpackResExpired = medpackMisses
			msg.medpackEfficiency = CHUDGetAccuracy(medpackPicks, medpackMisses)
			msg.medpackRefill = medpackRefill
			msg.ammopackResUsed = ammopackPicks
			msg.ammopackResExpired = ammopackMisses
			msg.ammopackEfficiency = CHUDGetAccuracy(ammopackPicks, ammopackMisses)
			msg.ammopackRefill = ammopackRefill
			msg.catpackResUsed = catpackPicks
			msg.catpackResExpired = catpackMisses
			msg.catpackEfficiency = CHUDGetAccuracy(catpackPicks, catpackMisses)
			
			Server.SendNetworkMessage("CHUDGlobalCommStats", msg, true)
		end
		
		-- Don't save the round data if there's no player data
		if #finalStats[1] > 0 or #finalStats[2] > 0 then
			lastRoundStats = {}
			lastRoundStats.MarineCommStats = CHUDCopyTable(newCommStatsTable)
			lastRoundStats.PlayerStats = CHUDCopyTable(CHUDClientStats)
			lastRoundStats.KillFeed = CHUDCopyTable(CHUDKillGraph)
			lastRoundStats.ServerInfo = {}
			lastRoundStats.ServerInfo["ip"] = Server.GetIpAddress()
			lastRoundStats.ServerInfo["port"] = Server.GetPort()
			lastRoundStats.ServerInfo["name"] = Server.GetName()
			lastRoundStats.ServerInfo["slots"] = Server.GetMaxPlayers()
			lastRoundStats.ServerInfo["buildNumber"] = Shared.GetBuildNumber()
			lastRoundStats.ServerInfo["rookieOnly"] = Server.GetHasTag("rookie_only")
			lastRoundStats.ServerInfo["mods"] = {}
			local modNum
			local activeModIds = {}

			-- Can't get the mod title correctly unless we do this
			-- GetModTitle can't get it from the active mod list index, it uses the normal one
			for modNum = 1, Server.GetNumActiveMods() do
				activeModIds[Server.GetActiveModId(modNum)] = true
			end
			for modNum = 1, Server.GetNumMods() do
				if activeModIds[Server.GetModId(modNum)] then
					table.insert(lastRoundStats.ServerInfo["mods"], {modId = Server.GetModId(modNum), name = Server.GetModTitle(modNum)})
				end
			end
			lastRoundStats.RoundInfo = {}
			lastRoundStats.RoundInfo["mapName"] = Shared.GetMapName()
			lastRoundStats.RoundInfo["minimapExtents"] = minimapExtents
			lastRoundStats.RoundInfo["roundDate"] = Shared.GetSystemTime()
			lastRoundStats.RoundInfo["roundLength"] = CHUDGetGameTime()
			lastRoundStats.RoundInfo["startingLocations"] = CHUDCopyTable(CHUDStartingTechPoints)
			lastRoundStats.RoundInfo["winningTeam"] = winningTeam and winningTeam.GetTeamType and winningTeam:GetTeamType() or kNeutralTeamType
			lastRoundStats.RoundInfo["tournamentMode"] = GetTournamentModeEnabled()
			lastRoundStats.RoundInfo["maxPlayers1"] = CHUDTeamStats[1].maxPlayers
			lastRoundStats.RoundInfo["maxPlayers2"] = CHUDTeamStats[2].maxPlayers
			lastRoundStats.Locations = locationsTable
			lastRoundStats.Buildings = CHUDCopyTable(CHUDExportBuilding)
			lastRoundStats.Research = CHUDCopyTable(CHUDExportResearch)

			if CHUDServerOptions["savestats"].currentValue == true then
				local savedServerFile = io.open("config://" .. serverStatsPath .. Shared.GetSystemTime() .. ".json", "w+")
				if savedServerFile then
					savedServerFile:write(json.encode(lastRoundStats, { indent = true }))
					io.close(savedServerFile)
				end
			end
		end
		
		originalNS2GamerulesEndGame(self, winningTeam)
	end)


local oldPreOnKill 
local function NS2PlusPlayerPreOnKill(self, killer, doer, point, direction)
	if oldPreOnKill then
		oldPreOnKill( self, killer, doer, point, direction )
	end

	-- Send stats to the player on death
	if CHUDGetGameStarted() then
		local steamId = GetSteamIdForClientIndex(self:GetClientIndex())
		if steamId and steamId > 0 then
			local teamNumber = self:GetTeamNumber()
			MaybeInitCHUDClientStats(steamId, nil, teamNumber)
			if CHUDClientStats[steamId] then
				local lastStat = CHUDClientStats[steamId]["last"]
				local totalStats = CHUDClientStats[steamId]["weapons"]
				local msg = {}
				local lastAcc = 0
				local lastAccOnos = 0
				local currentAcc = 0
				local currentAccOnos = 0
				local hitssum = 0
				local missessum = 0
				local onossum = 0
				
				for _, wStats in pairs(totalStats) do
					-- Display current accuracy for the current team's weapons
					if wStats.teamNumber == teamNumber then
						hitssum = hitssum + wStats.hits
						onossum = onossum + wStats.onosHits
						missessum = missessum + wStats.misses
					end
				end
				
				if lastStat.hits > 0 or lastStat.misses > 0 then
					lastAcc, lastAccOnos = CHUDGetAccuracy(lastStat.hits, lastStat.misses, lastStat.onosHits)
				end
				
				if hitssum > 0 or missessum > 0 then
					currentAcc, currentAccOnos = CHUDGetAccuracy(hitssum, missessum, onossum)
				end
				
				if lastStat.hits > 0 or lastStat.misses > 0 or lastStat.pdmg > 0 or lastStat.sdmg > 0 then
					msg.lastAcc = lastAcc
					msg.lastAccOnos = lastAccOnos
					msg.currentAcc = currentAcc
					msg.currentAccOnos = currentAccOnos
					msg.pdmg = lastStat.pdmg
					msg.sdmg = lastStat.sdmg
					msg.kills = lastStat.kills
					
					Server.SendNetworkMessage(Server.GetOwner(self), "CHUDDeathStats", msg, true)
				end
			end
			ResetCHUDLastLifeStats(steamId)
		end
		
		local targetTeam = self.GetTeamNumber and self:GetTeamNumber() or 0
		
		-- Now save the attacker weapon
		local killerSteamId, killerWeapon, killerTeam = GetAttackerWeapon(killer, doer)
		
		if not self.isHallucination then
			if killerSteamId and killerTeam ~= targetTeam then
				AddWeaponKill(killerSteamId, killerWeapon, killerTeam)
			end
			-- If there's a teamkill or a death by natural causes, award the kill to the other team
			if killerTeam == targetTeam or killerTeam == nil then
				if targetTeam == 1 then
					killerTeam = 2
				else
					killerTeam = 1
				end
			end
			AddTeamGraphKill(killerTeam, killer, self, killerWeapon, doer)
		end
	end
	
end

if Player.PreOnKill then
	oldPreOnKill = Class_ReplaceMethod("Player", "PreOnKill", NS2PlusPlayerPreOnKill )
else
	Class_AddMethod("Player","PreOnKill", NS2PlusPlayerPreOnKill )
end

local originalConstructMixinConstruct = ConstructMixin.Construct
function ConstructMixin:Construct(elapsedTime, builder)

	local success, playAV = originalConstructMixinConstruct(self, elapsedTime, builder)
	local steamId
	
	if builder and builder:isa("Player") then
		steamId = GetSteamIdForClientIndex(builder:GetClientIndex())
	end

	if success and steamId then
		AddBuildTime(steamId, elapsedTime, builder:GetTeamNumber())
	end

end

local originalConstructMixinOnKill = ConstructMixin.OnKill
function ConstructMixin:OnKill()
	local extraInfo
	if self:isa("Hive") and self:GetIsBuilt() then
		extraInfo = {name = "biomass", value = self:GetTeam():GetBioMassLevel()-self:GetBioMassLevel()}
	end
	AddExportBuilding(self:GetTeamNumber(), self.GetTechId and self:GetTechId(), self:GetIsBuilt(),  true, false, extraInfo)  -- Killed structure ?10
	originalConstructMixinOnKill(self)
end

local originalAttackMeleeCapsule = AttackMeleeCapsule
function AttackMeleeCapsule(weapon, player, damage, range, optionalCoords, altMode, filter)
	local a, target, c, d, e , f = originalAttackMeleeCapsule(weapon, player, damage, range, optionalCoords, altMode, filter)
	if weapon and weapon.GetTechId and weapon.GetParent and weapon:GetParent() then
		-- Drifters, buildings and teammates don't count towards accuracy as hits or misses
		if (target and target:isa("Player") and GetAreEnemies(weapon:GetParent(), target)) or target == nil then
			local steamId = weapon:GetParent():GetSteamId()
			if steamId then
				AddAccuracyStat(steamId, weapon:GetTechId(), target ~= nil, target and target:isa("Onos"), weapon:GetParent():GetTeamNumber())
			end
		end
	end

	return a, target, c, d, e , f
end

local originalBulletsMixinApplyBulletGameplayEffects = BulletsMixin.ApplyBulletGameplayEffects
function BulletsMixin:ApplyBulletGameplayEffects(player, target, endPoint, direction, damage, surface, showTracer)
	if self and self.GetTechId and self.GetParent and self:GetParent() then
		-- Drifters, buildings and teammates don't count towards accuracy as hits or misses
		if (target and target:isa("Player") and GetAreEnemies(self:GetParent(), target)) or target == nil then
			local steamId = GetSteamIdForClientIndex(self:GetParent():GetClientIndex())
			if steamId then
				AddAccuracyStat(steamId, self:GetTechId(), target ~= nil, target and target:isa("Onos"), self:GetParent():GetTeamNumber())
			end
		end
	end
	
	originalBulletsMixinApplyBulletGameplayEffects(self, player, target, endPoint, direction, damage, surface, showTracer)
end

local kChargeTime, kBulletSize
local function NewExecuteShot(self, startPoint, endPoint, player)
	-- Filter ourself out of the trace so that we don't hit ourselves.
	local filter = EntityFilterTwo(player, self)
	local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))
	local hitPointOffset = trace.normal * 0.3
	local direction = (endPoint - startPoint):GetUnit()
	local damage = kRailgunDamage + math.min(1, (Shared.GetTime() - self.timeChargeStarted) / kChargeTime) * kRailgunChargeDamage
	local parent = self.GetParent and self:GetParent()
	local extents = GetDirectedExtentsForDiameter(direction, kBulletSize)
	
	if parent and trace.fraction < 1 then
	
		-- do a max of 10 capsule traces, should be sufficient
		local hitEntities = {}
		local isPlayer = false
		local playerTargets = 0
		local foundOnos = false
		
		for i = 1, 20 do
		
			local capsuleTrace = Shared.TraceBox(extents, startPoint, trace.endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
			if capsuleTrace.entity then
			
				if not table.find(hitEntities, capsuleTrace.entity) then
				
					if capsuleTrace.entity:isa("Player") and GetAreEnemies(parent, capsuleTrace.entity) then
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
			
			-- use new start point
			startPoint = Vector(capsuleTrace.endPoint) + direction * extents.x * 3
		
		end

		-- Drifters, buildings and teammates don't count towards accuracy as hits or misses
		if #hitEntities == 0 or (#hitEntities > 0 and isPlayer) then
			local steamId = GetSteamIdForClientIndex(parent:GetClientIndex())
			if steamId then
				AddAccuracyStat(steamId, self:GetTechId(), #hitEntities > 0, playerTargets == 1 and foundOnos, parent:GetTeamNumber())
			end
		end
		
		-- for tracer
		local effectFrequency = self:GetTracerEffectFrequency()
		local showTracer = ConditionalValue(GetIsVortexed(player), false, math.random() < effectFrequency)
		self:DoDamage(0, nil, trace.endPoint + hitPointOffset, direction, trace.surface, false, showTracer)
		
		if Client and showTracer then
			TriggerFirstPersonTracer(self, trace.endPoint)
		end
	
	end
end
debug.replaceupvalue(Railgun.OnTag, "ExecuteShot", NewExecuteShot, true)

local originalParasiteAttack, kRange, kParasiteSize
originalParasiteAttack = Class_ReplaceMethod( "Parasite", "PerformPrimaryAttack",
	function(self, player)
		self.activity = Parasite.kActivity.Primary
		self.primaryAttacking = true
		local parent = self.GetParent and self:GetParent()
		local success = false

		if parent and not self.blocked then
		
			self.blocked = true
			
			success = true
			
			self:TriggerEffects("parasite_attack")
			
			-- Trace ahead to see if hit enemy player or structure

			local viewCoords = player:GetViewAngles():GetCoords()
			local startPoint = player:GetEyePos()
		
			-- double trace; first as a ray to allow us to hit through narrow openings, then as a fat box if the first one misses
			local trace = Shared.TraceRay(startPoint, startPoint + viewCoords.zAxis * kRange, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
			if not trace.entity then
				local extents = GetDirectedExtentsForDiameter(viewCoords.zAxis, kParasiteSize)
				trace = Shared.TraceBox(extents, startPoint, startPoint + viewCoords.zAxis * kRange, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
			end
			
			if trace.fraction < 1 then
			
				local hitObject = trace.entity
				local direction = GetNormalizedVector(trace.endPoint - startPoint)
				local impactPoint = trace.endPoint - direction * kHitEffectOffset
				
				if (hitObject and hitObject:isa("Player") and GetAreEnemies(parent, hitObject)) then
					local steamId = GetSteamIdForClientIndex(parent:GetClientIndex())
					if steamId then
						AddAccuracyStat(steamId, self:GetTechId(), true, hitObject and hitObject:isa("Onos"), parent:GetTeamNumber())
					end
				end
				
				self:DoDamage(kParasiteDamage, hitObject, impactPoint, direction)
				
			end
			
			if not trace.entity then
				local steamId = GetSteamIdForClientIndex(parent:GetClientIndex())
				if steamId then
					AddAccuracyStat(steamId, self:GetTechId(), false, nil, parent:GetTeamNumber())
				end
			end
			
		end
		
		return success
	end)
debug.joinupvalues(Parasite.PerformPrimaryAttack, originalParasiteAttack)
	
local kSpread, kSpikeSize
local function NewFireSpikes(self)
	local player = self:GetParent()    
	local viewAngles = player:GetViewAngles()
	viewAngles.roll = NetworkRandom() * math.pi * 2
	local shootCoords = viewAngles:GetCoords()
	
	-- Filter ourself out of the trace so that we don't hit ourselves.
	local filter = EntityFilterOneAndIsa(player, "Babbler")
	local range = kSpikesRange
	
	local numSpikes = kSpikesPerShot
	local startPoint = player:GetEyePos()
	
	local viewCoords = player:GetViewCoords()
	
	self.spiked = true
	self.silenced = GetHasSilenceUpgrade(player)
	
	for spike = 1, numSpikes do

		-- Calculate spread for each shot, in case they differ    
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

			-- Have damage increase to reward close combat
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
debug.replaceupvalue(SpikesMixin.OnTag, "FireSpikes", NewFireSpikes, true)

local originalSpitProcessHit
originalSpitProcessHit = Class_ReplaceMethod( "Spit", "ProcessHit",
	function(self, targetHit, surface, normal, hitPoint)

		local player = self:GetOwner()
		if player then
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
		end
		-- An actual attack I can hook semi-properly :_)
		originalSpitProcessHit(self, targetHit, surface, normal, hitPoint)

	end)

local originalSpitTimeUp
originalSpitTimeUp = Class_ReplaceMethod( "Spit", "TimeUp",
	function(self)
		local player = self:GetOwner()
		if player then
			local steamId = GetSteamIdForClientIndex(player:GetClientIndex())
			if steamId then
				AddAccuracyStat(steamId, self:GetWeaponTechId(), false, false, player:GetTeamNumber())
			end
		end
	
		originalSpitTimeUp(self)
	end)
	
-- Initialize the arrays
CHUDResetStats()
