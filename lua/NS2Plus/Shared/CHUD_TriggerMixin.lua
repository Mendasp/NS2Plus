function TriggerMixin:SetBox(setExtents)

    if self.triggerBody then
    
        Shared.DestroyCollisionObject(self.triggerBody)
        self.triggerBody = nil
        
    end
    
    local extents = setExtents * 0.2395
    local coords = self:GetAngles():GetCoords()

    coords.origin = Vector(self:GetOrigin())
    // The physics origin is at it's center
    coords.origin.y = coords.origin.y + extents.y
    
    self.triggerBody = Shared.CreatePhysicsBoxBody(false, extents, 0, coords)
    self.triggerBody:SetTriggerEnabled(true)
    self.triggerBody:SetCollisionEnabled(false)
    
    if self:GetMixinConstants().kPhysicsGroup then
        //Print("set trigger physics group to %s", EnumToString(PhysicsGroup, self:GetMixinConstants().kPhysicsGroup))
        self.triggerBody:SetGroup(self:GetMixinConstants().kPhysicsGroup)
    end
    
    if self:GetMixinConstants().kFilterMask then
        //Print("set trigger filter mask to %s", EnumToString(PhysicsMask, self:GetMixinConstants().kFilterMask))
        self.triggerBody:SetGroupFilterMask(self:GetMixinConstants().kFilterMask)
    end
    
    self.triggerBody:SetEntity(self)
    
end