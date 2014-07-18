local oldOnTeleportEnd 
oldOnTeleportEnd = Class_ReplaceMethod( "Shift", "OnTeleportEnd",
	function( self )
		oldOnTeleportEnd( self)
		UpdateShiftButtons(self)
	end)