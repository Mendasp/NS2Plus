local SpawnInfantryPortal

function NewMarineTeamSpawnInitialStructures(self,techPoint)

    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)
    
    SpawnInfantryPortal(self, techPoint)
    // Spawn a second IP when marines have 9 or more players
    if self:GetNumPlayers() > 8 then
        SpawnInfantryPortal(self, techPoint)
    end

    if Shared.GetCheatsEnabled() and MarineTeam.gSandboxMode then

        // Pretty dumb way of spawning two things..heh
        local origin = techPoint:GetOrigin()
        local right = techPoint:GetCoords().xAxis
        local forward = techPoint:GetCoords().zAxis
        CreateEntity( AdvancedArmory.kMapName, origin+right*3.5+forward*1.5, kMarineTeamType)
        CreateEntity( PrototypeLab.kMapName, origin+right*3.5-forward*1.5, kMarineTeamType)

    end
    
    return tower, commandStation
    
end

CopyUpValues( NewMarineTeamSpawnInitialStructures, MarineTeam.SpawnInitialStructures )
Class_ReplaceMethod( "MarineTeam", "SpawnInitialStructures", NewMarineTeamSpawnInitialStructures )