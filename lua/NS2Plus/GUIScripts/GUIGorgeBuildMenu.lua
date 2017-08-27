local originalGorgeBuyMenuReset = GUIGorgeBuildMenu.Reset
function GUIGorgeBuildMenu:Reset()
	if CHUDGetOption("mingui") then
		self.kSmokeSmallTextureCoordinates = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}
		self.kSmokeyBackgroundSize = Vector(0, 0, 0)
	else
		self.kSmokeSmallTextureCoordinates = { { 916, 4, 1020, 108 }, { 916, 15, 1020, 219 }, { 916, 227, 1020, 332 }, { 916, 332, 1020, 436 } }
		self.kSmokeyBackgroundSize = GUIScale(Vector(220, 400, 0))
	end

	originalGorgeBuyMenuReset(self)
end