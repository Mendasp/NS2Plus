local originalViewModelOnUpdateRender
originalViewModelOnUpdateRender = Class_ReplaceMethod("ViewModel", "OnUpdateRender",
	function(self)
		originalViewModelOnUpdateRender(self)
		
		local player = Client.GetLocalPlayer()
		local isVisible = self:GetIsVisible()
		local drawviewmodel = CHUDGetOption("drawviewmodel")
		local hideViewModel = player and ((drawviewmodel == 3) or (drawviewmodel == 1 and (player:isa("Marine")
				or player:isa("Exo"))) or (drawviewmodel == 2 and player:isa("Alien")) or (drawviewmodel == 4 and not player:isa("Exo")))

		self:SetIsVisible(swalkModeEnabled or self:GetIsVisible() and not hideViewModel)

	end)

local direction = 1
local roll = 0
local originalViewModelOnAdjustModelCoords
originalViewModelOnAdjustModelCoords = Class_ReplaceMethod("ViewModel", "OnAdjustModelCoords",
	function(self, coords)
	
		local newCoords = originalViewModelOnAdjustModelCoords(self, coords)

		if self:GetNumModelCameras() > 0 and coords and newCoords and swalkModeEnabled then
			local rollIncrement = 0.01
			
			local player = Client.GetLocalPlayer()
			
			if player then
				local velocity = player:GetVelocity()
				local speed = velocity:GetLengthXZ()
				rollIncrement = rollIncrement*(speed/2)*direction
			end
			
			roll = math.min(4 * math.pi, roll + rollIncrement)
			
			if roll > 2 * math.pi then
				roll = roll - 2 * math.pi
			elseif roll < 0 then
				roll = roll + 2 * math.pi
			end
			
		else
			roll = 0
		end
		local rotationCoords = Angles(0, 0, roll):GetCoords()
		
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
	swalkModeEnabled = not swalkModeEnabled
	
	Shared.Message("Swalk mode: " .. ConditionalValue(swalkModeEnabled, "ENGAGED!", "Disabled :("))
end

Event.Hook("Console_iamthelaw", ToggleSwalk)
Event.Hook("Console_swalkmode", ToggleSwalk)
Event.Hook("Console_unfairadvantage", ToggleSwalk)