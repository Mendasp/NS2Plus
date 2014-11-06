local originalGameInfo
originalGameInfo = Class_ReplaceMethod( "GameInfo", "OnCreate",
	function(self)
		
		originalGameInfo(self)
		
		self.showAvgSkill = CHUDServerOptions["showavgteamskill"].currentValue == true
		
	end)

CHUDServerOptions["showavgteamskill"].applyFunction = function()
		GetGameInfoEntity().showAvgSkill = CHUDServerOptions["showavgteamskill"].currentValue
	end