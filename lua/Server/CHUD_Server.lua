Script.Load("lua/Shared/CHUD_Shared.lua")

// Clear tags on map restart
SetCHUDTagBitmask(0)

Script.Load("lua/Server/CHUD_ServerSettings.lua")
Script.Load("lua/Server/CHUD_ModUpdater.lua")
Script.Load("lua/Server/CHUD_HiveStats.lua")
Script.Load("lua/Server/CHUD_Respawn.lua")
Script.Load("lua/Server/CHUD_ServerStats.lua")
Script.Load("lua/Server/CHUD_ClientOptions.lua")
Script.Load("lua/Server/CHUD_MarineTeam.lua")
Script.Load("lua/Server/CHUD_PlayerInfo.lua")
Script.Load("lua/Server/CHUD_PowerPoint.lua")
Script.Load("lua/Server/CHUD_PickupExpire.lua")
Script.Load("lua/Server/CHUD_DropPack.lua")

local oldBadgesActive = false
// Warning about outdated mod
for modNum = 1, Server.GetNumActiveMods() do
	if Server.GetActiveModId(modNum) == "5f42a0c" then
		oldBadgesActive = true
		Shared.Message("[NS2+] Player Badges mod detected. This mod is OUTDATED and will make players lose their customization entry in the main menu. Please use the more up to date Badges+ mod in the Steam Workshop.")
	end
end

local function SendModsWarning(client)
	if client and not client:GetIsVirtual() and oldBadgesActive then
		local message = "Player Badges mod detected. This mod is OUTDATED and blocks the customization menu. Use Badges+ instead."
		Server.SendNetworkMessage(client, "Chat", BuildChatMessage(false, "NS2+", -1, kTeamReadyRoom, kNeutralTeamType, message), true)
	end
end

Event.Hook("ClientConnect", SendModsWarning)