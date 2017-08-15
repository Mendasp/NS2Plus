local LoadData
local originalLowLights = { }
local cachedNSLLights = { }
lowLightsSwitched = false

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
	local filePath = "lights/" .. filename .. ".json"
	local fileExists = GetFileExists(filePath)
	if fileExists then
		local file = io.open(filePath, "r")
		if file then
			LoadData = json.decode(file:read("*all"))
			file:close()
		end
	end
	return LoadData
end

-- Save the low lights group to a json file
local function OnCommandSaveLights()
	if Client and Shared.GetCheatsEnabled() and #Client.lowLightList > 0 then
		local filename = Shared.GetMapName()
        local lightsFile = io.open("config://" .. filename .. ".json", "w+")
		lightsFile:write("[")
		for i, object in ipairs(Client.lowLightList) do
			object.values = UpdateValuesForObject(object.values, false)
			-- Disable casting shadows for all lights (can't really do this efficiently in the editor)
			if object.values.casts_shadows then
				object.values.casts_shadows = false
			end
			lightsFile:write(json.encode(object))
			if i < #Client.lowLightList then
				lightsFile:write(",\n")
			end
		end
		lightsFile:write("]")
		io.close(lightsFile)
		Shared.Message("Saved lights to " .. filename .. ".json")
	end
end

-- I don't remember how I got to make this function look like this
-- Fragile, do not touch
-- Rewrite, actually
function CHUDLoadLights()
	if not lowLightsSwitched then
	
		if CHUDGetOption("nsllights") or #Client.lowLightList == 0 then
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
		
	end
	
end

Event.Hook("Console_savelights", OnCommandSaveLights)