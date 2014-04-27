local originalGUIRequestUpdate
originalGUIRequestUpdate = Class_ReplaceMethod( "GUIRequestMenu", "Update",
	function(self, deltaTime)
		originalGUIRequestUpdate(self, deltaTime)
			
		local mouseX, mouseY = Client.GetCursorPosScreen()
		
		if CHUDGetOption("mingui") then
			local highlightColor = Color(1,1,0,1)
			local defaultColor = Color(1,1,1,1)
			
			self.background:SetTexture("ui/blank.dds")
			
			if GUIItemContainsPoint(self.ejectCommButton.Background, mouseX, mouseY) then
				self.ejectCommButton.CommanderName:SetColor(highlightColor)
			else
				self.ejectCommButton.CommanderName:SetColor(defaultColor)
			end
			self.ejectCommButton.Background:SetTexture("ui/blank.dds")
			
			if GUIItemContainsPoint(self.voteConcedeButton.Background, mouseX, mouseY) then
				self.voteConcedeButton.ConcedeText:SetColor(highlightColor)
			else
				self.voteConcedeButton.ConcedeText:SetColor(defaultColor)
			end
			self.voteConcedeButton.Background:SetTexture("ui/blank.dds")
				
			for _, button in pairs(self.menuButtons) do		
				if GUIItemContainsPoint(button.Background, mouseX, mouseY) then
					button.Description:SetColor(highlightColor)
				else
					button.Description:SetColor(defaultColor)
				end
				button.Background:SetTexture("ui/blank.dds")
			end
		end
		
	end)