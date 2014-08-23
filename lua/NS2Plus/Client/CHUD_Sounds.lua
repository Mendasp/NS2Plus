Script.Load("lua/EffectManager.lua")
local blockedEffects = set {
							"complete_order",
							"upgrade_complete" }
originalTriggerEffects = Class_ReplaceMethod( "EffectManager", "TriggerEffects",
	function(self, effectName, tableParams, triggeringEntity)
		if not blockedEffects[effectName] then
			originalTriggerEffects(self, effectName, tableParams, triggeringEntity)
		elseif	(effectName == "complete_order" and CHUDGetOption("wps")) or
				(effectName == "upgrade_complete" and CHUDGetOption("unlocks")) then
			originalTriggerEffects(self, effectName, tableParams, triggeringEntity)
		end
	end
)

local blockedVO = set {
					"sound/NS2.fev/marine/voiceovers/commander/build",
					"sound/NS2.fev/marine/voiceovers/commander/defend",
					"sound/NS2.fev/marine/voiceovers/move" }
					
local reducedSounds = set {
					"sound/NS2.fev/alien/fade/blink",
					"sound/NS2.fev/alien/fade/blink_end" }
Script.Load("lua/SoundEffect.lua")
function StartSoundEffectOnEntity(soundEffectName, onEntity, volume, predictor)
	if not blockedVO[soundEffectName] or CHUDGetOption("wps") then
		if reducedSounds[soundEffectName] then
			volume = volume and volume * 0.8 or 0.8
		end
		Shared.PlaySound(onEntity, soundEffectName, volume or 1)
	end
end

function StartSoundEffect(soundEffectName, volume)
	if soundEffectName ~= "sound/NS2.fev/common/dead" or CHUDGetOption("ambient") then
		Shared.PlaySound(nil, soundEffectName, volume or 1)
	end
end

local kBlink2DSound = PrecacheAsset("sound/NS2.fev/alien/fade/blink_loop")
Class_ReplaceMethod("Fade", "UpdateBlink2DSound",
	function(self)
		local playSound = self:GetIsBlinking() and not GetHasSilenceUpgrade(self)

		if playSound and not self.blinkSoundPlaying then
		
			Shared.PlaySound(self, kBlink2DSound, 0.6)
			self.blinkSoundPlaying = true
			
		elseif not playSound and self.blinkSoundPlaying then
		
			Shared.StopSound(self, kBlink2DSound)
			self.blinkSoundPlaying = false
			
		end
	end)