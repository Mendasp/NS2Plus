gCHUDHiddenViewModel = true

local reloadFraction = -1
local overheatLeftFraction = -1
local overheatRightFraction = -1

function CHUDGetReloadFraction()
	return math.min(reloadFraction, 1)
end

function CHUDGetOverheatFraction()
	return math.min(overheatLeftFraction, 1), math.min(overheatRightFraction, 1)
end

--Todo: Clean this up to work with less locals
local insertNum
local lastSeq
local initialFraction
local originalViewModelOnUpdateRender
local lastReloadFraction
originalViewModelOnUpdateRender = Class_ReplaceMethod("ViewModel", "OnUpdateRender",
	function(self)
		originalViewModelOnUpdateRender(self)
		
		local player = Client.GetLocalPlayer()
		local drawviewmodel = CHUDGetOption("drawviewmodel")
		local drawviewmodel_a = CHUDGetOption("drawviewmodel_a")
		gCHUDHiddenViewModel = drawviewmodel == 1 or
			drawviewmodel == 2 and
			(
				player:isa("Marine") and not CHUDGetOption("drawviewmodel_m") or
				player:isa("Exo") and not CHUDGetOption("drawviewmodel_exo") or
				player:isa("Alien") and drawviewmodel_a ~= 0 and
				(
					drawviewmodel_a == 1 or
					player:isa("Skulk") and not CHUDGetOption("drawviewmodel_skulk") or
					player:isa("Gorge") and not CHUDGetOption("drawviewmodel_gorge") or
					player:isa("Lerk") and not CHUDGetOption("drawviewmodel_lerk") or
					player:isa("Fade") and not CHUDGetOption("drawviewmodel_fade") or
					player:isa("Onos") and not CHUDGetOption("drawviewmodel_onos")
				)
			)
		
		self:SetIsVisible(trollModes["swalkMode"] or self:GetIsVisible() and not gCHUDHiddenViewModel)
		
		reloadFraction = -1
		local weapon = self:GetWeapon()
		if weapon then
			if player:isa("Marine") or player:isa("Exo") then
				local model = Shared.GetModel(self.modelIndex)
				if model then
					local seqLength = model:GetSequenceLength(self.animationSequence)
					local seqName = model:GetSequenceName(self.animationSequence)
					if lastSeq ~= seqName then
						lastSeq = seqName
						if weapon:isa("Shotgun") then
							if seqName == "reload_start" then
								insertNum = weapon:GetClip()
							elseif seqName == "reload_insert" then
								insertNum = insertNum or weapon:GetClip()
								insertNum = insertNum + 1
								initialFraction = insertNum/weapon:GetClipSize()
							end
						elseif weapon:isa("GrenadeLauncher") then
							if string.find(seqName, "reload") and not string.find(seqName, "end") or not seqName == "reload_one" then
								insertNum = weapon:GetClip()
								initialFraction = insertNum/weapon:GetClipSize()
							end
						end
					end
					
					if seqName == "reload" or weapon:isa("Rifle") and seqName == "secondary" then
						reloadFraction = (Shared.GetTime()-self.animationStart) / (seqLength/self.animationSpeed)
					elseif weapon:isa("Shotgun") then
						if seqName == "reload_start" then
							reloadFraction = (insertNum + (Shared.GetTime()-self.animationStart) / (seqLength/self.animationSpeed)) / weapon:GetClipSize()
						elseif seqName == "reload_insert" then
							reloadFraction = initialFraction + (Shared.GetTime()-self.animationStart) / (seqLength*(weapon:GetClipSize()-insertNum)/self.animationSpeed)*(1-initialFraction)
						end
					elseif weapon:isa("GrenadeLauncher") then
						if string.find(seqName, "reload") then
							if not string.find(seqName, "end") or not seqName == "reload_one" then
								reloadFraction = (insertNum + (Shared.GetTime()-self.animationStart) / (seqLength/self.animationSpeed)) / weapon:GetClipSize()
								lastReloadFraction = reloadFraction
							else
								reloadFraction = lastReloadFraction + (Shared.GetTime()-self.animationStart) / (seqLength/self.animationSpeed)*(1-lastReloadFraction)
							end
						end
					elseif weapon:isa("ExoWeaponHolder") then
						overheatLeftFraction = -1
						overheatRightFraction = -1
						local leftWeapon = Shared.GetEntity(weapon.leftWeaponId)
						local rightWeapon = Shared.GetEntity(weapon.rightWeaponId)
						if leftWeapon:isa("Minigun") and seqName == "attack_l_heat" then
							overheatLeftFraction = (Shared.GetTime()-self.animationStart) / (seqLength/self.animationSpeed)
						end
						if rightWeapon:isa("Minigun") and model:GetSequenceName(self.layer1AnimationSequence) == "attack_r_heat" then
							overheatRightFraction = (Shared.GetTime()-self.layer1AnimationStart) / (model:GetSequenceLength(self.layer1AnimationSequence)/self.layer1AnimationSpeed)
						end
					end
				end
			elseif player:isa("Alien") then
				reloadFraction = AlienUI_GetMovementSpecialCooldown()
			end
		end
	end)

-- Correct heat display on Exos for their cooldown with the animation progress (not the heat amount)
-- The animation is what determines how long it's going to take until we can actually fire again
local oldMinigunOnUpdateRender
oldMinigunOnUpdateRender = Class_ReplaceMethod("Minigun", "OnUpdateRender",
	function(self)
		oldMinigunOnUpdateRender(self)
		
		if self.heatDisplayUI then
			local slotName = self:GetExoWeaponSlotName()
			local leftOverheatFraction, rightOverheatFraction = CHUDGetOverheatFraction()
			local overheatFraction = slotName == "left" and leftOverheatFraction or rightOverheatFraction
			if overheatFraction > -1 then
				self.heatDisplayUI:SetGlobal("heatAmount" .. slotName, math.min(1, 1-overheatFraction))
			end
		end
	end)

local direction = 1
local rollVM = 0
local rollIncrementViewModel = 0.01
local originalViewModelOnAdjustModelCoords
originalViewModelOnAdjustModelCoords = Class_ReplaceMethod("ViewModel", "OnAdjustModelCoords",
	function(self, coords)
	
		local newCoords = originalViewModelOnAdjustModelCoords(self, coords)
		local rollIncrement
		if trollModes["swalkMode"] and self:GetNumModelCameras() > 0 and coords and newCoords then
			
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
		if trollModes["swalkMode"] and cameraCoords and newCoords then
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