Script.Load("lua/GUIMarineBuyMenu.lua")
local originalMarineBuyMenuInit
originalMarineBuyMenuInit = Class_ReplaceMethod( "GUIMarineBuyMenu", "Initialize",
	function(self)
		originalMarineBuyMenuInit(self)

		if CHUDGetOption("mingui") then
			self.content:SetTexture("ui/transparent.dds")
			self.repeatingBGTexture:SetTexture("ui/transparent.dds")
			self.scanLine:SetIsVisible(false)
			self.resourceDisplayBackground:SetTexture("ui/transparent.dds")
			self.background:SetColor(Color(1, 1, 1, 0))
		end
	end)
	
local originalMarineBuyMenuSetHostStructure
originalMarineBuyMenuSetHostStructure = Class_ReplaceMethod( "GUIMarineBuyMenu", "SetHostStructure",
	function(self, hostStructure)
		originalMarineBuyMenuSetHostStructure(self, hostStructure)
		if CHUDGetOption("mingui") then
			self.menu:SetTexture("ui/transparent.dds")
			self.menuHeader:SetTexture("ui/transparent.dds")
		end
	end)