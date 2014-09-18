local originalViewModelOnUpdateRender
originalViewModelOnUpdateRender = Class_ReplaceMethod("ViewModel", "OnUpdateRender",
	function(self)
		originalViewModelOnUpdateRender(self)
		
		local player = Client.GetLocalPlayer()
		local isVisible = self:GetIsVisible()
		local drawviewmodel = CHUDGetOption("drawviewmodel")
		local hideViewModel = player and ((drawviewmodel == 3) or (drawviewmodel == 1 and player:isa("Marine")) or (drawviewmodel == 2 and player:isa("Alien")))

		self:SetIsVisible(self:GetIsVisible() and not hideViewModel)

	end)