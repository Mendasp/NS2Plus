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

local originalSetServerData
originalSetServerData = Class_ReplaceMethod( "ServerEntry", "SetServerData",
	function(self, serverData)
		originalSetServerData(self, serverData)
		
		if serverData.CHUDBitmask ~= nil then
		
			self.modName:SetColor(kYellow)
			
			local blockedString = nil
			for index, mask in pairs(CHUDTagBitmask) do
				if CheckCHUDTagOption(serverData.CHUDBitmask, mask) then
					if index == "mcr" then
						self.playerCount:SetColor(kRed)
					else
						local val = ConditionalValue(CHUDOptions[index].disabledValue == nil, CHUDOptions[index].defaultValue, CHUDOptions[index].disabledValue)
						
						if CHUDOptions[index].currentValue ~= val then
							self.modName:SetColor(kRed)
							if not blockedString then
								blockedString = "This server has disabled these NS2+ settings that you're currently using: " .. CHUDOptions[index].label
							else
								blockedString = blockedString .. ", " .. CHUDOptions[index].label
							end
							
						end
					end
				end
			end
			
			self.modName.tooltip = blockedString
			
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
			elseif GUIItemContainsPoint(self.modName.guiItem, Client.GetCursorPosScreen()) then
				if self.modName.tooltip then
					self.playerSkill.tooltip:SetText(self.modName.tooltip)
					self.playerSkill.tooltip:Show()
				end
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