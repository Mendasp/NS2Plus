function UnitStatusMixin:GetCHUDBlipData(forEntity, hint)
	local nameplates = CHUDGetOption("nameplates") or 0
	if nameplates == 0 then return hint end

	local player = Client.GetLocalPlayer()
	if not HasMixin(self, "Live") or self.GetShowHealthFor and not self:GetShowHealthFor(player) then
		return hint
	end

	local CHUDBlipData = { }

	CHUDBlipData.Hint = hint

	local status = string.format("%d/%d",math.max(1, math.ceil(self:GetHealth())),math.ceil(self:GetArmor()))
	if self:isa("Exo") or self:isa("Exosuit") then
		status = string.format("%d",math.max(1, math.ceil(self:GetArmor())))
	end
	CHUDBlipData.Status = status

	if (self:GetMapName() ~= TechPoint.kMapName and self:GetMapName() ~= ResourcePoint.kPointMapName) then
		if not self:isa("Player") or (self:isa("Embryo") and GetAreEnemies(player, self)) then
			CHUDBlipData.Percentage = string.format("%d%%",math.max(1, math.ceil(self:GetHealthScalar()*100)))
		end
	end

	if self:isa("Marine") then
		CHUDBlipData.HasWelder = self:GetHasWelder(player)
	end

	return CHUDBlipData
end

local originalGetUnitHint = UnitStatusMixin.GetUnitHint
function UnitStatusMixin:GetUnitHint(forEntity)
	local hint = originalGetUnitHint(self, forEntity)
	
	return self:GetCHUDBlipData(forEntity, hint)
end

local oldGetUnitState = UnitStatusMixin.GetUnitState
function UnitStatusMixin:GetUnitState(forEntity)
	local state = oldGetUnitState(self, forEntity)
	if state and state.CHUDBlipData then
		state.CHUDBlipData = self:GetCHUDBlipData(forEntity)
	end

	return state
end