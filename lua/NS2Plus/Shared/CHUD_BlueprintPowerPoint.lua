AppendToEnum( kMinimapBlipType, "BlueprintPowerPoint" )

local originalGetMapBlipInfo = MapBlipMixin.GetMapBlipInfo
function MapBlipMixin:GetMapBlipInfo()
	if self:isa("PowerPoint") then
		if self.OnGetMapBlipInfo then
			return self:OnGetMapBlipInfo()
		end

		local success = false
		local blipType = kMinimapBlipType.Undefined
		local blipTeam = -1
		local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
		local isParasited = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
		
		blipType = ConditionalValue( self:GetIsDisabled(), kMinimapBlipType.DestroyedPowerPoint, ConditionalValue(self:GetCanTakeDamageOverride(), kMinimapBlipType.PowerPoint, kMinimapBlipType.BlueprintPowerPoint))
		blipTeam = self:GetTeamNumber()
		
		if blipType ~= 0 then
			success = true
		end
		
		return success, blipType, blipTeam, isAttacked, isParasited
	else
		return originalGetMapBlipInfo(self)
	end
end