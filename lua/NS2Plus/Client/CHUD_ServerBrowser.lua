local oldBuildServerEntry = BuildServerEntry
function BuildServerEntry(serverIndex)

	local serverEntry = oldBuildServerEntry(serverIndex)

	local serverTags = { }
	Client.GetServerTags(serverIndex, serverTags)
	
	for t = 1, #serverTags do
		local _, pos = string.find(serverTags[t], "CHUD_0x")
		if pos then
			serverEntry.CHUDBitmask = tonumber(string.sub(serverTags[t], pos+1))
			break
		end
	end
	
	if serverEntry.CHUDBitmask ~= nil and serverEntry.mode == "ns2" then
		serverEntry.mode = "ns2+"
	end
    
    return serverEntry
    
end

originalSetServerData = Class_ReplaceMethod( "ServerEntry", "SetServerData",
	function(self, serverData)
		originalSetServerData(self, serverData)
		
		if serverData.CHUDBitmask ~= nil then
		
			self.modName:SetColor(kYellow)
			
			for index, mask in pairs(CHUDTagBitmask) do
				if CheckCHUDTagOption(serverData.CHUDBitmask, mask) then
					if index == "mcr" then
						self.playerCount:SetColor(kRed)
					else
						local val = ConditionalValue(CHUDOptions[index].disabledValue == nil, CHUDOptions[index].defaultValue, CHUDOptions[index].disabledValue)
						
						if CHUDOptions[index].currentValue ~= val then
							self.modName:SetColor(kRed)
						end
					end
				end
			end
			
		end
		
	end
)
