local kMinTimeNameChange = 5
local kMaxChanges = 3
local kPenaltyTime = 60
local originalPlayerSetName
originalPlayerSetName = Class_ReplaceMethod( "Player", "SetName",
	function(self, name)
		-- NSPlayer is a restricted name and is set when connecting, don't treat it as a change
		if not self.lastNameChange or name == "NSPlayer" then
			self.lastNameChange = -(kMinTimeNameChange*2)
			self.changes = 0
			self.nextAllowedNameChange = 0
		end
		
		if self.lastNameChange + kMinTimeNameChange > Shared.GetTime(true) and self:GetName() ~= "NSPlayer" then
			self.changes = self.changes + 1
		else
			self.changes = 0
		end
		
		if self.changes > kMaxChanges and self.nextAllowedNameChange < Shared.GetTime(true) then
			self.nextAllowedNameChange = Shared.GetTime(true) + kPenaltyTime - kMinTimeNameChange
			local client = self:GetClient()
			if client then
				CHUDServerAdminPrint(client, "You have changed your name too often in a short time, you will be able to change your name again in " .. kPenaltyTime .. " seconds.")
			end
		end
		
		if self.nextAllowedNameChange < Shared.GetTime(true) then
			self.lastNameChange = Shared.GetTime(true)
			originalPlayerSetName(self, name)
		end
	end)
