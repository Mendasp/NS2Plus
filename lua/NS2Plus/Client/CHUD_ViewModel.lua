local originalViewModelOnUpdateRender
originalViewModelOnUpdateRender = Class_ReplaceMethod("ViewModel", "OnUpdateRender",
	function(self)
		originalViewModelOnUpdateRender(self)
		
		local player = Client.GetLocalPlayer()
		if player and player:isa("Marine") then
			self:SetIsVisible(self:GetIsVisible() and CHUDGetOption("drawviewmodel"))
		end
	end)