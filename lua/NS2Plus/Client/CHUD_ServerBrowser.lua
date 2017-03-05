local oldBuildServerEntry = BuildServerEntry
function BuildServerEntry(serverIndex)

	local serverEntry = oldBuildServerEntry(serverIndex)

	local serverBrowserOpen = false
	local mainMenu = GetCHUDMainMenu()
	if mainMenu and mainMenu.playWindow and mainMenu.playWindow:GetIsVisible() then
		serverBrowserOpen = true
		local serverTags = { }
		Client.GetServerTags(serverIndex, serverTags)
		
		for t = 1, #serverTags do
			local _, pos = string.find(serverTags[t], "CHUD_0x")
			if pos then
				serverEntry.CHUDBitmask = tonumber(string.sub(serverTags[t], pos+1))
				if CheckCHUDTagOption(serverEntry.CHUDBitmask, CHUDTagBitmask["nslserver"]) and serverEntry.requiresPassword and string.find(serverEntry.name, "ENSL.org") == 1 then
					serverEntry.isNSL = true
				end
				break
			end
		end
	end
	
	return serverEntry
	
end

local kBlue = Color(0, 168/255 ,255/255)
local kGreen = Color(0, 208/255, 103/255)
local kYellow = kGreen --Color(1, 1, 0) --used for reserved full
local kGold = kBlue --Color(212/255, 175/255, 55/255) --used for ranked
local kRed = kBlue --Color(1, 0 ,0) --used for full
local kNSLColor = ColorIntToColor(0x1aa7e2)
local originalSetServerData
originalSetServerData = Class_ReplaceMethod( "ServerEntry", "SetServerData",
	function(self, serverData)
		originalSetServerData(self, serverData)
		
		local blockedString
		if serverData.CHUDBitmask ~= nil then
			local mode = serverData.mode:gsub("ns2", "ns2+", 1)
			if serverData.isNSL then
				mode = mode .. " NSL"
			end
			self.modName:SetText(mode)

			if serverData.ranked then
				self.modName:SetColor(kGold)
			end
			for index, mask in pairs(CHUDTagBitmask) do
				if CheckCHUDTagOption(serverData.CHUDBitmask, mask) then
					if index == "mcr" then
						self.playerCount:SetColor(kYellow)
					elseif serverData.isNSL then
						self.modName:SetColor(kNSLColor)
						self.serverName:SetColor(kNSLColor)
					elseif index ~= "nslserver" then
						local val = ConditionalValue(CHUDOptions[index].disabledValue == nil, CHUDOptions[index].defaultValue, CHUDOptions[index].disabledValue)
						
						if CHUDOptions[index].currentValue ~= val then
							self.modName:SetColor(kYellow)
							if not blockedString then
								blockedString = ConditionalValue(serverData.ranked, "Ranked server. ", "") .. "This server has disabled these NS2+ settings that you're currently using: " .. CHUDOptions[index].label
							else
								blockedString = blockedString .. ", " .. CHUDOptions[index].label
							end
							
						end
					end
				end
			end
		end
		
		self.modName.tooltipText = blockedString or serverData.ranked and Locale.ResolveString(string.format("SERVERBROWSER_RANKED_TOOLTIP"))
		self.mapName:SetColor(kWhite)
		self.mapName.tooltipText = nil
		if serverData.ranked and blockedString then
			self.mapName:SetColor(kGold)
			self.mapName.tooltipText = Locale.ResolveString(string.format("SERVERBROWSER_RANKED_TOOLTIP"))
		end
	end
)

local kFavoriteMouseOverColor = Color(1,1,0,1)
local kFavoriteColor = Color(1,1,1,0.9)

local originalServerEntryInit
originalServerEntryInit = Class_ReplaceMethod( "ServerEntry", "Initialize",
	function(self)
		originalServerEntryInit(self)
		
		self.mouseOverCallbacks = {}
		table.insertunique(self.mouseOverCallbacks, function(self)
		
			local height = self:GetHeight()
			local topOffSet = self:GetBackground():GetPosition().y + self:GetParent():GetBackground():GetPosition().y
			self.scriptHandle.highlightServer:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
			self.scriptHandle.highlightServer:SetIsVisible(true)
			
			if GUIItemContainsPoint(self.favorite, Client.GetCursorPosScreen()) then
				self.favorite:SetColor(kFavoriteMouseOverColor)
			else
				self.favorite:SetColor(kFavoriteColor)
			end
			
			if self.modName.tooltipText and GUIItemContainsPoint(self.modName, Client.GetCursorPosScreen()) then
				self.modName.tooltip:SetText(self.modName.tooltipText)
				self.modName.tooltip:Show()
			elseif self.mapName.tooltipText and GUIItemContainsPoint(self.mapName, Client.GetCursorPosScreen()) then
				self.modName.tooltip:SetText(self.mapName.tooltipText)
				self.modName.tooltip:Show()
			else
				self.modName.tooltip:Hide()
			end
		end)
		
		table.insertunique(self.mouseOutCallbacks, function(self)
			self.scriptHandle.highlightServer:SetIsVisible(false)
			self.favorite:SetColor(kFavoriteColor)
			self.modName.tooltip:Hide()
		end)
	end)