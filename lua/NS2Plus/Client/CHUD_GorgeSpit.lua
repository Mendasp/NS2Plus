-- turtsmcgurts
-- the reasoning behind this option is to make it easier for gorges to see their 'spit' with alien vision and adjust their aim properly.
-- https://i.imgur.com/S9rqKxm.png
-- https://youtu.be/397QWoxpFWI

-- kProjectileCinematic is for .cinematic files (which do not get affected by alien vision, making their effects difficult to see especially with darker AV)
-- kModelName is for .model files (which DO get affected by alien vision)
-- must alternate using these for the different files.

--Script.Load("lua/Weapons/PredictedProjectile.lua")
local oldCreatePredictedProjectile = PredictedProjectileShooterMixin.CreatePredictedProjectile
function PredictedProjectileShooterMixin:CreatePredictedProjectile(className, startPoint, velocity, bounce, friction, gravity)
	if (className == "Spit") then
		if not CHUDGetOption("gorgespit") then
			_G[className].kProjectileCinematic = PrecacheAsset("cinematics/alien/gorge/dripping_slime.cinematic")
			_G[className].kModelName = nil
		else
			_G[className].kProjectileCinematic = nil
			_G[className].kModelName = PrecacheAsset("models/marine/rifle/rifle_grenade.model")
		end
	end
	
	oldCreatePredictedProjectile(self, className, startPoint, velocity, bounce, friction, gravity)
end