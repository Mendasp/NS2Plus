local oldCommanderUpdateGhostGuides = Commander.UpdateGhostGuides
function Commander:UpdateGhostGuides()
	oldCommanderUpdateGhostGuides(self)

	for index, entity in ipairs(self.selectedEntities) do
		local visualRadius = entity:GetVisualRadius()

		if visualRadius then
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
end