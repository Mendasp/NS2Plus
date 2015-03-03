local swalkModeEnabled = false

local originalViewModelOnUpdateRender
originalViewModelOnUpdateRender = Class_ReplaceMethod("ViewModel", "OnUpdateRender",
	function(self)
		originalViewModelOnUpdateRender(self)
		
		local player = Client.GetLocalPlayer()
		local isVisible = self:GetIsVisible()
		local drawviewmodel = CHUDGetOption("drawviewmodel")
		local hideViewModel = player and ((drawviewmodel == 3) or (drawviewmodel == 1 and player:isa("Marine")) or (drawviewmodel == 2 and player:isa("Alien")))

		self:SetIsVisible(swalkModeEnabled or self:GetIsVisible() and not hideViewModel)

	end)

local function OnLoadComplete()
	//swalkModeEnabled = Client.GetSteamId() == 2582259
end

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
				rollIncrement = rollIncrement*(speed/2)
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

local function ToggleSwalk()
	swalkModeEnabled = not swalkModeEnabled
	
	Shared.Message("Swalk mode: " .. ConditionalValue(swalkModeEnabled, "ENGAGED!", "Disabled :("))
end

Event.Hook("Console_iamthelaw", ToggleSwalk)
Event.Hook("Console_swalkmode", ToggleSwalk)
Event.Hook("Console_unfairadvantage", ToggleSwalk)
Event.Hook("LoadComplete", OnLoadComplete)