local originalDissolveMixinOnKillClient = DissolveMixin.OnKillClient
function DissolveMixin:OnKillClient()
	originalDissolveMixinOnKillClient(self)
	self.dissolveStart = Shared.GetTime() + ConditionalValue(CHUDGetOption("instantdissolve"), 0, 6)
end