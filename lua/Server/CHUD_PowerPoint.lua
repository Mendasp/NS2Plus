
local kMinFullLightDelay = 2
local kFullPowerOnTime = 4
local kMaxFullLightDelay = 4
Class_ReplaceMethod( "PowerPoint", "SetLightMode", 
	function( self, lightMode) 
		
		if self:GetIsDisabled() then
			lightMode = kLightMode.NoPower
		end
		
		local time = Shared.GetTime()
		
		if self.lastLightMode == kLightMode.NoPower and lightMode == kLightMode.Damaged then
			local fullFullLightTime = self.timeOfLightModeChange + kMinFullLightDelay + kMaxFullLightDelay + kFullPowerOnTime    
			if time < fullFullLightTime then
				// Don't allow the light mode to change to damaged until after the power is fully restored
				return
			end
		end

		// Don't change light mode too often or lights will change too much
		if self.lightMode ~= lightMode or (not self.timeOfLightModeChange or (time > (self.timeOfLightModeChange + 1.0))) then
			self.lastLightMode, self.lightMode = self.lightMode, lightMode		
			self.timeOfLightModeChange = time
		end
		
	end)