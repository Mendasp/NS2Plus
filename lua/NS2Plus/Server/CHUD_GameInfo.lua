local originalGameInfo
originalGameInfo = Class_ReplaceMethod( "GameInfo", "OnCreate",
	function(self)
	
		originalGameInfo(self)
		
		self.showAvgSkill = CHUDServerOptions["showavgteamskill"].currentValue == true
	
	end)

-- This should be rewritten properly with the mod updater stuff to apply setting changes efficiently
local showAvgSkill = false
local function GameInfoUpdater()
	if showAvgSkill ~= CHUDServerOptions["showavgteamskill"].currentValue then
		showAvgSkill = CHUDServerOptions["showavgteamskill"].currentValue
		GetGameInfoEntity().showAvgSkill = showAvgSkill
	end
end

Event.Hook("UpdateServer", GameInfoUpdater)