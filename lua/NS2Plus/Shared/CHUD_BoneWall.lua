AppendToEnum( kMinimapBlipType, "BoneWall" )

-- ClassToGrid is a map of class names to a grid position on the spritesheet
-- ui/minimap_blip.dds and it's defined in NS2Utility.lua
local originalBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
	local map = originalBuildClassToGrid()

	-- 8,3 is apparently a "Kill" blip, which i think is unused. it seems to suit
	-- our purposes okay, but if need be there's room to add another blip. not
	-- sure what a BoneWall blip would look like anyway.
	map["BoneWall"] = { 8, 3 }
	return map
end

-- add the MapBlipMixin to BoneWall
if Server then
	originalBoneWallOnCreate = Class_ReplaceMethod( "BoneWall", "OnCreate",
		function(self)
			originalBoneWallOnCreate(self)

			InitMixin(self, MapBlipMixin)
		end
	)
end

-- Add range to bonewalls before dropping
LookupTechData(kTechId.BoneWall, kVisualRange, 2.75)