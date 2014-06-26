Grenade.kDetonateRadius = 0.17
Grenade.kRadius = 0.05

if Server then
	local oldGrenadeOnUpdate
	oldGrenadeOnUpdate = Class_ReplaceMethod( "Grenade", "OnUpdate",
		function ( self, deltaTime )
			local startTrace = self:GetOrigin()
			
			oldGrenadeOnUpdate( self, deltaTime )
			
			local endTrace = self:GetOrigin()
			
			local controller = self.projectileController
            local oldEnough = controller and ( controller.minLifeTime + controller.creationTime <= Shared.GetTime() )
			if oldEnough then
				local trace = Shared.TraceCapsule( startTrace, endTrace, Grenade.kDetonateRadius,  0, CollisionRep.Damage, PhysicsMask.PredictedProjectileGroup, EntityFilterOne(self) )
				
				if trace.fraction ~= 1 then
					if GetAreEnemies(self, trace.entity) then
						self:SetOrigin( trace.endPoint )
						self:Detonate( trace.entity )
					end
				end		
			end
		end)
end