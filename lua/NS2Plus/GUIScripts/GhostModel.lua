Script.Load("lua/Hud/Commander/GhostModel.lua")

local oldGhostModelUpdate = GhostModel.Update
function GhostModel:Update()
	
	local modelCoords = oldGhostModelUpdate(self)
	
	if self.circleRangeModel then
		self.circleRangeModel:SetIsVisible(false)
	end
	
	local player = Client.GetLocalPlayer()
	
	if modelCoords then
		local radius = LookupTechData(player.currentTechId, kVisualRange, nil)
		if radius and player.currentTechId ~= kTechId.Cyst then
			player:AddGhostGuide(Vector(modelCoords.origin), radius)
			if player.currentTechId == kTechId.Shift then
				player:AddGhostGuide(Vector(modelCoords.origin), kEnergizeRange)
			end
		end
	end
	
	return modelCoords
end

local oldCystGhostModelUpdate
oldCystGhostModelUpdate = Class_ReplaceMethod("CystGhostModel", "Update",
	function(self)
	
		oldCystGhostModelUpdate(self)
		
		local modelCoords = GhostModelUI_GetGhostModelCoords()
		
		if self.circleModel then
			self.circleModel:SetIsVisible(false)
		end
		
		if modelCoords then
			local player = Client.GetLocalPlayer()
			
			player:DestroyGhostGuides(true)
			
			local cystPoints = GetCystPoints(modelCoords.origin)
			
			if #cystPoints > 1 then
				player:AddGhostGuide(cystPoints[#cystPoints], kInfestationRadius)
			end
		end
	end)

Class_ReplaceMethod("Commander", "AddGhostGuide",
	function(self, origin, radius)
		local guide = nil

		if #self.reuseGhostGuides > 0 then
			guide = self.reuseGhostGuides[#self.reuseGhostGuides]
			table.remove(self.reuseGhostGuides, #self.reuseGhostGuides)
		end

		// Insert point, circle
		
		if not guide then
			guide = Client.CreateRenderDecal()
			guide.material = Client.CreateRenderMaterial()
		end

		local materialName = ConditionalValue(self:GetTeamType() == kAlienTeamType, PrecacheAsset("models/misc/circle/circle_alien.material"), PrecacheAsset("models/misc/circle/circle.material"))
		guide.material:SetMaterial(materialName)
		guide:SetMaterial(guide.material)
		local coords = Coords.GetTranslation(origin)
		guide:SetCoords( coords )
		guide:SetExtents(Vector(1,1,1)*radius)
		
		table.insert(self.ghostGuides, {origin, guide})
	end)
	
Class_ReplaceMethod("Commander", "DestroyGhostGuides",
	function(self, reuse)
		for index, guide in ipairs(self.ghostGuides) do
			if not reuse then
				Client.DestroyRenderDecal(guide[2])

			else
				guide[2]:SetExtents(Vector(0,0,0))
				table.insert(self.reuseGhostGuides, guide[2])
			end
		end
		
		if not reuse then
		
			for index, guide in ipairs(self.reuseGhostGuides) do
				Client.DestroyRenderMaterial(guide.material)
				Client.DestroyRenderDecal(guide)
				guide = nil
			end

			self.reuseGhostGuides = {}
			
		end

		self.ghostGuides = {}
	end)

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