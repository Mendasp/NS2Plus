local originalGUIPickupsUpdate
originalGUIPickupsUpdate = Class_ReplaceMethod( "GUIPickups", "Update",
	function(self, deltaTime)
		originalGUIPickupsUpdate(self, deltaTime)
		
		local localPlayer = Client.GetLocalPlayer()
		
		if localPlayer then
			for i, pickupGraphic in ipairs(self.allPickupGraphics) do
				if pickupGraphic:GetIsVisible() then
					local isVisible = CHUDGetOption("pickupexpire") > 0 and pickupGraphic.isWeapon or CHUDGetOption("pickupexpire") == 2
					pickupGraphic.expireBar:SetIsVisible(isVisible)
					pickupGraphic.expireBarBg:SetIsVisible(isVisible)
					
					if isVisible then
						local alpha = pickupGraphic.expireBar:GetColor().a
						local barColor = Color(0, 0.6117, 1, alpha)

						local timeLeft = -1
						
						if pickupGraphic.expireTime and pickupGraphic.expireTime ~= 0 then
							timeLeft = Clamp((pickupGraphic.expireTime - Shared.GetTime())/pickupGraphic.stayTime, 0, 1)
						end
						
						if timeLeft >= 0.5 and timeLeft < 0.75 then
							barColor = Color(1, 1, 0, alpha)
						elseif timeLeft >= 0.25 and timeLeft < 0.5 then
							barColor = Color(1, 0.5, 0, alpha)
						elseif timeLeft < 0.25 then
							barColor = Color(1, 0, 0, alpha)
						end
						
						pickupGraphic.expireBar:SetColor(barColor)
					end
				end
			end
		end
	end)