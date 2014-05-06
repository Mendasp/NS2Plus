Script.Load("lua/Hud/Commander/GhostModel.lua")

local kCircleModelMarine = PrecacheAsset("models/misc/circle/circle.model")
local kCircleModelAlien = PrecacheAsset("models/misc/circle/circle_alien.model")

local oldGhostModelInit = GhostModel.Initialize
function GhostModel:Initialize()
	oldGhostModelInit(self)
	if not self.circleRangeModel then
		local player = Client.GetLocalPlayer()
		local kCircleModelName = ConditionalValue(player:isa("MarineCommander"), kCircleModelMarine, kCircleModelAlien)
		
		self.circleRangeModel = Client.CreateRenderModel(RenderScene.Zone_Default)
		self.circleRangeModel:SetModel(kCircleModelName)
	end
end
		
local oldGhostModelDestroy = GhostModel.Destroy
function GhostModel:Destroy()
	oldGhostModelDestroy(self)
	if self.circleRangeModel then
		local player = Client.GetLocalPlayer()
		local kCircleModelName = ConditionalValue(player:isa("MarineCommander"), kCircleModelMarine, kCircleModelAlien)

		Client.DestroyRenderModel(self.circleRangeModel)
		self.circleRangeModel = nil
	end
end

local oldGhostModelVis = GhostModel.SetIsVisible
function GhostModel:SetIsVisible(isVisible)
	oldGhostModelVis(self, isVisible)
	local player = Client.GetLocalPlayer()
	
	if not self.circleRangeModel then
		local kCircleModelName = ConditionalValue(player:isa("MarineCommander"), kCircleModelMarine, kCircleModelAlien)

		self.circleRangeModel = Client.CreateRenderModel(RenderScene.Zone_Default)
		self.circleRangeModel:SetModel(kCircleModelName)
	end
	
	// Handle the cyst on its own file, with this generic method it won't always align with the last cyst in the chain
	if player and player.currentTechId then
		self.circleRangeModel:SetIsVisible(ConditionalValue(player.currentTechId ~= kTechId.Cyst, isVisible, false))
	end
end
		
local oldGhostModelUpdate = GhostModel.Update
function GhostModel:Update()
	
	local modelCoords = GhostModelUI_GetGhostModelCoords()
	
	local player = Client.GetLocalPlayer()
	
	if modelCoords and player and player.currentTechId then
		local radius = LookupTechData(player.currentTechId, kVisualRange, nil)
		if radius then
			modelCoords:Scale(radius*2)
			modelCoords.origin.y = modelCoords.origin.y+0.01
			
			if not self.circleRangeModel then
				local player = Client.GetLocalPlayer()
				local kCircleModelName = ConditionalValue(player:isa("MarineCommander"), kCircleModelMarine, kCircleModelAlien)

				self.circleRangeModel = Client.CreateRenderModel(RenderScene.Zone_Default)
				self.circleRangeModel:SetModel(kCircleModelName)
			end
			
			self.circleRangeModel:SetCoords(modelCoords)
		end
	end
	
	return oldGhostModelUpdate(self)
end
