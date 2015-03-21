Script.Load("lua/GUIAnimatedScript.lua")

class 'CHUDGUI_ClassicAmmo' (GUIAnimatedScript)

local kFontName = Fonts.kAgencyFB_Large_Bold
local kAmmoColor = Color(163/255, 210/255, 220/255, 0.8)
local kLowAmmoColor = Color(1, 0, 0, 1)

function CHUDGUI_ClassicAmmo:Initialize()

	GUIAnimatedScript.Initialize(self)
	
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
	self.ammoText:SetScale(GetScaledVector())
	self.ammoText:SetPosition(self.kAmmoPos)
	
end

function CHUDGUI_ClassicAmmo:Reset()

	GUIAnimatedScript.Reset(self)
	
	self.ammoText:SetScale(GetScaledVector())
	
end

local pulsateTime = 0
local function Pulsate(script, item)

	item:SetColor(Color(1, 0, 0, 0.35), pulsateTime, "CLASSIC_AMMO_PULSATE", AnimateLinear,
		function(script, item)
			item:SetColor(Color(1, 0, 0, 1), pulsateTime, "CLASSIC_AMMO_PULSATE", AnimateLinear, Pulsate)
		end)

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

		local fraction = PlayerUI_GetWeaponClip() / PlayerUI_GetWeapon():GetClipSize()

		if fraction < 0.25 then
			pulsateTime = 0.25
		elseif fraction <= 0.4 then
			pulsateTime = 0.5
		end

		if not self.ammoText:GetIsAnimating() and fraction <= 0.4 and fraction > 0 then
			self.ammoText:FadeIn(0.05, "CLASSIC_AMMO_PULSATE", AnimateLinear, Pulsate)
		elseif fraction > 0.4 then
			self.ammoText:SetColor(kAmmoColor)
		elseif fraction == 0 then
			self.ammoText:SetColor(kRed)
		end
	else
		self.ammoText:SetColor(kAmmoColor)
		if activeWeapon and (activeWeapon:isa("Builder") or activeWeapon:isa("Welder")) then
			self.ammoText:SetText(string.format("%d%%", PlayerUI_GetUnitStatusPercentage()))
			self.ammoText:SetIsVisible(PlayerUI_GetUnitStatusPercentage() > 0)
		elseif activeWeapon and player:isa("Exo") and activeWeapon:isa("ExoWeaponHolder") then
			local leftWeapon = Shared.GetEntity(activeWeapon.leftWeaponId)
			local rightWeapon = Shared.GetEntity(activeWeapon.rightWeaponId)
			local leftAmmo = -1
			local rightAmmo = -1
			if rightWeapon:isa("Railgun") then
				rightAmmo = rightWeapon:GetChargeAmount() * 100
				if leftWeapon:isa("Railgun") then
					leftAmmo = leftWeapon:GetChargeAmount() * 100
				end
			elseif rightWeapon:isa("Minigun") then
				rightAmmo = rightWeapon.heatAmount * 100
				if leftWeapon:isa("Minigun") then
					leftAmmo = leftWeapon.heatAmount * 100
				end
			end
			if leftAmmo > -1 and rightAmmo > -1 then
				self.ammoText:SetText(string.format("%d / %d", leftAmmo, rightAmmo))
			elseif rightAmmo > -1 then
				self.ammoText:SetText(string.format("%d", rightAmmo))
			end
			self.ammoText:SetIsVisible((leftAmmo > -1 and rightAmmo > -1) or rightAmmo > -1)
		elseif activeWeapon and activeWeapon:isa("GrenadeThrower") then
			self.ammoText:SetText(string.format("%d", activeWeapon.grenadesLeft))
		elseif activeWeapon and activeWeapon:isa("LayMines") then
			self.ammoText:SetText(string.format("%d", activeWeapon:GetMinesLeft()))
		else
			self.ammoText:SetIsVisible(false)
		end
	end
	
end

function CHUDGUI_ClassicAmmo:Uninitialize()

	GUIAnimatedScript.Uninitialize(self)

	self.ammoText:Destroy()
	self.ammoText = nil
	
end
