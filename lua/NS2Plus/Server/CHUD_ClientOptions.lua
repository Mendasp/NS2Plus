local function SendDisabledSettings(client)
	if client and not client:GetIsVirtual() and #CHUDClientOptions > 0 then
		for _, option in ipairs(CHUDClientOptions) do
			local msg = { }
			msg.disabledOption = option
			Server.SendNetworkMessage(client, "CHUDOption", msg, true)
		end
	end
end

Event.Hook("ClientConnect", SendDisabledSettings)