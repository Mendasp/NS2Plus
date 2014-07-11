AppendToEnum( kMinimapBlipType, "UnsocketedPowerPoint" )
AppendToEnum( kMinimapBlipType, "BlueprintPowerPoint" )

local originalGetMapBlipInfo = MapBlipMixin.GetMapBlipInfo
function MapBlipMixin:GetMapBlipInfo()
	if self:isa("PowerPoint") then
		if self.OnGetMapBlipInfo then
			return self:OnGetMapBlipInfo()
		end

		local blipType = kMinimapBlipType.Undefined
		local blipTeam = self:GetTeamNumber()
		local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
		local isParasited = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
		
		if self:GetIsDisabled() then
			blipType = kMinimapBlipType.DestroyedPowerPoint
		elseif self:GetCanTakeDamageOverride() then
			blipType = kMinimapBlipType.PowerPoint
		elseif self:GetIsSocketed() then
			blipType = kMinimapBlipType.BlueprintPowerPoint
		else
			blipType = kMinimapBlipType.UnsocketedPowerPoint
		end
		
		return true, blipType, blipTeam, isAttacked, isParasited
	else
		return originalGetMapBlipInfo(self)
	end
end

if Server then
	local originalPowerPointSetInternalPowerState
	originalPowerPointSetInternalPowerState = Class_ReplaceMethod( "PowerPoint", "SetInternalPowerState",
		function(self, powerState)
			-- Mark the mapblip dirty when switching from unsocketed to socketed so we can see the change
			if self.powerState == PowerPoint.kPowerState.unsocketed and powerState == PowerPoint.kPowerState.socketed and self.MarkBlipDirty then
				self:MarkBlipDirty()
			end
			
			originalPowerPointSetInternalPowerState(self, powerState)
		end)
end