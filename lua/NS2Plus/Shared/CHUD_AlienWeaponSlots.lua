if Server then
	local playerOption = {}

	local function OnSetCHUDAlienWeaponSlot(client, message)
		local clientId = client:GetUserId()
		playerOption[clientId] = message.slotMode
	end
	Server.HookNetworkMessage("SetCHUDAlienWeaponSlot", OnSetCHUDAlienWeaponSlot)

	function GetAlienWeaponSelectMode(player)
		if not player then return 0 end

		local clientId = player:GetSteamId()
		return playerOption[clientId] or 0
	end
end

if Client then
	function GetAlienWeaponSelectMode()
		return CHUDGetOption("alien_weaponslots")
	end
end

function Metabolize:GetHUDSlot()
	local player = self:GetParent()
	if GetAlienWeaponSelectMode and GetAlienWeaponSelectMode(player) == 0 then
		return 0
	end

	return 2
end