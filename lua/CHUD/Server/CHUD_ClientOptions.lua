local function SendDisabledSettings(client)
	if client and not client:GetIsVirtual() and #CHUDClientOptions > 0 then
		for _, option in pairs(CHUDClientOptions) do
			local msg = { }
			msg.disabledOption = option
			Server.SendNetworkMessage(client, "CHUDOption", msg, true)
		end
	end
end

Event.Hook("ClientConnect", SendDisabledSettings)