originalGetUnitHint = UnitStatusMixin.GetUnitHint
function UnitStatusMixin:GetUnitHint(forEntity)
	
	local player = Client.GetLocalPlayer()
	
	if HasMixin(self, "Live") and (not self.GetShowHealthFor or self:GetShowHealthFor(player)) and CHUDHint then
	
		local hintTable = { }
		
		hintTable.Hint = originalGetUnitHint(self, forEntity)
		
		local status = string.format("%d/%d",math.max(1, math.ceil(self:GetHealth())),math.ceil(self:GetArmor()))
		if self:isa("Exo") then
			status = string.format("%d",math.max(1, math.ceil(self:GetArmor())))
		end
		hintTable.Status = status
		
		if (self:GetMapName() ~= TechPoint.kMapName and self:GetMapName() ~= ResourcePoint.kPointMapName) then
			if not self:isa("Player") or (self:isa("Embryo") and GetAreEnemies(player, self)) then
				hintTable.Percentage = string.format("%d%%",math.max(1, math.ceil(self:GetHealthScalar()*100)))
			end
		end
		
		if self:isa("Marine") then
			hintTable.HasWelder = self:GetHasWelder(player)
		end
		
		return hintTable
	end
	
	return hint
end