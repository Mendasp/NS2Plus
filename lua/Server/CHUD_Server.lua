Script.Load("lua/Shared/CHUD_Shared.lua")

// Clear tags on map restart
SetCHUDTagBitmask(0)

Script.Load("lua/Server/CHUD_ServerSettings.lua")
Script.Load("lua/Server/CHUD_ModUpdater.lua")
Script.Load("lua/Server/CHUD_HiveStats.lua")
Script.Load("lua/Server/CHUD_Respawn.lua")
Script.Load("lua/Server/CHUD_ServerStats.lua")
Script.Load("lua/Server/CHUD_ClientOptions.lua")

local skulkJumpSounds = {
	"sound/NS2.fev/alien/skulk/jump_good",
	"sound/NS2.fev/alien/skulk/jump_best",
	"sound/NS2.fev/alien/skulk/jump"
}

function StartSoundEffectOnEntity(soundEffectName, onEntity, volume, predictor)
	if table.contains(skulkJumpSounds, soundEffectName) then
		volume = volume * 0.5
	end
	local soundEffectEntity = Server.CreateEntity(SoundEffect.kMapName)
	soundEffectEntity:SetParent(onEntity)
	soundEffectEntity:SetAsset(soundEffectName)
	soundEffectEntity:SetVolume(volume)
	soundEffectEntity:SetPredictor(predictor)
	soundEffectEntity:Start()
	
	return soundEffectEntity
	
end

// Bugfix for skulk growl sounds
Class_ReplaceMethod("Player", "GetPlayIdleSound",
	function(self)
		return self:GetIsAlive() and (self:GetVelocityLength() / self:GetMaxSpeed(true)) > 0.65
	end)