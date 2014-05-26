// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========    
//    
// lua\MarineOutlineMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

MarineOutlineMixin = CreateMixin( MarineOutlineMixin )
MarineOutlineMixin.type = "MarineOutline"

MarineOutlineMixin.expectedMixins =
{
    Model = "For copying bonecoords and drawing model in view model render zone.",
}

function MarineOutlineMixin:__initmixin()

    if Client then
        self.marineOutlineVisible = false
		self.isParasited = false
    end

end

if Client then

    function MarineOutlineMixin:OnDestroy()

		local isParasited = ConditionalValue(self.isParasited, 3, 0)
        if self.marineOutlineVisible then
            local model = self:GetRenderModel()
            if model ~= nil then
                EquipmentOutline_RemoveModel( model, isParasited )
            end
        end
        
    end

    function MarineOutlineMixin:OnUpdate(deltaTime)   

        local player = Client.GetLocalPlayer()
        
        local model = self:GetRenderModel()
        if model ~= nil then 
        
            local outlineModel = Client.GetLocalClientTeamNumber() == kSpectatorIndex and Client.GetOutlinePlayers()

			if outlineModel and (HasMixin(self, "ParasiteAble") and self.isParasited ~= self:GetIsParasited()) and self.marineOutlineVisible then
				if self:GetIsParasited() then
					EquipmentOutline_RemoveModel( model, 0 )
					EquipmentOutline_AddModel( model, 3 )
				else
					EquipmentOutline_RemoveModel( model, 3 )
					EquipmentOutline_AddModel( model, 0 )
				end
			end
			
			self.isParasited = ConditionalValue(HasMixin(self, "ParasiteAble") and self:GetIsParasited(), 3, 0)
			
            if outlineModel and not self.marineOutlineVisible then

				EquipmentOutline_AddModel( model, self.isParasited )
                self.marineOutlineVisible = true 
            
            elseif self.marineOutlineVisible and not outlineModel then
            
                EquipmentOutline_RemoveModel( model, self.isParasited )
                self.marineOutlineVisible = false
            
            end
        
        end
            
    end

end