local kCHUDMarineIconsFileName = PrecacheAsset("ui/chud_marine_minimap_blip.dds")
local kMarineIconsFileName = PrecacheAsset("ui/marine_minimap_blip.dds")
local oldSetBackgroundMode = GUIMinimapFrame.SetBackgroundMode
function GUIMinimapFrame:SetBackgroundMode(setMode, forceReset)
    oldSetBackgroundMode(self, setMode, forceReset)

    if self.comMode == GUIMinimapFrame.kModeZoom then
        self:SetIconFileName(ConditionalValue(CHUDGetOption("minimaparrowcolorcustom") or CHUDGetOption("playercolor_m") ~= CHUDGetOptionParam("playercolor_m", "defaultValue"), kCHUDMarineIconsFileName, kMarineIconsFileName))
    else
        self:SetIconFileName(nil)
    end
end