Script.Load("lua/Hud/GUIEvent.lua")
local originalEventUpdate
originalEventUpdate = Class_ReplaceMethod( "GUIEvent", "Update",
	function (self, deltaTime, parameters)
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
// Disables low health effects
originalDSPEff = UpdateDSPEffects
function UpdateDSPEffects()
	// We're not doing anything in this function
    // but leave this for future generations to wonder why this was an option in the first place

    // Most ancient piece of code in this mod - Archaeologists pls be careful, this code has a curse
	/*if Client.GetOptionBoolean("CHUD_LowHealthEff", true) then
		originalDSPEff()
	end*/
end

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

// Man I wish I didn't have to hook all this crap
// This is horrible
local CystOverride = false
local kCircleModelName = PrecacheAsset("models/misc/circle/circle_alien.model")

local oldLoadGhostModel = LoadGhostModel
function LoadGhostModel(className)
	oldLoadGhostModel(className)
	// This is horriblier, or maybe horribliest
	if className == "CystGhostModel" and not CystOverride then
		CystOverride = true
			
		oldCystGhostModelInit = CystGhostModel.Initialize
		function CystGhostModel:Initialize()

			oldCystGhostModelInit(self)
			if not self.circleModel then
				self.circleModel = Client.CreateRenderModel(RenderScene.Zone_Default)
				self.circleModel:SetModel(kCircleModelName)
			end
		end
		
		oldCystGhostModelDestroy = CystGhostModel.Destroy
		function CystGhostModel:Destroy()
			oldCystGhostModelDestroy(self)
			if self.circleModel then
				Client.DestroyRenderModel(self.circleModel)
				self.circleModel = nil
			end
		end

		oldCystGhostModelVis = CystGhostModel.SetIsVisible
		function CystGhostModel:SetIsVisible(isVisible)
			oldCystGhostModelVis(self, isVisible)
			if not self.circleModel then
				self.circleModel = Client.CreateRenderModel(RenderScene.Zone_Default)
				self.circleModel:SetModel(kCircleModelName)
			end			
			self.circleModel:SetIsVisible(isVisible)
		end
		
		oldCystGhostModelUpdate = CystGhostModel.Update
		function CystGhostModel:Update()
			
			local modelCoords = GhostModel.Update(self)
			
			local cystPoints = {}
			
			if modelCoords then
				cystPoints = GetCystPoints(modelCoords.origin)
			end
			
			if #cystPoints > 0 then
				local lastcyst = Coords.GetTranslation(cystPoints[#cystPoints])
				lastcyst:Scale(kInfestationRadius*2)
				// Raise the circle a bit so it doesn't create horrible Z-fighting
				// Y-fighting? huehuehue
				lastcyst.origin.y = lastcyst.origin.y+0.01
				if not self.circleModel then
					self.circleModel = Client.CreateRenderModel(RenderScene.Zone_Default)
					self.circleModel:SetModel(kCircleModelName)
				end
				self.circleModel:SetCoords(lastcyst)
			end
			
			oldCystGhostModelUpdate(self)
		end
	end
end