local originalChatUpdate
originalChatUpdate = Class_ReplaceMethod( "GUIChat", "Update",
function(self, deltaTime)
	local addChatMessages = ChatUI_GetMessages()
	local numberElementsPerMessage = 8
	local numberMessages = table.count(addChatMessages) / numberElementsPerMessage
	local currentIndex = 1
	
	while numberMessages > 0 do
	
		local playerColor = addChatMessages[currentIndex]
		local playerName = addChatMessages[currentIndex + 1]
		local messageColor = addChatMessages[currentIndex + 2]
		local messageText = addChatMessages[currentIndex + 3]
		local steamId = addChatMessages[currentIndex + 4]
		
		if steamId and (IsNumber(steamId) and steamId > 0 and not ChatUI_GetSteamIdTextMuted(steamId)) or steamId == "" then
			self:AddMessage(playerColor, playerName, messageColor, messageText)
		end
		currentIndex = currentIndex + numberElementsPerMessage
		numberMessages = numberMessages - 1
		
	end
	
	originalChatUpdate(self, deltaTime)
end)