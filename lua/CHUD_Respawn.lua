local function OnCommandChangeClass(className, teamNumber, extraValues)

    return function(client)
    
        local player = client:GetControllingPlayer()
        if Shared.GetCheatsEnabled() and player:GetTeamNumber() == teamNumber then
			local newPlayer = player:Replace(className, player:GetTeamNumber(), false, nil, extraValues)
			
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