// Man I wish I didn't have to hook all this crap
Script.Load("lua/Hud/Commander/CystGhostModel.lua")
local kCircleModelName = PrecacheAsset("models/misc/circle/circle_alien.model")
			
local oldCystGhostModelInit = CystGhostModel.Initialize
function CystGhostModel:Initialize()

	oldCystGhostModelInit(self)
	if not self.circleModel then
		self.circleModel = Client.CreateRenderModel(RenderScene.Zone_Default)
		self.circleModel:SetModel(kCircleModelName)
	end
end
		
local oldCystGhostModelDestroy = CystGhostModel.Destroy
function CystGhostModel:Destroy()
	oldCystGhostModelDestroy(self)
	if self.circleModel then
		Client.DestroyRenderModel(self.circleModel)
		self.circleModel = nil
	end
end

local oldCystGhostModelVis = CystGhostModel.SetIsVisible
function CystGhostModel:SetIsVisible(isVisible)
	oldCystGhostModelVis(self, isVisible)
	if not self.circleModel then
		self.circleModel = Client.CreateRenderModel(RenderScene.Zone_Default)
		self.circleModel:SetModel(kCircleModelName)
	end			
	self.circleModel:SetIsVisible(isVisible)
end
		
local oldCystGhostModelUpdate = CystGhostModel.Update
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
