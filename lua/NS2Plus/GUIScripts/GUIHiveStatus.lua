local originalInit = GUIHiveStatus.Initialize
function GUIHiveStatus:Initialize()
	originalInit(self)

	local hivestatus = CHUDGetOption("hivestatus")

	self:SetIsVisible(hivestatus)
end

local transparent = PrecacheAsset("ui/transparent.dds")
local originalCreateStatusContainer = GUIHiveStatus.CreateStatusContainer
function GUIHiveStatus:CreateStatusContainer(slotIdx, locationId)
	originalCreateStatusContainer(self, slotIdx, locationId)

	local mingui = not CHUDGetOption("mingui")
	local frameBackground = ConditionalValue(mingui, "ui/alien_hivestatus_frame_bgs.dds", transparent)
	local locationBackground = ConditionalValue(mingui, "ui/alien_hivestatus_locationname_bg.dds", transparent)

	self.statusSlots[slotIdx].frame:SetTexture(frameBackground)
	self.statusSlots[slotIdx].locationBackground:SetTexture(locationBackground)
end