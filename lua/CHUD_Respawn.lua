local function OnCommandChangeClass(className, teamNumber, extraValues)

    return function(client)
    
        local player = client:GetControllingPlayer()
        if Shared.GetCheatsEnabled() and player:GetTeamNumber() == teamNumber then
			local newPlayer = player:Replace(className, player:GetTeamNumber(), nil, player.lastDeathPos, extraValues)
			
			newPlayer:SetDesiredCameraDistance(0)

			// Turns out if you give weapons to exos the game implodes! Who would've thought!
			if teamNumber == kTeam1Index and (className == "marine" or className == "jetpackmarine") and newPlayer.lastWeaponList then
				// Restore weapons in reverse order so the main weapons gets selected on respawn
				for i = #newPlayer.lastWeaponList, 1, -1 do
					if newPlayer.lastWeaponList[i] ~= "axe" then
						newPlayer:GiveItem(newPlayer.lastWeaponList[i])
					end
				end
			end
			
			if teamNumber == kTeam2Index and newPlayer.lastUpgradeList then			
				// I have no idea if this will break, but I don't care!
				// Thug life!
				// Ghetto code incoming, you've been warned
				newPlayer.upgrade1 = newPlayer.lastUpgradeList[1] or 1
				newPlayer.upgrade2 = newPlayer.lastUpgradeList[2] or 1
				newPlayer.upgrade3 = newPlayer.lastUpgradeList[3] or 1
			end
			
        end
        
    end
    
end

Event.Hook("Console_skulk", OnCommandChangeClass("skulk", kTeam2Index))
Event.Hook("Console_gorge", OnCommandChangeClass("gorge", kTeam2Index))
Event.Hook("Console_lerk", OnCommandChangeClass("lerk", kTeam2Index))
Event.Hook("Console_fade", OnCommandChangeClass("fade", kTeam2Index))
Event.Hook("Console_onos", OnCommandChangeClass("onos", kTeam2Index))
Event.Hook("Console_marine", OnCommandChangeClass("marine", kTeam1Index))
Event.Hook("Console_jetpack", OnCommandChangeClass("jetpackmarine", kTeam1Index))
Event.Hook("Console_exo", OnCommandChangeClass("exo", kTeam1Index, { layout = "ClawMinigun" }))
Event.Hook("Console_dualminigun", OnCommandChangeClass("exo", kTeam1Index, { layout = "MinigunMinigun" }))
Event.Hook("Console_clawrailgun", OnCommandChangeClass("exo", kTeam1Index, { layout = "ClawRailgun" }))
Event.Hook("Console_dualrailgun", OnCommandChangeClass("exo", kTeam1Index, { layout = "RailgunRailgun" }))

local originalPlayerOnKill

originalPlayerOnKill = Class_ReplaceMethod("Player", "OnKill",
	function (self, killer, doer, point, direction)
		originalPlayerOnKill(self, killer, doer, point, direction)
		
		// Save position of last death only if we didn't die to a DeathTrigger
		// Also save if the player killed himself
		if (killer and not killer:isa("DeathTrigger")) or (doer and not doer:isa("DeathTrigger")) or (not killer and not doer) then
			self.lastDeathPos = self:GetOrigin()
		end
		
	end)
	
local originalMarineOnKill

originalMarineOnKill = Class_ReplaceMethod("Marine", "OnKill",
	function (self, attacker, doer, point, direction)

		if self.teamNumber == kTeam1Index then
			local lastWeaponList = self:GetHUDOrderedWeaponList()
			self.lastWeaponList = { }
			for _, weapon in pairs(lastWeaponList) do
				table.insert(self.lastWeaponList, weapon:GetMapName())
				// If cheats are enabled, destroy the weapons so they don't drop
				if Shared.GetCheatsEnabled() and weapon:GetIsDroppable() and LookupTechData(weapon:GetTechId(), kTechDataCostKey, 0) > 0 then
					DestroyEntity(weapon)
				end
			end
		end
		
		originalMarineOnKill(self, attacker, doer, point, direction)
		
	end)

local originalCopyPlayerData
	
originalCopyPlayerData = Class_ReplaceMethod("Player", "CopyPlayerDataFrom",
	function (self, player)
		self.lastDeathPos = player.lastDeathPos
		self.lastWeaponList = player.lastWeaponList

		originalCopyPlayerData(self, player)
	end)