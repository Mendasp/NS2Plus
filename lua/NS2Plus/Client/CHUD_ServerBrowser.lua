local function CheckShowTableEntry(self, entry)
	for _, filterFunc in pairs(self.filter) do
		if not filterFunc(entry) then
			return false
		end
	end
	return true
end

function FilterHiveWhiteList(active)
	return function(entry) return not active or entry.isHiveWhitelisted == true end
end

local oldServerTabsReset
oldServerTabsReset = Class_ReplaceMethod("ServerTabs", "Reset",
	function (self)
		oldServerTabsReset(self)
		-- Try reloading the whitelist
		if not CHUDHiveWhiteList then
			CHUDSaveHiveWhiteList()
		end
	end)

-- Disable hive filter for the other buttons
local oldEnableFilter
oldEnableFilter = Class_ReplaceMethod("ServerTabs", "EnableFilter",
	function(self, filters)
		oldEnableFilter(self, filters)
		if not filters[101] then
			self.serverList:SetFilter(101, FilterHiveWhiteList(false))
		end
	end)

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
		
		if serverEntry.CHUDBitmask ~= nil then
			serverEntry.originalMode = serverEntry.mode
			serverEntry.mode = serverEntry.mode:gsub("ns2", "ns2+", 1)
			if serverEntry.isNSL then
				serverEntry.mode = serverEntry.mode .. " NSL"
			end
		end
		if CHUDHiveWhiteList then
			serverEntry.isHiveWhitelisted = CHUDHiveWhiteList[serverEntry.address] or false
		end
	end
	
	-- Revert to the original mode if we're not in the server browser
	if serverEntry.originalMode and not serverBrowserOpen then
		serverEntry.mode = serverEntry.originalMode
	end
	
	return serverEntry
	
end

local kGold = Color(212/255, 175/255, 55/255)
local kNSLColor = ColorIntToColor(0x1aa7e2)
local originalSetServerData
originalSetServerData = Class_ReplaceMethod( "ServerEntry", "SetServerData",
	function(self, serverData)
		originalSetServerData(self, serverData)
		
		local blockedString
		if serverData.CHUDBitmask ~= nil then
			self.modName:SetColor(kYellow)
			
			for index, mask in pairs(CHUDTagBitmask) do
				if CheckCHUDTagOption(serverData.CHUDBitmask, mask) then
					if index == "mcr" then
						self.playerCount:SetColor(kRed)
					elseif serverData.isNSL then
						self.modName:SetColor(kNSLColor)
						self.serverName:SetColor(kNSLColor)
					elseif index ~= "nslserver" then
						local val = ConditionalValue(CHUDOptions[index].disabledValue == nil, CHUDOptions[index].defaultValue, CHUDOptions[index].disabledValue)
						
						if CHUDOptions[index].currentValue ~= val then
							self.modName:SetColor(kRed)
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
		
		self.modName.tooltipText = blockedString or serverData.ranked and self.modName.tooltipText
		self.mapName:SetColor(kWhite)
		self.mapName.tooltipText = nil
		if serverData.ranked then
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
			
			if GUIItemContainsPoint(self.playerSkill, Client.GetCursorPosScreen()) then
				self.playerSkill.tooltip:SetText(self.playerSkill.tooltipText)
				self.playerSkill.tooltip:Show()
			elseif self.modName.tooltipText and GUIItemContainsPoint(self.modName, Client.GetCursorPosScreen()) then
					self.playerSkill.tooltip:SetText(self.modName.tooltipText)
					self.playerSkill.tooltip:Show()
			elseif self.mapName.tooltipText and GUIItemContainsPoint(self.mapName, Client.GetCursorPosScreen()) then
				self.playerSkill.tooltip:SetText(self.mapName.tooltipText)
				self.playerSkill.tooltip:Show()
			else
				self.playerSkill.tooltip:Hide()
			end
		end)
		
		table.insertunique(self.mouseOutCallbacks, function(self)
			self.scriptHandle.highlightServer:SetIsVisible(false)
			self.favorite:SetColor(kFavoriteColor)
			self.playerSkill.tooltip:Hide()
		end)
	end)