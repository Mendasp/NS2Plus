local ResetShiftButtons
local function UpdateShiftButtons(self)

    ResetShiftButtons(self)

    local teleportAbles = GetEntitiesWithMixinForTeamWithinRange("TeleportAble", self:GetTeamNumber(), self:GetOrigin(), kEchoRange)    
    for _, teleportable in ipairs(teleportAbles) do
		
		if teleportable:GetCanTeleport() then
			if teleportable:isa("Hydra") then
				self.hydraInRange = true
			elseif teleportable:isa("Whip") then
				self.whipInRange = true
			elseif teleportable:isa("TunnelEntrance") then
				self.tunnelInRange = true
			elseif teleportable:isa("Crag") then
				self.cragInRange = true
			elseif teleportable:isa("Shade") then
				self.shadeInRange = true
			elseif teleportable:isa("Shift") then
				self.shiftInRange = true
			elseif teleportable:isa("Veil") then
				self.veilInRange = true
			elseif teleportable:isa("Spur") then
				self.spurInRange = true
			elseif teleportable:isa("Shell") then
				self.shellInRange = true
			elseif teleportable:isa("Hive") then
				self.hiveInRange = true
			elseif teleportable:isa("Egg") then
				self.eggInRange = true
			elseif teleportable:isa("Harvester") then
				self.harvesterInRange = true
			end
		end
    end

end
ReplaceUpValue( Shift.OnUpdate, "UpdateShiftButtons", UpdateShiftButtons, {CopyUpValues = true} )

local oldOnTeleportEnd 
oldOnTeleportEnd = Class_ReplaceMethod( "Shift", "OnTeleportEnd",
	function( self )
		oldOnTeleportEnd( self)
		UpdateShiftButtons(self)
	end)