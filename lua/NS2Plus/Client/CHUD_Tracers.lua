-- MODIFIED FROM BETTER NS2 BY LWF

Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
local OriginalClipFreq
OriginalClipFreq = Class_ReplaceMethod( "ClipWeapon", "GetTracerEffectFrequency", 
	function(self)
	
		if not CHUDGetOption("tracers") then
			return 0
		else
			return OriginalClipFreq(self)
		end
	
	end
)

Script.Load("lua/Weapons/Marine/Shotgun.lua")
local OriginalShotgunFreq
OriginalShotgunFreq = Class_ReplaceMethod( "Shotgun", "GetTracerEffectFrequency", 
	function(self)
	
		if not CHUDGetOption("tracers") then
			return 0
		else
			return OriginalShotgunFreq(self)
		end
	
	end
)

Script.Load("lua/Weapons/Marine/Minigun.lua")
local OriginalMinigunFreq
OriginalMinigunFreq = Class_ReplaceMethod( "Minigun", "GetTracerEffectFrequency", 
	function(self)
	
		if not CHUDGetOption("tracers") then
			return 0
		else
			return OriginalMinigunFreq(self)
		end
	
	end
)
