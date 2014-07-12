function DissolveMixin:OnKillClient()
	// Start the dissolve effect`
	local now = Shared.GetTime()
	self.dissolveStart = now + ConditionalValue(CHUDGetOption("instantdissolve"), 0, 6)
	self:InstanceMaterials()
end