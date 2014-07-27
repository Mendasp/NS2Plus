local kHitSoundVol = 0.0

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

function HitSounds_SyncOptions()
	kHitSoundVol = Client.GetOptionFloat( "hitsound-vol", 0.0 )
end

function HitSounds_PlayHitsound( i )
	if CHUDGetOption("hitsounds") > 0 then
		HitSounds_PlayCHUDHitsound( i )
	elseif kHitSounds[i] then
		StartSoundEffect( kHitSounds[i], kHitSoundVol )
	end
end

function HitSounds_PlayCHUDHitsound( i )
	local hitsound = i - 1
	if hitsounds[hitsound] then
		local soundEffectName = CHUDGetOptionAssocVal("hitsounds")
		
		soundEffectName = soundEffectName .. hitsounds[hitsound]
		if CHUDGetOption("hitsounds_pitch") == 1 and hitsound > 0 then
			soundEffectName = soundEffectName .. "-h"
		end
	
		StartSoundEffect(soundEffectName, kHitSoundVol)
	end
end