local oldInventoryUpdate = GUIInventory.Update
function GUIInventory:Update(_, parameters)
	local inventoryMode = CHUDGetOption("inventory")

	if inventoryMode == 1 then
		self:SetIsVisible(false)
	else
		-- Ignore HUD mode and use our own option
		-- Start original update
		PROFILE("GUIInventory:Update")

		local activeWeaponTechId, inventoryTechIds = parameters[1], parameters[2]

		if #self.inventoryIcons > #inventoryTechIds then

			self.inventoryIcons[#self.inventoryIcons].Graphic:Destroy()
			table.remove(self.inventoryIcons, #self.inventoryIcons)

		end

		local resetAnimations = false
		if activeWeaponTechId ~= self.lastActiveWeaponTechId and gTechIdPosition and gTechIdPosition[activeWeaponTechId] then

			self.lastActiveWeaponTechId = activeWeaponTechId
			resetAnimations = true

		end

		if self.forceAnimationReset then
			resetAnimations = true
		end

		local numItems = #inventoryTechIds
		self.background:SetPosition(Vector(
			self.scale * -0.5 * (numItems*GUIInventory.kItemSize.x + (numItems-1)*GUIInventory.kItemPadding),
			GUIInventory.kBackgroundYOffset,
			0))

		local alienStyle = PlayerUI_GetTeamType() == kAlienTeamType

		for index, inventoryItem in ipairs(inventoryTechIds) do
			self:LocalAdjustSlot(index, inventoryItem.HUDSlot, inventoryItem.TechId, inventoryItem.TechId == activeWeaponTechId, resetAnimations, alienStyle)
		end
		-- End original update

		local player = Client.GetLocalPlayer()
		local isMarine = player and player:isa("Marine")

		self:SetForceAnimationReset(inventoryMode > 2)

		for _, icon in ipairs(self.inventoryIcons) do
			if not icon.AmmoDisplayLeft then
				local item = self.script:CreateAnimatedTextItem()
				icon.Graphic.guiItem:AddChild(item.guiItem)
				item:SetText("")
				item:SetFontName(Fonts.kAgencyFB_Smaller_Bordered)
				item:SetInheritsParentAlpha(true)
				item:SetScale(GetScaledVector())
				item:SetTextAlignmentX(GUIItem.Align_Max)
				item:SetPosition(Vector(GUIInventory.kItemSize.x/2.25, -GUIInventory.kItemSize.y/2, 0))
				icon.AmmoDisplayLeft = item

				icon.reserveFraction = -1
			end

			if not icon.AmmoDisplayCenter then
				local item = self.script:CreateAnimatedTextItem()
				icon.Graphic.guiItem:AddChild(item.guiItem)
				item:SetText("")
				item:SetFontName(Fonts.kAgencyFB_Smaller_Bordered)
				item:SetInheritsParentAlpha(true)
				item:SetScale(GetScaledVector())
				item:SetTextAlignmentX(GUIItem.Align_Center)
				item:SetPosition(Vector(GUIInventory.kItemSize.x/2, -GUIInventory.kItemSize.y/2, 0))
				icon.AmmoDisplayCenter = item
			end

			if not icon.AmmoDisplayRight then
				local item = self.script:CreateAnimatedTextItem()
				icon.Graphic.guiItem:AddChild(item.guiItem)
				item:SetText("")
				item:SetFontName(Fonts.kAgencyFB_Smaller_Bordered)
				item:SetInheritsParentAlpha(true)
				item:SetScale(GetScaledVector())
				item:SetTextAlignmentX(GUIItem.Align_Min)
				item:SetPosition(Vector(GUIInventory.kItemSize.x/1.75, -GUIInventory.kItemSize.y/2, 0))
				icon.AmmoDisplayRight = item
			end
		end

		if isMarine and (inventoryMode == 2 or inventoryMode == 4) then
			local activeWeaponTechId, inventoryTechIds = unpack(parameters)
			for index, inventoryItem in ipairs(inventoryTechIds) do
				local weapon = player:GetWeaponInHUDSlot(inventoryItem.HUDSlot)
				local text = ""
				if weapon and self.inventoryIcons[index] then
					local ammo = CHUDGetWeaponAmmoString(weapon)
					local reserveAmmo = CHUDGetWeaponReserveAmmoString(weapon)
					local fraction = CHUDGetWeaponAmmoFraction(weapon)
					local reserveFraction = CHUDGetWeaponReserveAmmoFraction(weapon)

					if self.inventoryIcons[index].reserveFraction ~= reserveFraction then
						self.inventoryIcons[index].reserveFraction = reserveFraction
						self.inventoryIcons[index].Graphic:Pause(2, "ANIM_INVENTORY_ITEM_PAUSE", AnimateLinear, function(script, item) item:FadeOut(0.5, "ANIM_INVENTORY_ITEM") end )
					end

					if reserveFraction ~= -1 then
						self.inventoryIcons[index].AmmoDisplayLeft:SetIsVisible(true)
						self.inventoryIcons[index].AmmoDisplayCenter:SetIsVisible(true)
						self.inventoryIcons[index].AmmoDisplayCenter:SetColor(kWhite)
						self.inventoryIcons[index].AmmoDisplayRight:SetIsVisible(true)

						if fraction > 0.4 then
							self.inventoryIcons[index].AmmoDisplayLeft:SetColor(kWhite)
						else
							self.inventoryIcons[index].AmmoDisplayLeft:SetColor(kRed)
						end

						if reserveFraction > 0.4 then
							self.inventoryIcons[index].AmmoDisplayRight:SetColor(kWhite)
						else
							self.inventoryIcons[index].AmmoDisplayRight:SetColor(kRed)
						end

						self.inventoryIcons[index].AmmoDisplayLeft:SetText(ammo)
						self.inventoryIcons[index].AmmoDisplayCenter:SetText("/")
						self.inventoryIcons[index].AmmoDisplayRight:SetText(reserveAmmo)
					else
						self.inventoryIcons[index].AmmoDisplayLeft:SetIsVisible(false)
						self.inventoryIcons[index].AmmoDisplayCenter:SetIsVisible(true)
						self.inventoryIcons[index].AmmoDisplayCenter:SetColor(kWhite)
						self.inventoryIcons[index].AmmoDisplayRight:SetIsVisible(false)

						self.inventoryIcons[index].AmmoDisplayCenter:SetText(ammo)
					end
				else
					self.inventoryIcons[index].AmmoDisplayLeft:SetIsVisible(false)
					self.inventoryIcons[index].AmmoDisplayCenter:SetIsVisible(false)
					self.inventoryIcons[index].AmmoDisplayRight:SetIsVisible(false)
				end
			end
		end
	end
end