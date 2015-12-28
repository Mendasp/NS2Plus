gCHUDHiddenViewModel = true
local originalViewModelOnUpdateRender
originalViewModelOnUpdateRender = Class_ReplaceMethod("ViewModel", "OnUpdateRender",
	function(self)
		originalViewModelOnUpdateRender(self)
		
		local player = Client.GetLocalPlayer()
		local drawviewmodel = CHUDGetOption("drawviewmodel")
		gCHUDHiddenViewModel = drawviewmodel == 1 or
			(drawviewmodel == 2 and
				((player:isa("Marine") and not CHUDGetOption("drawviewmodel_m")) or
				(player:isa("Alien") and not CHUDGetOption("drawviewmodel_a")) or
				(player:isa("Exo") and not CHUDGetOption("drawviewmodel_exo")))
			)

		self:SetIsVisible(trollModes["swalkMode"] or self:GetIsVisible() and not gCHUDHiddenViewModel)

	end)

local direction = 1
local rollVM = 0
local rollIncrementViewModel = 0.01
local originalViewModelOnAdjustModelCoords
originalViewModelOnAdjustModelCoords = Class_ReplaceMethod("ViewModel", "OnAdjustModelCoords",
	function(self, coords)
	
		local newCoords = originalViewModelOnAdjustModelCoords(self, coords)
		local rollIncrement
		if self:GetNumModelCameras() > 0 and coords and newCoords and trollModes["swalkMode"] then
			
			local player = Client.GetLocalPlayer()
			
			if player then
				local velocity = player:GetVelocity()
				local speed = velocity:GetLengthXZ()
				rollIncrement = (speed/2)*direction*rollIncrementViewModel
			end
			
			rollVM = rollVM + rollIncrement
			
			if rollVM > 2 * math.pi then
				rollVM = rollVM - 2 * math.pi
			elseif rollVM < 0 then
				rollVM = rollVM + 2 * math.pi
			end
			
		else
			rollVM = 0
		end
		local rotationCoords = Angles(0, 0, rollVM):GetCoords()
		
		return newCoords * rotationCoords

	end)

local rollCamera = 0
local rollIncrementCamera = 0.005
local originalGetCameraViewCoordsOverride
originalGetCameraViewCoordsOverride = Class_ReplaceMethod("Player", "GetCameraViewCoordsOverride",
	function(self, cameraCoords)
	
		local newCoords = originalGetCameraViewCoordsOverride(self, cameraCoords)
		local rollIncrement
		if cameraCoords and newCoords and trollModes["swalkMode"] then
			local player = Client.GetLocalPlayer()
			
			if player then
				local velocity = player:GetVelocity()
				local speed = velocity:GetLengthXZ()
				rollIncrement = (speed/2)*direction*rollIncrementCamera
			end
			
			rollCamera = rollCamera + rollIncrement
			
			if rollCamera > 2 * math.pi then
				rollCamera = rollCamera - 2 * math.pi
			elseif rollCamera < 0 then
				rollCamera = rollCamera + 2 * math.pi
			end
			
		else
			rollCamera = 0
		end
		local rotationCoords = Angles(0, 0, rollCamera):GetCoords()
		
		return newCoords * rotationCoords

	end)

local lastBack, lastLeft, lastRight, lastForward
local originalSKE
originalSKE = Class_ReplaceMethod("GUIManager", "SendKeyEvent",
function(self, key, down, amount)
	local ret = originalSKE(self, key, down, amount)
	
	if GetIsBinding(key, "MoveBackward") then
		if down ~= lastBack then
			lastBack = down
		end
	end
	
	if GetIsBinding(key, "MoveLeft") then
		if down ~= lastLeft then
			lastLeft = down
		end
	end
	
	if GetIsBinding(key, "MoveRight") then
		if down ~= lastRight then
			lastRight = down
		end
	end
	
	if GetIsBinding(key, "MoveForward") then
		if down ~= lastForward then
			lastForward = down
		end
	end
	
	if (lastLeft and not lastBack and not lastRight and not lastForward) or lastBack then
		direction = -1
	else
		direction = 1
	end
	
	return ret
end)

local function ToggleSwalk()
	trollModes["swalkMode"] = not trollModes["swalkMode"]
	
	Shared.Message("Swalk mode: " .. ConditionalValue(trollModes["swalkMode"], "ENGAGED!", "Disabled :("))
	if trollModes["swalkMode"] then
		Shared.Message("swalkmode_vmspeed (-100 to 100) - Controls the speed of the viewmodel roll")
		Shared.Message("swalkmode_cameraspeed (-100 to 100) - Controls the speed of the camera roll")
	end
end

local function VMSpeed(speed)
	if speed then
		speed = tonumber(speed)
		if IsNumber(speed) and speed >= -100 and speed <= 100 then
			rollIncrementViewModel = speed / 10000
			rollVM = 0
			rollCamera = 0
		else
			Shared.Message("Invalid parameter.")
		end
	else
		Shared.Message("Invalid parameter.")
	end
end

local function CameraSpeed(speed)
	if speed then
		speed = tonumber(speed)
		if IsNumber(speed) and speed >= -100 and speed <= 100 then
			rollIncrementCamera = speed / 10000
			rollVM = 0
			rollCamera = 0
		else
			Shared.Message("Invalid parameter.")
		end
	else
		Shared.Message("Invalid parameter.")
	end
end

Event.Hook("Console_iamthelaw", ToggleSwalk)
Event.Hook("Console_swalkmode", ToggleSwalk)
Event.Hook("Console_swalkmode_vmspeed", VMSpeed)
Event.Hook("Console_swalkmode_cameraspeed", CameraSpeed)
Event.Hook("Console_unfairadvantage", ToggleSwalk)