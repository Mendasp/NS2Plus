Script.Load("lua/GUIInsight_OtherHealthbars.lua")

local isEnabled = Client.GetOptionBoolean("CHUD_SpectatorHPInsight", false)

local originalIOHBCreateOther
originalIOHBCreateOther = Class_ReplaceMethod("GUIInsight_OtherHealthbars", "CreateOtherGUIItem",
	function(self)
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
	end)

local kOtherHealthBarTextureSize = GetUpValue(GUIInsight_OtherHealthbars.Update, "kOtherHealthBarTextureSize", { LocateRecurse = true })
local originalIOHBUpdate
originalIOHBUpdate = Class_ReplaceMethod("GUIInsight_OtherHealthbars", "Update",
	function(self, deltaTime)
		originalIOHBUpdate(self, deltaTime)
		
		local otherList = GetUpValue(GUIInsight_OtherHealthbars.Update, "otherList", { LocateRecurse = true })
		for entId, other in pairs(otherList) do
			local entity = Shared.GetEntity(entId)
			if entity then
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
		local kAmmoColors = GetUpValue(GUIInsight_PlayerHealthbars.UpdatePlayers, "kAmmoColors", { LocateRecurse = true })
		local isVisible = GetUpValue(GUIInsight_OtherHealthbars.Update, "isVisible", { LocateRecurse = true })
		local kOtherHealthBarSize = GetUpValue(GUIInsight_OtherHealthbars.Update, "kOtherHealthBarSize", { LocateRecurse = true })
		for index, other in ientitylist(Shared.GetEntitiesWithClassname("Weapon")) do
			local otherIndex = other:GetId()
			local expireFraction = other.GetExpireTimeFraction and other:GetExpireTimeFraction() or 0
			local relevant = isVisible and expireFraction > 0
			if other:isa("Rifle") or other:isa("Welder") or other:isa("Pistol") or not other.weaponWorldState then
				relevant = false
			end
			
			if relevant then
			
				-- Get/Create Healthbar
				local otherGUI
				if not otherList[otherIndex] then -- Add new GUI for new units
				
					otherGUI = self:CreateOtherGUIItem()
					table.insert(otherList, otherIndex, otherGUI)
					
				else
				
					otherGUI = otherList[otherIndex]
					
				end
				
				otherList[otherIndex].Visited = true
				
				local backgroundSize = kOtherHealthBarSize.x/2
				local kHealthbarOffset = Vector(-backgroundSize/2, -kOtherHealthBarSize.y/2 - GUIScale(8), 0)
				
				-- Calculate Health Bar Screen position
				local min, max = other:GetModelExtents()
				local nameTagWorldPosition = other:GetOrigin() + Vector(0, max.y, 0)
				local nameTagInScreenspace = Client.WorldToScreen(nameTagWorldPosition) + kHealthbarOffset

				local color = kAmmoColors[other.kMapName] or kAmmoColors["rifle"]
				otherGUI.Background:SetIsVisible(true)

				-- background
				local background = otherGUI.Background
				background:SetPosition(nameTagInScreenspace)
				background:SetSize(Vector(backgroundSize,kOtherHealthBarSize.y/2, 0))
				
				-- healthbar
				local healthBar = otherGUI.HealthBar
				local healthBarSize = expireFraction * (backgroundSize - GUIScale(2))
				local healthBarTextureSize = expireFraction * kOtherHealthBarTextureSize.x
				healthBar:SetTexturePixelCoordinates(unpack({0, 0, healthBarTextureSize, kOtherHealthBarTextureSize.y}))
				healthBar:SetSize(Vector(healthBarSize, kOtherHealthBarSize.y/2, 0))
				healthBar:SetColor(color)
				
				-- health change bar
				local healthChangeBar = otherGUI.HealthChangeBar
				healthChangeBar:SetIsVisible(false)
			end
		end
	end)