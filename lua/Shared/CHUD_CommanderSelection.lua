Script.Load("lua/Commander_Selection.lua")
Class_ReplaceMethod( "Commander", "SelectHotkeyGroup", 
	function(self, number)

	if Client then    
		self:SendSelectHotkeyGroupMessage(number)        
	end
	
	local selection = false

	// select entities which match hotgroup, unselect all others
	for _, entity in ipairs(GetEntitiesWithMixin("Selectable")) do
		
		if entity:GetHotGroupNumber() == number and not GetAreEnemies(self, entity) then
			entity:SetSelected(self:GetTeamNumber(), true, true, false)
			selection = true
		else
			entity:SetSelected(self:GetTeamNumber(), false, true, false)
		end
		
	end
	
	UpdateMenuTechId(self:GetTeamNumber(), selection)

	end)