local LoadData
local originalLowLights = { }
local cachedNSLLights = { }
lowLightsSwitched = false
local propsRemoved = false
local PropCache = { }
local PropValuesCache = { }
local BlockedProps = { 	"models/props/veil/veil_hologram_01.model", 
						"models/props/veil/veil_holosign_01_nanogrid.model", 
						"models/props/veil/veil_hologram_01_scanlines.model",
						"models/props/biodome/biodome_bamboo_crown_01_01.model",
						"models/props/biodome/biodome_bamboo_crown_01_02.model",
						"models/props/biodome/biodome_bamboo_crown_01_03.model",																	
						"models/props/biodome/biodome_bamboo_crown_01_04.model",
						"models/props/biodome/biodome_bamboo_clump_01_01_high.model",
						"models/props/biodome/biodome_bamboo_clump_01_02_high.model",
						"models/props/biodome/biodome_bamboo_clump_01_03_high.model",
						"models/props/biodome/biodome_bamboo_clump_01_04_high.model",
						"models/props/biodome/biodome_bamboo_clump_01_05_high.model",
						"models/props/biodome/biodome_bamboo_clump_01_01_low.model",
						"models/props/biodome/biodome_bamboo_clump_01_02_low.model",
						"models/props/biodome/biodome_bamboo_clump_01_03_low.model",
						"models/props/biodome/biodome_bamboo_clump_01_04_low.model",
						"models/props/biodome/biodome_bamboo_clump_01_05_low.model",
						"models/props/biodome/biodome_waterfall_01.model",
						"models/props/biodome/biodome_grass_01_01.model",
						"models/props/biodome/biodome_grass_01_02.model",
						"models/props/biodome/biodome_grass_01_03.model",
						"models/props/biodome/biodome_grass_01_04.model",
						"models/props/biodome/biodome_grass_02_tile.model",
						"models/props/refinery/refinery_shipping_hologram_animated.model",
						"models/props/descent/descent_hologram_planet_01.model",
						"models/props/descent/descent_hologram_planet_02.model",
						"models/props/descent/descent_hologram_planet_03.model" }

						
local originalSetCommanderPropState = SetCommanderPropState
function SetCommanderPropState(isComm)
	originalSetCommanderPropState(isComm)
	if PropCache ~= nil then
		for index, propPair in ipairs(PropCache) do
			local prop = propPair[1]
			if prop.commAlpha < 1 then
				prop:SetIsVisible(not isComm)
			end
		end
	end
end

local originalLoadMapEntity = LoadMapEntity
function LoadMapEntity(className, groupName, values)
	local success = originalLoadMapEntity(className, groupName, values)
	if success then
		if className == "prop_static" and table.contains(BlockedProps, values.model) then
			table.insert(PropCache, Client.propList[#Client.propList])
			if not Client.fullyLoaded then
				table.insert(PropValuesCache, {className = className, groupName = groupName, values = values})
			end
			table.remove(Client.propList, #Client.propList)
		end
	end
	return success
end

local function UpdateValuesForObject(object, loading)
	if loading then
		object.angles = Angles(object.angles.pitch, object.angles.yaw, object.angles.roll)
		object.origin = Vector(object.origin.x, object.origin.y, object.origin.z)
		if object.color then
			object.color = Color(object.color.r, object.color.g, object.color.b, object.color.a)
		end
		if object.scale then
			object.scale = Vector(object.scale.x, object.scale.y, object.scale.z)
		end
		if object.color_dir_forward then
			object.color_dir_forward = Color(object.color_dir_forward.r, object.color_dir_forward.g, object.color_dir_forward.b, object.color_dir_forward.a)
			object.color_dir_backward = Color(object.color_dir_backward.r, object.color_dir_backward.g, object.color_dir_backward.b, object.color_dir_backward.a)
			object.color_dir_up = Color(object.color_dir_up.r, object.color_dir_up.g, object.color_dir_up.b, object.color_dir_up.a)
			object.color_dir_down = Color(object.color_dir_down.r, object.color_dir_down.g, object.color_dir_down.b, object.color_dir_down.a)
			object.color_dir_left = Color(object.color_dir_left.r, object.color_dir_left.g, object.color_dir_left.b, object.color_dir_left.a)
			object.color_dir_right = Color(object.color_dir_right.r, object.color_dir_right.g, object.color_dir_right.b, object.color_dir_right.a)
		end
	else
		object.angles = { pitch = object.angles.pitch, yaw = object.angles.yaw, roll = object.angles.roll }
		object.origin = { x = object.origin.x, y = object.origin.y, z = object.origin.z }
		if object.color then
			object.color = { r = object.color.r, g = object.color.g, b = object.color.b, a = object.color.a }
		end
		if object.scale then
			object.scale = { x = object.scale.x, y = object.scale.y, z = object.scale.z }
		end
		if object.color_dir_forward then
			object.color_dir_forward = { r = object.color_dir_forward.r, g = object.color_dir_forward.g, b = object.color_dir_forward.b, a = object.color_dir_forward.a }
			object.color_dir_backward = { r = object.color_dir_backward.r, g = object.color_dir_backward.g, b = object.color_dir_backward.b, a = object.color_dir_backward.a }
			object.color_dir_up = { r = object.color_dir_up.r, g = object.color_dir_up.g, b = object.color_dir_up.b, a = object.color_dir_up.a }
			object.color_dir_down = { r = object.color_dir_down.r, g = object.color_dir_down.g, b = object.color_dir_down.b, a = object.color_dir_down.a }
			object.color_dir_left = { r = object.color_dir_left.r, g = object.color_dir_left.g, b = object.color_dir_left.b, a = object.color_dir_left.a }
			object.color_dir_right = { r = object.color_dir_right.r, g = object.color_dir_right.g, b = object.color_dir_right.b, a = object.color_dir_right.a }
		end
	end
	return object
end

local function LoadLightData(filename)
	local LoadData
	local file = io.open("lights/" .. filename .. ".json", "r")
	if file then
		LoadData = json.decode(file:read("*all"))
		file:close()
	end
	return LoadData
end

function CHUDLoadLights()
	if not lowLightsSwitched then
	
		if CHUDSettings["nsllights"] or #Client.lowLightList == 0 then
			if #cachedNSLLights == 0 then
				LoadData = LoadLightData(Shared.GetMapName())
			
				if LoadData then
					for i, object in pairs(LoadData) do
						object.values = UpdateValuesForObject(object.values, true)
					end
					
					cachedNSLLights = LoadData
				end
			else
				LoadData = cachedNSLLights
			end
			
			if LoadData then
				originalLowLights = Client.lowLightList
				Client.lowLightList = LoadData
				lowLightsSwitched = true
			end
			
		elseif #originalLowLights > 0 then
			Client.lowLightList = originalLowLights
			lowLightsSwitched = true
		end
		
		ReplaceLocals(Lights_UpdateLightMode, { gLowLights = false })
	
		Lights_UpdateLightMode()
		
		if Client.GetIsConnected() then
		
			for _, onos in ientitylist(Shared.GetEntitiesWithClassname("Onos")) do            
				onos:RecalculateShakeLightList()        
			end
		
		end
		
		// Prop stuff
		if CHUDSettings["nsllights"] then
			if PropCache ~= nil then
				for index, models in ipairs(PropCache) do
					Client.DestroyRenderModel(models[1])
					Shared.DestroyCollisionObject(models[2])
				end
				PropCache = { }
				propsRemoved = true
			end
		elseif propsRemoved then
			for i, prop in pairs(PropValuesCache) do
				LoadMapEntity(prop.className, prop.groupName, prop.values)
			end
		end
	end
end