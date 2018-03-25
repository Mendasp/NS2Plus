local originalIOHBCreateOther = GUIInsight_OtherHealthbars.CreateOtherGUIItem
function GUIInsight_OtherHealthbars:CreateOtherGUIItem()
	local otherUI = originalIOHBCreateOther(self)

	if not otherUI.Location then
		local locationItem = GUIManager:CreateTextItem()
		locationItem:SetFontName(Fonts.kInsight)
		locationItem:SetScale(GUIScale(Vector(1,1,1)) * 0.8)
		locationItem:SetTextAlignmentX(GUIItem.Align_Center)
		locationItem:SetTextAlignmentY(GUIItem.Align_Max)
		otherUI.Background:AddChild(locationItem)

		otherUI.Location = locationItem
	end

	return otherUI
end

local kOtherHealthBarTextureSize = Vector(64, 6, 0)
local originalIOHBUpdate = GUIInsight_OtherHealthbars.Update
function GUIInsight_OtherHealthbars:Update(deltaTime)
	originalIOHBUpdate(self, deltaTime)

	local kAmmoColors = GUIInsight_PlayerHealthbars.kAmmoColors or {}

	for _, entId in ipairs(self.otherIds) do
		local other = self.otherList[entId]
		local entity = Shared.GetEntity(entId)
		if entity and other then
			if entity:isa("PhaseGate") or entity:isa("TunnelEntrance") or entity:isa("TunnelExit") then
				other.Location:SetIsVisible(true)
				other.Location:SetText(entity.GetDestinationLocationName and entity:GetDestinationLocationName() or "")
				other.Location:SetColor(Color(kNameTagFontColors[entity:GetTeamType()]))
				other.Location:SetPosition(Vector(other.Background:GetSize().x/2, 0, 0))
			else
				other.Location:SetIsVisible(false)
			end
		end
	end

	-- Weapon expire times
	for index, other in ientitylist(Shared.GetEntitiesWithClassname("Weapon")) do
		local otherIndex = other:GetId()
		local expireFraction = other.GetExpireTimeFraction and other:GetExpireTimeFraction() or 0
		local relevant = self.isVisible and expireFraction > 0
		if other:isa("Rifle") or other:isa("Welder") or other:isa("Pistol") or not other.weaponWorldState then
			relevant = false
		end

		if relevant then

			-- Get/Create Healthbar
			local otherGUI
			if not self.otherList[otherIndex] then -- Add new GUI for new units

				otherGUI = self:CreateOtherGUIItem()
				table.insert(self.otherIds, otherIndex)
				table.insert(self.otherList, otherIndex, otherGUI)

			else

				otherGUI = self.otherList[otherIndex]

			end

			self.otherList[otherIndex].Visited = true

			local backgroundSize = self.kOtherHealthBarSize.x/2
			local kHealthbarOffset = Vector(-backgroundSize/2, -self.kOtherHealthBarSize.y/2 - GUIScale(8), 0)

			-- Calculate Health Bar Screen position
			local min, max = other:GetModelExtents()
			local nameTagWorldPosition = other:GetOrigin() + Vector(0, max.y, 0)
			local nameTagInScreenspace = Client.WorldToScreen(nameTagWorldPosition) + kHealthbarOffset

			local color = kAmmoColors[other.kMapName] or kAmmoColors["rifle"]
			otherGUI.Background:SetIsVisible(true)

			-- background
			local background = otherGUI.Background
			background:SetPosition(nameTagInScreenspace)
			background:SetSize(Vector(backgroundSize,self.kOtherHealthBarSize.y/2, 0))

			-- healthbar
			local healthBar = otherGUI.HealthBar
			local healthBarSize = expireFraction * (backgroundSize - GUIScale(2))
			local healthBarTextureSize = expireFraction * kOtherHealthBarTextureSize.x
			healthBar:SetTexturePixelCoordinates(0, 0, healthBarTextureSize, kOtherHealthBarTextureSize.y)
			healthBar:SetSize(Vector(healthBarSize, self.kOtherHealthBarSize.y/2, 0))
			healthBar:SetColor(color)

			-- health change bar
			local healthChangeBar = otherGUI.HealthChangeBar
			healthChangeBar:SetIsVisible(false)
		end
	end
end