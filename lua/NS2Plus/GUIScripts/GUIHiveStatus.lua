local originalInit
originalInit = Class_ReplaceMethod( "GUIHiveStatus", "Initialize", 
	function(self)
		originalInit(self)
		
		local hivestatus = not CHUDGetOption("hivestatus")
		
		self:SetIsVisible(hivestatus)
	end)

local originalCreateStatusContainer
originalCreateStatusContainer = Class_ReplaceMethod( "GUIHiveStatus", "CreateStatusContainer",
	function(self, slotIdx, locationId)
		originalCreateStatusContainer(self, slotIdx, locationId)
		
		local mingui = not CHUDGetOption("mingui")
		local frameBackground = ConditionalValue(mingui, "ui/alien_hivestatus_frame_bgs.dds", PrecacheAsset("ui/transparent.dds"))
		local locationBackground = ConditionalValue(mingui, "ui/alien_hivestatus_locationname_bg.dds", "ui/transparent.dds")
		
		self.statusSlots[slotIdx].frame:SetTexture(frameBackground)
		self.statusSlots[slotIdx].locationBackground:SetTexture(locationBackground)
	end)