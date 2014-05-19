-- we need to completly replace the kMinimapBlipType enum because an enum cannot
-- be altered after creation. so, we're basically going to clone as just a
-- regular table instead of an enum. should be fine I guess, apparently enums
-- are just tables anyway.
local blipTypes = {}
local maxVal, key = 0
for k, v in pairs(kMinimapBlipType) do
	if type(v) == number and v > maxVal then
		maxVal, key = v, k
	end
	blipTypes[k] = v
end

-- append the entry for BoneWall, effectively registering it as a new blip type
blipTypes["BoneWall"] = maxVal + 1
blipTypes[maxVal + 1] = "BoneWall"
kMinimapBlipType = blipTypes

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