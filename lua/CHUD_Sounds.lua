Script.Load("lua/EffectManager.lua")
local blockedEffects = {	"complete_order",
							"upgrade_complete" }
originalTriggerEffects = Class_ReplaceMethod( "EffectManager", "TriggerEffects",
	function(self, effectName, tableParams, triggeringEntity)
		if not table.contains(blockedEffects, effectName) then
			originalTriggerEffects(self, effectName, tableParams, triggeringEntity)
		elseif	(effectName == "complete_order" and CHUDGetOption("wps")) or
				(effectName == "upgrade_complete" and CHUDGetOption("unlocks")) then
			originalTriggerEffects(self, effectName, tableParams, triggeringEntity)
		end
	end
)

local blockedVO = {	"sound/NS2.fev/marine/voiceovers/commander/build",
					"sound/NS2.fev/marine/voiceovers/commander/defend",
					"sound/NS2.fev/marine/voiceovers/move" }
					
Script.Load("lua/SoundEffect.lua")
function StartSoundEffectOnEntity(soundEffectName, onEntity, volume, predictor)
	if not table.contains(blockedVO, soundEffectName) or CHUDGetOption("wps") then
		Shared.PlaySound(onEntity, soundEffectName, volume or 1)
	end
end

function StartSoundEffect(soundEffectName, volume)
	if soundEffectName ~= "sound/NS2.fev/common/dead" or CHUDGetOption("ambient") then
		Shared.PlaySound(nil, soundEffectName, volume or 1)
	end
end