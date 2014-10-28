Script.Load("lua/Hud/Commander/GhostModel.lua")

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