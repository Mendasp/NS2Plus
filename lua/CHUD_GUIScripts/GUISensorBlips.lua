PrecacheAsset("ui/chud_sensor.dds")

local originalSensorBlipsUpdate
originalSensorBlipsUpdate = Class_ReplaceMethod( "GUISensorBlips", "Update",
	function (self, deltaTime)
		if CHUDGetOption("motiontracking") == 0 then
			GUISensorBlips.kBlipImageName = "ui/sensor.dds"
		else
			GUISensorBlips.kBlipImageName = "ui/chud_sensor.dds"
		end
	
		originalSensorBlipsUpdate(self, deltaTime)
	end
)