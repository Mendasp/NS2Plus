Script.Load("lua/Hud/Commander/GhostModel.lua")

local kCircleModelMarine = PrecacheAsset("models/misc/circle/circle.model")
local kCircleModelAlien = PrecacheAsset("models/misc/circle/circle_alien.model")

// I think this is a very honest function name, I'd trust it with my wallet, kids, dog and car keys
function GhostModel:MaybeInitCircleModel()
	if not self.circleRangeModel then
		local player = Client.GetLocalPlayer()
		local kCircleModelName = ConditionalValue(player:isa("MarineCommander"), kCircleModelMarine, kCircleModelAlien)
		
		self.circleRangeModel = Client.CreateRenderModel(RenderScene.Zone_Default)
		self.circleRangeModel:SetModel(kCircleModelName)
		
		// Second ring just for the shift, so always alien
		self.circleEnergyModel = Client.CreateRenderModel(RenderScene.Zone_Default)
		self.circleEnergyModel:SetModel(kCircleModelAlien)
	end
end

local oldGhostModelInit = GhostModel.Initialize
function GhostModel:Initialize()
	oldGhostModelInit(self)
	self:MaybeInitCircleModel()
end
		
local oldGhostModelDestroy = GhostModel.Destroy
function GhostModel:Destroy()
	oldGhostModelDestroy(self)
	
	if self.circleRangeModel then
		Client.DestroyRenderModel(self.circleRangeModel)
		self.circleRangeModel = nil
	end
	
	if self.circleEnergyModel then
		Client.DestroyRenderModel(self.circleEnergyModel)
		self.circleEnergyModel = nil
	end
end

local oldGhostModelVis = GhostModel.SetIsVisible
function GhostModel:SetIsVisible(isVisible)
	oldGhostModelVis(self, isVisible)

	local player = Client.GetLocalPlayer()
	
	self:MaybeInitCircleModel()
	
	self.circleRangeModel:SetIsVisible(isVisible)
	self.circleEnergyModel:SetIsVisible(false)
	
	if player and player.currentTechId then
		// Handle the cyst on its own file, with this generic method it won't always align with the last cyst in the chain
		if player.currentTechId == kTechId.Cyst then
			self.circleRangeModel:SetIsVisible(false)
		// Show a second circle for the shift energize radius
		elseif player.currentTechId == kTechId.Shift then
			self.circleEnergyModel:SetIsVisible(isVisible)
		end
	end
end

local oldGhostModelUpdate = GhostModel.Update
function GhostModel:Update()
	
	local modelCoords = GhostModelUI_GetGhostModelCoords()
	
	local player = Client.GetLocalPlayer()
	
	if modelCoords and player and player.currentTechId then
		local radius = LookupTechData(player.currentTechId, kVisualRange, nil)
		if radius then
		
			self:MaybeInitCircleModel()
		
			if player.currentTechId == kTechId.Shift then
				// Too lazy to use a second variable
				local energizeCoords = CopyCoords(modelCoords)
				energizeCoords:Scale(kEnergizeRange*2)
				energizeCoords.origin.y = energizeCoords.origin.y+0.01
				self.circleEnergyModel:SetCoords(energizeCoords)
			end
		
			modelCoords:Scale(radius*2)
			modelCoords.origin.y = modelCoords.origin.y+0.01
			
			self.circleRangeModel:SetCoords(modelCoords)
		end
	end
	
	return oldGhostModelUpdate(self)
end

local oldCommanderUpdateGhostGuides
oldCommanderUpdateGhostGuides = Class_ReplaceMethod("Commander", "UpdateGhostGuides",
function(self)
	oldCommanderUpdateGhostGuides(self)
	
	for index, entity in pairs(self.selectedEntities) do    
		local visualRadius = entity:GetVisualRadius()
		
		if visualRadius ~= nil then
			if type(visualRadius) == "table" then
				for i,r in ipairs(visualRadius) do
					if entity:GetTechId() == kTechId.Shift then
						self:AddGhostGuide(Vector(entity:GetOrigin()), kEnergizeRange)
					end
				end
			else
				if entity:GetTechId() == kTechId.Shift then
					self:AddGhostGuide(Vector(entity:GetOrigin()), kEnergizeRange)
				end
			end
		end
		
	end
end)
