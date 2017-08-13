local originalMarineBuyMenuInit = GUIMarineBuyMenu.Initialize
function GUIMarineBuyMenu:Initialize()
	originalMarineBuyMenuInit(self)

	if CHUDGetOption("mingui") then
		self.content:SetTexture("ui/transparent.dds")
		self.repeatingBGTexture:SetTexture("ui/transparent.dds")
		self.scanLine:SetIsVisible(false)
		self.resourceDisplayBackground:SetTexture("ui/transparent.dds")
		self.background:SetColor(Color(1, 1, 1, 0))
	end
end
	
local originalMarineBuyMenuSetHostStructure = GUIMarineBuyMenu.SetHostStructure
function GUIMarineBuyMenu:SetHostStructure(hostStructure)
	originalMarineBuyMenuSetHostStructure(self, hostStructure)
	if CHUDGetOption("mingui") then
		self.menu:SetTexture("ui/transparent.dds")
		self.menuHeader:SetTexture("ui/transparent.dds")
	end
end