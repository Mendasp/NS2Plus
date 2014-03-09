originalSetServerData = Class_ReplaceMethod( "ServerEntry", "SetServerData",
	function(self, serverData)
		originalSetServerData(self, serverData)
		if self.serverData ~= serverData and serverData.serverId >= 0 then
			local serverTags = { }
			Client.GetServerTags(serverData.serverId, serverTags)
			for k,v in pairs(serverTags) do
				if v == "CHUD" then
					self.modName:SetColor(kYellow)
					self.modName:SetText("CHUD")
					serverData.mode = "CHUD"
				end
			end
			self:SetId(serverData.serverId)
			self.serverData = { }
			for name, value in pairs(serverData) do
				self.serverData[name] = value
			end
		end
	end
)
