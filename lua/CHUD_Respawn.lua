local function OnCommandChangeClass(className, teamNumber, extraValues)

    return function(client)
    
        local player = client:GetControllingPlayer()
        if Shared.GetCheatsEnabled() and player:GetTeamNumber() == teamNumber then

			local newPlayer = player:Replace(className, player:GetTeamNumber(), nil, player.lastDeathPos, extraValues)
			
			newPlayer:SetDesiredCameraDistance(0)
        end
        
    end
    
end

Event.Hook("Console_skulk", OnCommandChangeClass("skulk", kTeam2Index))
Event.Hook("Console_gorge", OnCommandChangeClass("gorge", kTeam2Index))
Event.Hook("Console_lerk", OnCommandChangeClass("lerk", kTeam2Index))
Event.Hook("Console_fade", OnCommandChangeClass("fade", kTeam2Index))
Event.Hook("Console_onos", OnCommandChangeClass("onos", kTeam2Index))
Event.Hook("Console_marine", OnCommandChangeClass("marine", kTeam1Index))
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

local originalCopyPlayerData
	
originalCopyPlayerData = Class_ReplaceMethod("Player", "CopyPlayerDataFrom",
	function (self, player)
		self.lastDeathPos = player.lastDeathPos

		originalCopyPlayerData(self, player)
	end)