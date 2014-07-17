originalGetUnitHint = UnitStatusMixin.GetUnitHint
function UnitStatusMixin:GetUnitHint(forEntity)
	
	local player = Client.GetLocalPlayer()
	
	if HasMixin(self, "Live") and (not self.GetShowHealthFor or self:GetShowHealthFor(player)) and CHUDHint then
	
		local hintTable = { }
		
		hintTable.Hint = originalGetUnitHint(self, forEntity)
		
		local status = string.format("%d/%d",math.ceil(self:GetHealth()),math.ceil(self:GetArmor()))
		if self:isa("Exo") then
			status = string.format("%d",math.ceil(self:GetArmor()))
		end
		hintTable.Status = status
		
		if (self:GetMapName() ~= TechPoint.kMapName and self:GetMapName() ~= ResourcePoint.kPointMapName) then
			if not self:isa("Player") or (self:isa("Embryo") and GetAreEnemies(player, self)) then
				hintTable.Percentage = string.format("%d%%",math.ceil(self:GetHealthScalar()*100))
			end
		end
		
		if not GetAreEnemies(player, self) then
			if self:isa("Player") and self:isa("Alien") and not self:isa("Hallucination") and not self:isa("Embryo") then
				hintTable.EnergyFraction = self:GetEnergy() / self:GetMaxEnergy()
			end
		end
		
		if self:isa("Weapon") and self.weaponWorldState == true then
			if player:isa("MarineCommander") then
				hintTable.ExpireTime = self.expireTime
			else
				hintTable.IsVisible = false
			end
		end
		
		return hintTable
	end
	
	return hint
end