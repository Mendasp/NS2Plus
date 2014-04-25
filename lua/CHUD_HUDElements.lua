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