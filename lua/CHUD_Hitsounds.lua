local hitsounds = {}
hitsounds[0] = ""
hitsounds[1] = "-mid"
hitsounds[2] = "-hi"

for _, sound in pairs(CHUDGetOptionVals("hitsounds")) do
	Client.PrecacheLocalSound(sound)
	Client.PrecacheLocalSound(sound .. "-mid")
	Client.PrecacheLocalSound(sound .. "-hi")
	Client.PrecacheLocalSound(sound .. "-mid-h")
	Client.PrecacheLocalSound(sound .. "-hi-h")
end

function PlayHitsound(hitsound)
	
	if hitsounds[hitsound] then
		local soundEffectName = CHUDGetOptionAssocVal("hitsounds")
		
		soundEffectName = soundEffectName .. hitsounds[hitsound]
		if CHUDGetOption("hitsounds_pitch") == 1 then
			soundEffectName = soundEffectName .. "-h"
		end
	
		StartSoundEffect(soundEffectName, CHUDGetOption("hitsounds_vol"))
	end
	
end