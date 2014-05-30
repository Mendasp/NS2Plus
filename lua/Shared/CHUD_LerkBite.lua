Class_ReplaceMethod( "LerkBite", "GetDeathIconIndex", 
	function(self)

		if self.primaryAttacking then
			return kDeathMessageIcon.LerkBite
		else
			return kDeathMessageIcon.Spikes
		end
		
	end)