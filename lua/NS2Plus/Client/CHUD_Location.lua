Class_ReplaceMethod("Location", "OnUpdateRender",
    function(self)
    
        PROFILE("Location:OnUpdateRender")
        
        local player = Client.GetLocalPlayer()      

        local showPowerStatus = player and player.GetShowPowerIndicator and player:GetShowPowerIndicator()
        local powerPoint

        if showPowerStatus then
            powerPoint = GetPowerPointForLocation(self.name)
            showPowerStatus = powerPoint ~= nil   
        end  
        
        if showPowerStatus then
                
            self:ShowPowerStatus(powerPoint:GetIsPowering())
            if self.powerDecal then
            
                // TODO: Doesn't need to be updated every frame, only setup on creation.
            
                local origin = self:GetOrigin()
                local extents = self.scale * 0.2395
                extents.y = 10
                origin.y = powerPoint:GetOrigin().y - 2

                local coords = Coords.GetTranslation(origin)
                
                // Get the origin in the object space of the decal.
                local osOrigin = coords:GetInverse():TransformPoint( powerPoint:GetOrigin() )
                self.powerMaterial:SetParameter("osOrigin", osOrigin)

                self.powerDecal:SetCoords(coords)
                self.powerDecal:SetExtents(extents)
                
            end
            
        else
            self:HidePowerStatus()
        end   
        
    end)