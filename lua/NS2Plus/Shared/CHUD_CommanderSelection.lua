Script.Load("lua/Commander_Selection.lua")

local originalGetUnitUnderCursor
originalGetUnitUnderCursor = Class_ReplaceMethod( "Commander", "GetUnitUnderCursor",
function(self, pickVec)

	local player = Client.GetLocalPlayer()

	local entity = originalGetUnitUnderCursor(self, pickVec)

	if entity and entity:isa("Marine") and player:isa("MarineCommander") and not CHUDGetOption("marinecommselect") then
		entity = nil
	end

	return entity

end)
