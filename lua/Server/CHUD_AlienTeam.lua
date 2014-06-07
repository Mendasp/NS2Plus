local SortByBioMassAdd = GetUpValue( AlienTeam.UpdateBioMassLevel, "SortByBioMassAdd", { LocateRecurse = true } )
local kBioMassTechIds = GetUpValue( AlienTeam.UpdateBioMassLevel, "kBioMassTechIds", { LocateRecurse = true } )

function AlienTeam:UpdateBioMassLevel()

    local lastBioMassLevel = self.bioMassLevel

    self.bioMassLevel = 0
    self.bioMassAlertLevel = 0
    self.bioMassFraction = 0
    local extraBioMass = 0
    local progress = 0
    

    local ents = GetEntitiesForTeam("Hive", self:GetTeamNumber())
    table.sort(ents, SortByBioMassAdd)

    for index, entity in ipairs(ents) do
    
        if entity:GetIsAlive() then
    
            local currentBioMass = entity:GetBioMassLevel()
            self.bioMassLevel = self.bioMassLevel + currentBioMass



            local bioMassAdd = entity.biomassResearchFraction
            
            if not entity:GetIsBuilt() then
                bioMassAdd = bioMassAdd + entity:GetBuiltFraction()
            end
            
            if index == 1 then
                progress = bioMassAdd
            end
        
            currentBioMass = currentBioMass + bioMassAdd

            
            currentBioMass = currentBioMass * entity:GetHealthScalar()
            
            self.bioMassFraction = self.bioMassFraction + currentBioMass
            
            if Shared.GetTime() - entity:GetTimeLastDamageTaken() < 7 then
                self.bioMassAlertLevel = self.bioMassAlertLevel + currentBioMass
            end

        end
    
    end
    
    if self.techTree then
    
        for i = 1, #kBioMassTechIds do
        
            local techId = kBioMassTechIds[i]
            local techNode = self.techTree:GetTechNode(techId)
            if techNode then
            
                local techNodeProgress = i == self.bioMassLevel + 1 and progress or 0
				
				-- CHUD: Only mark changed if it changed (save 90*num_alien_players bytes per tech update)
				if techNode:GetResearchProgress() ~= techNodeProgress then
					techNode:SetResearchProgress(techNodeProgress)
					self.techTree:SetTechNodeChanged(techNode, string.format("researchProgress = %.2f", techNodeProgress))                 
				end
            
            end
        
        end
    
    end


    if lastBioMassLevel ~= self.bioMassLevel and self.techTree then
        self.techTree:SetTechChanged()
    end
    
    self.maxBioMassLevel = 0
    
    for _, hive in ipairs(GetEntitiesForTeam("Hive", self:GetTeamNumber())) do
    
        if GetIsUnitActive(hive) then
            self.maxBioMassLevel = self.maxBioMassLevel + 3
        end
    
    end
    
end