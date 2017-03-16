local originalUpdate
originalUpdate = Class_ReplaceMethod( "GUIBioMassDisplay", "Update",
	function(self, deltaTime)
		originalUpdate(self, deltaTime)
		
		local mingui = not CHUDGetOption("mingui")
		
		local player = Client.GetLocalPlayer()
		local teamNum = player and player:GetTeamNumber() or 0
		local teamInfo = GetTeamInfoEntity(teamNum)
		local bioMassAlert = (teamInfo and teamInfo.GetBioMassAlertLevel) and teamInfo:GetBioMassAlertLevel() or 0
		local showGUI = 
			player 
				and player:isa("Commander") 
				or ( bioMassAlert > 0 and player:isa("Commander") )
				or player:GetIsMinimapVisible() 
				or player:GetBuyMenuIsDisplaying() 
				or PlayerUI_GetIsTechMapVisible()
		
		self.smokeyBackground:SetIsVisible(showGUI and mingui)
	end)