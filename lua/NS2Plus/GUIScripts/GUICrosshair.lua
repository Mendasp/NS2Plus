local kCHUDReloadDialTexture = PrecacheAsset("ui/chud_reload.dds")

local originalCrossInit = GUICrosshair.Initialize
function GUICrosshair:Initialize()
	originalCrossInit(self)

	self.crosshairs:SetSize(Vector(1, 1, 0)*GUICrosshair.kCrosshairSize*CHUDGetOption("crosshairscale"))
	self.damageIndicator:SetSize(Vector(1, 1, 0)*GUICrosshair.kCrosshairSize*CHUDGetOption("crosshairscale"))

	self.crosshairs:SetPosition(-Vector(0.5, 0.5, 0)*GUICrosshair.kCrosshairSize*CHUDGetOption("crosshairscale"))

	if CHUDGetOption("reloadindicator") > 0 then
		local reloadDialSettings = { }
		reloadDialSettings.BackgroundWidth = GUIScale(64) * CHUDGetOption("crosshairscale")
		reloadDialSettings.BackgroundHeight = GUIScale(64) * CHUDGetOption("crosshairscale")
		reloadDialSettings.BackgroundAnchorX = GUIItem.Middle
		reloadDialSettings.BackgroundAnchorY = GUIItem.Center
		reloadDialSettings.BackgroundOffset = GUIScale(Vector(-32, 32, 0)) * CHUDGetOption("crosshairscale")
		reloadDialSettings.BackgroundTextureName = nil
		reloadDialSettings.BackgroundTextureX1 = 0
		reloadDialSettings.BackgroundTextureY1 = 0
		reloadDialSettings.BackgroundTextureX2 = 0
		reloadDialSettings.BackgroundTextureY2 = 0
		reloadDialSettings.ForegroundTextureName = kCHUDReloadDialTexture
		reloadDialSettings.ForegroundTextureWidth = 128
		reloadDialSettings.ForegroundTextureHeight = 128
		reloadDialSettings.ForegroundTextureX1 = 0
		reloadDialSettings.ForegroundTextureY1 = 0
		reloadDialSettings.ForegroundTextureX2 = 128
		reloadDialSettings.ForegroundTextureY2 = 128
		reloadDialSettings.InheritParentAlpha = false
		self.reloadDial = GUIDial()
		self.reloadDial:Initialize(reloadDialSettings)
		self.reloadDial:SetIsVisible(false)
		self.reloadDial:GetBackground():SetLayer(kGUILayerPlayerHUD)
		self.reloadDial:GetLeftSide():SetColor(ColorIntToColor(CHUDGetOption("reloadindicatorcolor")))
		self.reloadDial:GetRightSide():SetColor(ColorIntToColor(CHUDGetOption("reloadindicatorcolor")))
	end
end
	
local originalCrossUpdate = GUICrosshair.Update
function GUICrosshair:Update(deltaTime)
	originalCrossUpdate(self)

	local reloadFraction = CHUDGetReloadFraction()
	local reloadIndicator = CHUDGetOption("reloadindicator")
	local reloadIndicatorVisible = reloadIndicator == 1 and gCHUDHiddenViewModel or reloadIndicator == 2
	-- For some reason having this initialized isn't enough so let's check for it every frame
	if self.reloadDial and self.crosshairs:GetIsVisible() and reloadIndicatorVisible and reloadFraction > -1 then
		self.updateInterval = kUpdateIntervalFull
		self.reloadDial:SetIsVisible(true)
		self.reloadDial:SetPercentage(reloadFraction)
		self.reloadDial:Update(deltaTime)
	else
		self.updateInterval = 0.04
		if self.reloadDial then
			self.reloadDial:SetIsVisible(false)
		end
	end
end
	
local originalCrossUninit = GUICrosshair.Uninitialize
function GUICrosshair:Uninitialize()
	originalCrossUninit(self)

	if self.reloadDial then
		self.reloadDial:Uninitialize()
		self.reloadDial = nil
	end
end