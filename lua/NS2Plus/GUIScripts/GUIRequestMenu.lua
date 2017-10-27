local originalGUIRequestUpdate = GUIRequestMenu.Update
function GUIRequestMenu:Update(deltaTime)
	originalGUIRequestUpdate(self, deltaTime)

	if self.background:GetIsVisible() and CHUDGetOption("mingui") then
		local highlightColor = Color(1,1,0,1)
		local defaultColor = Color(1,1,1,1)

		self.background:SetTexture("ui/transparent.dds")

		if self.selectedButton == self.ejectCommButton then
			self.ejectCommButton.CommanderName:SetColor(highlightColor)
		else
			self.ejectCommButton.CommanderName:SetColor(defaultColor)
		end
		self.ejectCommButton.Background:SetTexture("ui/transparent.dds")

		if self.selectedButton == self.voteConcedeButton then
			self.voteConcedeButton.ConcedeText:SetColor(highlightColor)
		else
			self.voteConcedeButton.ConcedeText:SetColor(defaultColor)
		end
		self.voteConcedeButton.Background:SetTexture("ui/transparent.dds")

		for _, button in ipairs(self.menuButtons) do
			if self.selectedButton == button then
				button.Description:SetColor(highlightColor)
			else
				button.Description:SetColor(defaultColor)
			end
			button.Background:SetTexture("ui/transparent.dds")
		end
	end

end
