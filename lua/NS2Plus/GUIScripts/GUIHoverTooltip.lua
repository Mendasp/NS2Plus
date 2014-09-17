local chud_tooltip = PrecacheAsset("ui/chud_tooltip.dds")
local originalTooltipInit
originalTooltipInit = Class_ReplaceMethod("GUIHoverTooltip", "Initialize",
	function(self)
		originalTooltipInit(self)
		
		self.background:SetTexture(chud_tooltip)
	end)