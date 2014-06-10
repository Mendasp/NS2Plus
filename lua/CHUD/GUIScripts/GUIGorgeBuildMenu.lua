Script.Load("lua/GUIGorgeBuildMenu.lua")
local originalGorgeBuyMenuInit
originalGorgeBuyMenuInit = Class_ReplaceMethod( "GUIGorgeBuildMenu", "Initialize",
	function(self)
		if CHUDGetOption("mingui") then
			self.kSmokeSmallTextureCoordinates = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}
			ReplaceLocals(GUIGorgeBuildMenu.CreateButton, {kSmokeyBackgroundSize = Vector(0, 0, 0)})
		else
			self.kSmokeSmallTextureCoordinates = { { 916, 4, 1020, 108 }, { 916, 15, 1020, 219 }, { 916, 227, 1020, 332 }, { 916, 332, 1020, 436 } }
			ReplaceLocals(GUIGorgeBuildMenu.CreateButton, {kSmokeyBackgroundSize = GUIScale(Vector(220, 400, 0))})
		end
	
		originalGorgeBuyMenuInit(self)
	end)