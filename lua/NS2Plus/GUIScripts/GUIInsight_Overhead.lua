local keyHintsVisible = Client.GetOptionBoolean("CHUD_OverheadHelp", true)

local originalOverheadInit = GUIInsight_Overhead.Initialize
function GUIInsight_Overhead:Initialize()
	originalOverheadInit(self)

	self.keyHints = GUIManager:CreateTextItem()
	self.keyHints:SetFontName(Fonts.kAgencyFB_Tiny)
	self.keyHints:SetScale(GetScaledVector())
	self.keyHints:SetAnchor(GUIItem.Left, GUIItem.Bottom)
	self.keyHints:SetPosition(Vector(GUIScale(10), -GUIScale(20), 0))
	self.keyHints:SetColor(kWhite)
	GUIMakeFontScale(self.keyHints)
end

local originalOverheadUpdate = GUIInsight_Overhead.Update
function GUIInsight_Overhead:Update(deltaTime)
	originalOverheadUpdate(self, deltaTime)
	if self.keyHints then
		self.keyHints:SetIsVisible(keyHintsVisible)
		self.keyHints:SetText(string.format("[%s] Stats [%s] Toggle health [%s] Toggle outlines [%s/%s] Zoom [%s] Reset zoom [%s] Draw on screen [%s] Clear screen [%s] Toggle this help", BindingsUI_GetInputValue("RequestHealth"), BindingsUI_GetInputValue("Use"),BindingsUI_GetInputValue("ToggleFlashlight"), BindingsUI_GetInputValue("OverHeadZoomIncrease"), BindingsUI_GetInputValue("OverHeadZoomDecrease"), BindingsUI_GetInputValue("OverHeadZoomReset"), BindingsUI_GetInputValue("SecondaryAttack"), BindingsUI_GetInputValue("Reload"), BindingsUI_GetInputValue("RequestAmmo")))
	end
end
	
local originalOverheadOnResChanged = GUIInsight_Overhead.OnResolutionChanged
function GUIInsight_Overhead:OnResolutionChanged(oldX, oldY, newX, newY)
	originalOverheadOnResChanged(self, oldX, oldY, newX, newY)

	if self.keyHints then
		self.keyHints:SetFontName(Fonts.kAgencyFB_Tiny)
		self.keyHints:SetScale(GetScaledVector())
		self.keyHints:SetPosition(Vector(GUIScale(10), -GUIScale(20), 0))
		GUIMakeFontScale(self.keyHints)
	end
end
	
local originalOverheadUninit = GUIInsight_Overhead.Uninitialize
function GUIInsight_Overhead:Uninitialize()
	originalOverheadUninit(self)

	if self.keyHints then
		GUI.DestroyItem(self.keyHints)
		self.keyHints = nil
	end
end
	
local lastDown = false
local originalOverheadSKE = GUIInsight_Overhead.SendKeyEvent
function GUIInsight_Overhead:SendKeyEvent(key, down)
	local ret = originalOverheadSKE(self, key, down)
	if not ret and GetIsBinding(key, "RequestAmmo") and lastDown ~= down then
		lastDown = down
		if not down and not ChatUI_EnteringChatMessage() and not MainMenu_GetIsOpened() then
			keyHintsVisible = not keyHintsVisible
			Client.SetOptionBoolean("CHUD_OverheadHelp", keyHintsVisible)
			return true
		end
	end

	return ret
end