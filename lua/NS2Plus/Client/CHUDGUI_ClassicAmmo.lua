Script.Load("lua/GUIAnimatedScript.lua")

class 'CHUDGUI_ClassicAmmo' (GUIAnimatedScript)

local kFontName = Fonts.kAgencyFB_Large_Bold
local kAmmoColor = Color(163/255, 210/255, 220/255, 0.8)
local kLowAmmoColor = Color(1, 0, 0, 1)

function CHUDGUI_ClassicAmmo:Initialize()

	GUIAnimatedScript.Initialize(self)
	
	self.scale = Client.GetScreenHeight() / kBaseScreenHeight
	
	if CHUDGetOption("customhud_m") == 2 then
		self.kAmmoPos = Vector(-320, -105, 0)
	else
		self.kAmmoPos = Vector(-210, -105, 0)
	end
	
	self.ammoText = self:CreateAnimatedTextItem()
	self.ammoText:SetFontName(kFontName)
	self.ammoText:SetAnchor(GUIItem.Right, GUIItem.Bottom)    
	self.ammoText:SetTextAlignmentX(GUIItem.Align_Min)    
	self.ammoText:SetTextAlignmentY(GUIItem.Align_Center)    
	self.ammoText:SetColor(kAmmoColor)
	self.ammoText:SetUniformScale(self.scale)
	self.ammoText:SetScale(GetScaledVector())
	self.ammoText:SetPosition(self.kAmmoPos)
	
	self.lowAmmoOverlay = self:CreateAnimatedTextItem()
	self.lowAmmoOverlay:SetFontName(kFontName)
	self.lowAmmoOverlay:SetAnchor(GUIItem.Right, GUIItem.Bottom)    
	self.lowAmmoOverlay:SetTextAlignmentX(GUIItem.Align_Min)    
	self.lowAmmoOverlay:SetTextAlignmentY(GUIItem.Align_Center)    
	self.lowAmmoOverlay:SetColor(kAmmoColor)
	self.lowAmmoOverlay:SetUniformScale(self.scale)
	self.lowAmmoOverlay:SetScale(GetScaledVector())
	self.lowAmmoOverlay:SetPosition(self.kAmmoPos)
	
end

function CHUDGUI_ClassicAmmo:Reset()

	GUIAnimatedScript.Reset(self)
	
	self.ammoText:SetUniformScale(self.scale)
	self.ammoText:SetScale(GetScaledVector())
	self.ammoText:SetPosition(self.kAmmoPos)
	
	self.lowAmmoOverlay:SetUniformScale(self.scale)
	self.lowAmmoOverlay:SetScale(GetScaledVector())
	self.lowAmmoOverlay:SetPosition(self.kAmmoPos)
	
end

function CHUDGUI_ClassicAmmo:Update(deltaTime)

	GUIAnimatedScript.Update(self, deltaTime)

	local player = Client.GetLocalPlayer()
	local activeWeapon = player:GetActiveWeapon()
	if activeWeapon and activeWeapon:isa("ClipWeapon") and not player:isa("Exo") then
		local clipammo = ToString(PlayerUI_GetWeaponClip())
		local ammo = ToString(PlayerUI_GetWeaponAmmo())
		if clipammo == nil then clipammo = "0" end
		local reloadindicator = ""
		if player:GetActiveWeapon():GetIsReloading() then
			reloadindicator = " (R)"
		end
		self.ammoText:SetText(clipammo .. " / " .. ammo .. reloadindicator)
		self.ammoText:SetIsVisible(true)
		self.lowAmmoOverlay:SetText(clipammo .. " / " .. ammo .. reloadindicator)
		self.lowAmmoOverlay:SetIsVisible(true)

		local fraction = PlayerUI_GetWeaponClip() / PlayerUI_GetWeapon():GetClipSize()
		local alpha = 0
		local pulseSpeed = 5

		
		if fraction <= 0.4 then
			
			if fraction < 0.25 then pulseSpeed = 10 end
			alpha = (math.sin(Shared.GetTime() * pulseSpeed) + 1) / 2
			
			if fraction == 0 then alpha = 1 end
		end
		
		self.lowAmmoOverlay:SetColor(Color(1, 0, 0, alpha))

	else
		if activeWeapon and (activeWeapon:isa("Builder") or activeWeapon:isa("Welder")) then
			self.ammoText:SetText(string.format("%d%%", PlayerUI_GetUnitStatusPercentage()))
			self.lowAmmoOverlay:SetText(string.format("%d%%", PlayerUI_GetUnitStatusPercentage()))
			self.ammoText:SetIsVisible(PlayerUI_GetUnitStatusPercentage() > 0)
			self.lowAmmoOverlay:SetIsVisible(PlayerUI_GetUnitStatusPercentage() > 0)
		else
			self.ammoText:SetIsVisible(false)
			self.lowAmmoOverlay:SetIsVisible(false)
		end
	end
	
end

function CHUDGUI_ClassicAmmo:Uninitialize()

	GUIAnimatedScript.Uninitialize(self)

	self.ammoText:Destroy()
	self.ammoText = nil
	
	self.lowAmmoOverlay:Destroy()
	self.lowAmmoOverlay = nil
	
end
