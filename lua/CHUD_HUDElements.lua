Script.Load("lua/Hud/Marine/GUIMarineStatus.lua")
local originalMarineStatusInit
originalMarineStatusInit = Class_ReplaceMethod( "GUIMarineStatus", "Initialize",
	function (self)
		originalMarineStatusInit(self)
		if CHUDGetOption("mingui") then
			self.statusbackground:SetColor(Color(1,1,1,0))
			self.scanLinesForeground:SetColor(Color(1,1,1,0))
		end
		
		self.ammoText = self.script:CreateAnimatedTextItem()
		self.ammoText:SetFontName(GUIMarineStatus.kFontName)
		self.ammoText:SetAnchor(GUIItem.Right, GUIItem.Bottom)    
		self.ammoText:SetTextAlignmentX(GUIItem.Align_Min)    
		self.ammoText:SetTextAlignmentY(GUIItem.Align_Center)    
		self.ammoText:SetColor(GUIMarineStatus.kHealthBarColor)
	end
)

local originalMarineStatusReset
originalMarineStatusReset = Class_ReplaceMethod( "GUIMarineStatus", "Reset",
	function (self, scale)
		originalMarineStatusReset(self, scale)
	
		self.ammoText:SetUniformScale(scale)
		self.ammoText:SetScale(GetScaledVector())
		self.ammoText:SetPosition(Vector(-210, -105, 0))
	end
)

local originalMarineStatusDestroy
originalMarineStatusDestroy = Class_ReplaceMethod( "GUIMarineStatus", "Destroy",
	function (self)
		originalMarineStatusDestroy(self)
	
		self.ammoText:Destroy()
	end
)

local originalMarineStatusUpdate
originalMarineStatusUpdate = Class_ReplaceMethod( "GUIMarineStatus", "Update",
	function (self, deltaTime, parameters)
		originalMarineStatusUpdate(self, deltaTime, parameters)
		if CHUDGetOption("mingui") or not CHUDGetOption("hpbar") then
			self.healthBorderMask:SetColor(Color(1,1,1,0))
			self.armorBorderMask:SetColor(Color(1,1,1,0))
		end
		if not CHUDGetOption("hpbar") or Client.GetLocalPlayer():isa("Exo") then
			self.statusbackground:SetTexturePixelCoordinates(unpack({ 0, 0, 0, 0 }))
			self.scanLinesForeground:SetAnchor(GUIItem.Left, GUIItem.Top)
			self.parasiteState:SetAnchor(GUIItem.Left, GUIItem.Center)
			self.healthText:SetPosition(Vector(-300, 36, 0))
			self.armorText:SetPosition(Vector(-300, 96, 0))
			self.healthBar:SetIsVisible(false)
			self.armorBar:SetIsVisible(false)
			if Client.GetLocalPlayer():isa("Exo") then
				self.healthText:SetIsVisible(false)
				self.healthBar:SetIsVisible(false)
				self.healthBorderMask:SetColor(Color(1,1,1,0))
				self.armorBorderMask:SetColor(Color(1,1,1,0))
			end
		end
		
		local player = Client.GetLocalPlayer()
		if player:GetActiveWeapon() and player:GetActiveWeapon():isa("ClipWeapon") and not player:isa("Exo") and CHUDGetOption("classicammo") then
			local clipammo = ToString(PlayerUI_GetWeaponClip())
			local ammo = ToString(PlayerUI_GetWeaponAmmo())
			if clipammo == nil then clipammo = "--" end
			if ammo == "0" then ammo = "--" end
			self.ammoText:SetText(clipammo .. " / " .. ammo)
			self.ammoText:SetIsVisible(true)
			if PlayerUI_GetWeaponClip() < PlayerUI_GetWeapon():GetClipSize() * 0.25 then
				self.ammoText:SetColor(Color(1, 0, 0, 1)) 
			else
				self.ammoText:SetColor(GUIMarineStatus.kHealthBarColor) 
			end
		else
			self.ammoText:SetIsVisible(false)
		end
	end
)

Script.Load("lua/Hud/GUIEvent.lua")
local originalEventUpdate
originalEventUpdate = Class_ReplaceMethod( "GUIEvent", "Update",
	function (self, deltaTime, parameters)
		if not CHUDGetOption("minimap") then
			parameters[1] = nil
		end
		originalEventUpdate(self, deltaTime, parameters)
		if CHUDGetOption("mingui") then
			self.borderTop:SetIsVisible(false)
			self.unlockBackground:SetColor(Color(1,1,1,0))
			self.unlockFlash:SetIsVisible(false)
			self.unlockFlashStencil:SetIsVisible(false)
		end
		if not CHUDGetOption("unlocks") then
			self.unlockFrame:SetIsVisible(false)
		else
			self.unlockFrame:SetIsVisible(true)
		end
	end
)

Script.Load("lua/GUIAlienTeamMessage.lua")
originalAlienMessage = Class_ReplaceMethod( "GUIAlienTeamMessage", "SetTeamMessage",
	function(self, message)
		originalAlienMessage(self, message)
		if not CHUDGetOption("banners") then
			self.background:SetIsVisible(false)
		end
		if CHUDGetOption("mingui") then
			self.background:DestroyAnimations()
		end
	end
)

Script.Load("lua/GUIMarineTeamMessage.lua")
originalMarineMessage = Class_ReplaceMethod( "GUIMarineTeamMessage", "SetTeamMessage",
	function(self, message)
		originalMarineMessage(self, message)
		if not CHUDGetOption("banners") then
			self.background:SetIsVisible(false)
		end
		if CHUDGetOption("mingui") then
			self.background:DestroyAnimations()
		end
	end
)

Script.Load("lua/Player_Client.lua")
originalBlur = Class_ReplaceMethod( "Player", "SetBlurEnabled",
	function(self, blurEnabled)
		if not CHUDGetOption("blur") then
			Player.screenEffects.blur:SetActive(false)
		else
			originalBlur(self, blurEnabled)
		end
	end
)

originalUpdateScreenEff = Class_ReplaceMethod( "Player", "UpdateScreenEffects",
	function(self, deltaTime)
		originalUpdateScreenEff(self, deltaTime)
		//if not Client.GetOptionBoolean("CHUD_LowHealthEff", true) then
			Player.screenEffects.lowHealth:SetActive(false)
		//end
	end
)

Script.Load("lua/DSPEffects.lua")
originalDSPEff = UpdateDSPEffects
function UpdateDSPEffects()
	/*if Client.GetOptionBoolean("CHUD_LowHealthEff", true) then
		originalDSPEff()
	end*/
end

Script.Load("lua/EffectManager.lua")
local blockedEffects = {	"complete_order",
							"upgrade_complete" }
originalTriggerEffects = Class_ReplaceMethod( "EffectManager", "TriggerEffects",
	function(self, effectName, tableParams, triggeringEntity)
		if not table.contains(blockedEffects, effectName) then
			originalTriggerEffects(self, effectName, tableParams, triggeringEntity)
		elseif	(effectName == "complete_order" and CHUDGetOption("wps")) or
				(effectName == "upgrade_complete" and CHUDGetOption("unlocks")) then
			originalTriggerEffects(self, effectName, tableParams, triggeringEntity)
		end
	end
)

Script.Load("lua/Weapons/Marine/ExoWeaponHolder.lua")
originalExoWeaponHolder = Class_ReplaceMethod( "ExoWeaponHolder", "OnUpdateRender",
	function(self)
		originalExoWeaponHolder(self)
		local parent = self:GetParent()
		if parent and parent == Client.GetLocalPlayer() then
		
			local viewModel = parent:GetViewModelEntity()
			if viewModel and viewModel:GetRenderModel() then
				if CHUDGetOption("mingui") then
					viewModel:GetRenderModel():SetMaterialParameter("scanlinesMap", "ui/blank.dds")
				else
					viewModel:GetRenderModel():SetMaterialParameter("scanlinesMap", "ui/exosuit_scanlines.dds")
				end
			end
		end
	end
)

Script.Load("lua/SoundEffect.lua")
local blockedVO = {	"sound/NS2.fev/marine/voiceovers/commander/build",
					"sound/NS2.fev/marine/voiceovers/commander/defend",
					"sound/NS2.fev/marine/voiceovers/move" }
					
local skulkJumpSounds = {
	"sound/NS2.fev/alien/skulk/jump_good",
	"sound/NS2.fev/alien/skulk/jump_best",
	"sound/NS2.fev/alien/skulk/jump"
}
function StartSoundEffectOnEntity(soundEffectName, onEntity, volume, predictor)
	if table.contains(skulkJumpSounds, soundEffectName) then
		volume = volume * 0.5
	elseif soundEffectName == "sound/NS2.fev/alien/skulk/bite" then
		volume = volume * 0.6
	end
	
	if not table.contains(blockedVO, soundEffectName) or CHUDGetOption("wps") then
		Shared.PlaySound(onEntity, soundEffectName, volume or 1)
	end
end
