
	function Exosuit:OnUseDeferred()
		
		local player = self.useRecipient 
		self.useRecipient = nil
		
		if player and not player:GetIsDestroyed() and self:GetIsValidRecipient(player) then
		
            local weapons = player:GetWeapons()
            for i = 1, #weapons do            
                weapons[i]:SetParent(nil)            
            end

            local exoPlayer = nil

            if self.layout == "MinigunMinigun" then
                exoPlayer = player:GiveDualExo()            
            elseif self.layout == "RailgunRailgun" then
                exoPlayer = player:GiveDualRailgunExo()
            elseif self.layout == "ClawRailgun" then
                exoPlayer = player:GiveClawRailgunExo()
            else
                exoPlayer = player:GiveExo()
            end  

            if exoPlayer then
                           
                for i = 1, #weapons do
                    exoPlayer:StoreWeapon(weapons[i])
                end 

                exoPlayer:SetMaxArmor(self:GetMaxArmor())  
                exoPlayer:SetArmor(self:GetArmor())
                
                local newAngles = player:GetViewAngles()
                newAngles.pitch = 0
                newAngles.roll = 0
                newAngles.yaw = GetYawFromVector(self:GetCoords().zAxis)
                exoPlayer:SetOffsetAngles(newAngles)
                // the coords of this entity are the same as the players coords when he left the exo, so reuse these coords to prevent getting stuck
                exoPlayer:SetCoords(self:GetCoords())
                
                self:TriggerEffects("pickup")
                DestroyEntity(self)
                
            end
            
		end
	
	end

    function Exosuit:OnUse(player, elapsedTime, useSuccessTable)
    
        if self:GetIsValidRecipient( player ) and ( not self.useRecipient or self.useRecipient:GetIsDestroyed() ) then
			
			self.useRecipient = player
			self:AddTimedCallback( self.OnUseDeferred, 0 )			 
            
        end
        
    end
    
	function Jetpack:OnUseDeferred()
		
		local player = self.useRecipient 
		self.useRecipient = nil
		
		if player and not player:GetIsDestroyed() and self:GetIsValidRecipient(player) then
		
            player:GiveJetpack()
            self:TriggerEffects("pickup")
            DestroyEntity(self)
		
		end
	
	end

    function Jetpack:OnUse(player, elapsedTime, useSuccessTable)
    
        if self:GetIsValidRecipient( player ) and ( not self.useRecipient or self.useRecipient:GetIsDestroyed() ) then
			
			self.useRecipient = player
			self:AddTimedCallback( self.OnUseDeferred, 0 )			 
            
        end
        
    end