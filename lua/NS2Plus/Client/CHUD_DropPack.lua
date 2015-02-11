local oldDropPackOnInit
oldDropPackOnInit = Class_ReplaceMethod("DropPack", "OnInitialized",
	function(self)
		oldDropPackOnInit(self)
		
		-- Make this show as a pickupable item in the HUD
		Shared.AddTagToEntity(self:GetId(), "Pickupable")
	end)