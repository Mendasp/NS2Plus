local originalMinimapMoveMixin_CalcMinimapMovePosition = MinimapMoveMixin_CalcMinimapMovePosition

function MinimapMoveMixin_CalcMinimapMovePosition(self, input)
	if CHUDGetOption("overheadsmoothing") then
		return originalMinimapMoveMixin_CalcMinimapMovePosition(self, input)
	else
		local origin = self:GetOrigin()
		local targetDiff = origin - self.minimapTargetPosition
		
		origin = origin - targetDiff
	
		return origin, true
	end
end