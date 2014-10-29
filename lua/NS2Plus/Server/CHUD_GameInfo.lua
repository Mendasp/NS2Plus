local originalGameInfo
originalGameInfo = Class_ReplaceMethod( "GameInfo", "OnCreate",
	function(self)
		
		originalGameInfo(self)
		
		self.showAvgSkill = CHUDServerOptions["showavgteamskill"].currentValue == true
		local showAvgSkill = ConditionalValue(self.showAvgSkill, "Enabled", "Disabled")
		Shared.Message("[NS2+] Display team avg. skill: " .. showAvgSkill)
		
	end)

CHUDServerOptions["showavgteamskill"].applyFunction = function()
		GetGameInfoEntity().showAvgSkill = CHUDServerOptions["showavgteamskill"].currentValue
	end