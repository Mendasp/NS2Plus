cLastHitTime = nil
cNumHits = 0

for _, sound in pairs(CHUDGetOptionVals("hitsounds")) do
	Client.PrecacheLocalSound(sound)
	Client.PrecacheLocalSound(sound .. "-mid")
	Client.PrecacheLocalSound(sound .. "-hi")
	Client.PrecacheLocalSound(sound .. "-mid-h")
	Client.PrecacheLocalSound(sound .. "-hi-h")
end

function PlayHitsounds()

	if cLastHitTime and Shared.GetTime() - cLastHitTime > 0.005 and cNumHits > 0 then
		if CHUDGetOption("hitsounds") > 0 and not Client.GetLocalPlayer():isa("Commander") then
			local soundEffectName = CHUDGetOptionAssocVal("hitsounds")
			
			if cNumHits >= 6 and cNumHits <= 13 then
				soundEffectName = soundEffectName .. "-mid"
				if CHUDGetOption("hitsounds_pitch") == 1 then
					soundEffectName = soundEffectName .. "-h"
				end
			elseif cNumHits > 13 then
				soundEffectName = soundEffectName .. "-hi"
				if CHUDGetOption("hitsounds_pitch") == 1 then
					soundEffectName = soundEffectName .. "-h"
				end
			end
		
			StartSoundEffect(soundEffectName, CHUDGetOption("hitsounds_vol"))
		end
		
		cNumHits = 0
		cLastHitTime = Shared.GetTime()
	end
	
end

Event.Hook("UpdateRender", PlayHitsounds)