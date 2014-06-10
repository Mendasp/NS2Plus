Class_ReplaceMethod( "LayMines", "GetIsValidRecipient", function( self, recipient)

    if self:GetParent() == nil and recipient and not GetIsVortexed(recipient) and recipient:isa("Marine") then
    
        return true
        
    end
    
    return false
    
end)
