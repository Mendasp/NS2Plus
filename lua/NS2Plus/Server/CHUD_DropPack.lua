local commDrops = { "ammopack", "medpack", "catpack" }
local originalDropPackOnInit
originalDropPackOnInit = Class_ReplaceMethod( "DropPack", "OnInitialized",
	function(self)
	
		originalDropPackOnInit(self)
		
		local mapName = self:GetMapName()
		
		if table.contains(commDrops, mapName) then
			CHUDCommStats[CHUDMarineComm][mapName].misses = CHUDCommStats[CHUDMarineComm][mapName].misses + 1
		end
	
	end)