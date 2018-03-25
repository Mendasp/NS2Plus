local originalGameInfo
originalGameInfo = Class_ReplaceMethod( "GameInfo", "OnCreate",
	function(self)
		
		originalGameInfo(self)
		
		self.showAvgSkill = CHUDServerOptions["showavgteamskill"].currentValue == true
		self.showProbability = CHUDServerOptions["showprobabilityofteamvictory"].currentValue == true
		self.showPlayerSkill = CHUDServerOptions["showplayerskill"].currentValue == true
		self.showEndStatsAuto = CHUDServerOptions["autodisplayendstats"].currentValue == true
		self.showEndStatsTeamBreakdown = CHUDServerOptions["endstatsteambreakdown"].currentValue == true
		
	end)

CHUDServerOptions["showavgteamskill"].applyFunction = function()
		GetGameInfoEntity().showAvgSkill = CHUDServerOptions["showavgteamskill"].currentValue
	end
CHUDServerOptions["showprobabilityofteamvictory"].applyFunction = function()
		GetGameInfoEntity().showProbability = CHUDServerOptions["showprobabilityofteamvictory"].currentValue
	end
CHUDServerOptions["showplayerskill"].applyFunction = function()
		GetGameInfoEntity().showPlayerSkill = CHUDServerOptions["showplayerskill"].currentValue
	end
CHUDServerOptions["autodisplayendstats"].applyFunction = function()
		GetGameInfoEntity().showEndStatsAuto = CHUDServerOptions["autodisplayendstats"].currentValue
	end
CHUDServerOptions["endstatsteambreakdown"].applyFunction = function()
		GetGameInfoEntity().showEndStatsTeamBreakdown = CHUDServerOptions["endstatsteambreakdown"].currentValue
	end