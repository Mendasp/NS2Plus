Script.Load("lua/GUIInsight_Overhead.lua")

local keyHintsVisible = Client.GetOptionBoolean("CHUD_OverheadHelp", true)

local originalOverheadInit
originalOverheadInit = Class_ReplaceMethod("GUIInsight_Overhead", "Initialize",
	function(self)
		originalOverheadInit(self)
		
		self.keyHints = GUIManager:CreateTextItem()
		self.keyHints:SetFontName(Fonts.kAgencyFB_Tiny)
		self.keyHints:SetScale(GetScaledVector())
		self.keyHints:SetAnchor(GUIItem.Left, GUIItem.Bottom)
		self.keyHints:SetPosition(Vector(GUIScale(10), -GUIScale(20), 0))
		self.keyHints:SetColor(kWhite)
		GUIMakeFontScale(self.keyHints)
	end)

local originalOverheadUpdate
originalOverheadUpdate = Class_ReplaceMethod("GUIInsight_Overhead", "Update",
	function(self, deltaTime)
		originalOverheadUpdate(self, deltaTime)
		if self.keyHints then
			self.keyHints:SetIsVisible(keyHintsVisible)
			self.keyHints:SetText(string.format("[%s] Stats [%s] Toggle health [%s] Toggle outlines [%s/%s] Zoom [%s] Reset zoom [%s] Draw on screen [%s] Clear screen [%s] Toggle this help", BindingsUI_GetInputValue("RequestHealth"), BindingsUI_GetInputValue("Use"),BindingsUI_GetInputValue("ToggleFlashlight"), BindingsUI_GetInputValue("OverHeadZoomIncrease"), BindingsUI_GetInputValue("OverHeadZoomDecrease"), BindingsUI_GetInputValue("OverHeadZoomReset"), BindingsUI_GetInputValue("SecondaryAttack"), BindingsUI_GetInputValue("Reload"), BindingsUI_GetInputValue("RequestAmmo")))
		end
	end)
	
local originalOverheadOnResChanged
originalOverheadOnResChanged = Class_ReplaceMethod("GUIInsight_Overhead", "OnResolutionChanged",
	function(self, oldX, oldY, newX, newY)
		originalOverheadOnResChanged(self, oldX, oldY, newX, newY)
		
		if self.keyHints then
			self.keyHints:SetFontName(Fonts.kAgencyFB_Tiny)
			self.keyHints:SetScale(GetScaledVector())
			self.keyHints:SetPosition(Vector(GUIScale(10), -GUIScale(20), 0))
			GUIMakeFontScale(self.keyHints)
		end
	end)
	
local originalOverheadUninit
originalOverheadUninit = Class_ReplaceMethod("GUIInsight_Overhead", "Uninitialize",
	function(self)
		originalOverheadUninit(self)
		
		if self.keyHints then
			GUI.DestroyItem(self.keyHints)
			self.keyHints = nil
		end
	end)
	
local lastDown = false
local originalOverheadSKE
originalOverheadSKE = Class_ReplaceMethod("GUIInsight_Overhead", "SendKeyEvent",
	function(self, key, down)
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
	end)