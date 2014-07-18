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


-- Try to select enemy units if the marquee returns no entities
local oldGetSelectablesOnScreen = GetSelectablesOnScreen
function GetSelectablesOnScreen(commander, className, minPos, maxPos)

	local selected = oldGetSelectablesOnScreen(commander, className, minPos, maxPos)
	
	if #selected == 0 then
		if not className then
			className = "Entity"
		end
		
		local selectables = {}

		if not minPos then
			minPos = Vector(0,0,0)
		end
		
		if not maxPos then
			maxPos = Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0)
		end
		
		local oppositeTeam = ConditionalValue(commander:GetTeamNumber() == kTeam1Index, kTeam2Index, kTeam1Index)

		for _, selectable in ipairs(GetEntitiesWithMixinForTeam("Selectable", oppositeTeam)) do

			if selectable:isa(className) then

				local screenPos = Client.WorldToScreen(selectable:GetOrigin())
				if screenPos.x >= minPos.x and screenPos.x <= maxPos.x and
				   screenPos.y >= minPos.y and screenPos.y <= maxPos.y then
			
					table.insert(selectables, selectable)
			
				end
			
			end

		end
		
		selected = selectables
	end
	
	return selected

end
