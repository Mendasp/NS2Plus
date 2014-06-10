Script.Load("lua/GUIAnimatedScript.lua")

class 'CHUDGUI_ClassicAmmo' (GUIAnimatedScript)

local kFontName = "fonts/AgencyFB_large_bold.fnt"
local kAmmoColor = Color(163/255, 210/255, 220/255, 0.8)
local kLowAmmoColor = Color(1, 0, 0, 1)
local kAmmoPos = Vector(-210, -105, 0)

function CHUDGUI_ClassicAmmo:Initialize()

	GUIAnimatedScript.Initialize(self)
	
	self.scale =  Client.GetScreenHeight() / kBaseScreenHeight
	
	self.ammoText = self:CreateAnimatedTextItem()
	self.ammoText:SetFontName(kFontName)
	self.ammoText:SetAnchor(GUIItem.Right, GUIItem.Bottom)    
	self.ammoText:SetTextAlignmentX(GUIItem.Align_Min)    
	self.ammoText:SetTextAlignmentY(GUIItem.Align_Center)    
	self.ammoText:SetColor(kAmmoColor)
	self.ammoText:SetUniformScale(self.scale)
	self.ammoText:SetScale(GetScaledVector())
	self.ammoText:SetPosition(kAmmoPos)
	
end

function CHUDGUI_ClassicAmmo:Reset()

    GUIAnimatedScript.Reset(self)
	
	self.ammoText:SetUniformScale(self.scale)
	self.ammoText:SetScale(GetScaledVector())
	self.ammoText:SetPosition(kAmmoPos)
	
end

function CHUDGUI_ClassicAmmo:Update(deltaTime)

	GUIAnimatedScript.Update(self, deltaTime)

	local player = Client.GetLocalPlayer()
	if player:GetActiveWeapon() and player:GetActiveWeapon():isa("ClipWeapon") and not player:isa("Exo") and CHUDGetOption("classicammo") then
		local clipammo = ToString(PlayerUI_GetWeaponClip())
		local ammo = ToString(PlayerUI_GetWeaponAmmo())
		if clipammo == nil then clipammo = "--" end
		if ammo == "0" then ammo = "--" end
		self.ammoText:SetText(clipammo .. " / " .. ammo)
		self.ammoText:SetIsVisible(true)
		if PlayerUI_GetWeaponClip() < PlayerUI_GetWeapon():GetClipSize() * 0.25 then
			self.ammoText:SetColor(kLowAmmoColor)
		else
			self.ammoText:SetColor(kAmmoColor)
		end

	else
		self.ammoText:SetIsVisible(false)
	end
	
end

function CHUDGUI_ClassicAmmo:Uninitialize()

	GUIAnimatedScript.Uninitialize(self)

	self.ammoText:Destroy()
	self.ammoText = nil
	
end