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
local kOtherTypes = GetUpValue(GUIInsight_OtherHealthbars.Update, "kOtherTypes", { LocateRecurse = true })
table.insert(kOtherTypes, "Weapon")
local originalIOHBUpdate
originalIOHBUpdate = Class_ReplaceMethod("GUIInsight_OtherHealthbars", "Update",
	function(self, deltaTime)
		originalIOHBUpdate(self, deltaTime)
		
		local otherList = GetUpValue(GUIInsight_OtherHealthbars.Update, "otherList", { LocateRecurse = true })
		local kAmmoColors = GetUpValue(GUIInsight_PlayerHealthbars.UpdatePlayers, "kAmmoColors", { LocateRecurse = true })
		for entId, other in pairs(otherList) do
			local entity = Shared.GetEntity(entId)
			if entity then
				if entity:isa("PhaseGate") or entity:isa("TunnelEntrance") or entity:isa("TunnelExit") then
					other.Location:SetIsVisible(true)
					other.Location:SetText(entity.GetDestinationLocationName and entity:GetDestinationLocationName() or "")
					other.Location:SetColor(Color(kNameTagFontColors[entity:GetTeamType()]))
					other.Location:SetPosition(Vector(other.Background:GetSize().x/2, 0, 0))
				elseif entity:isa("Weapon") then
					local expireFraction = entity.GetExpireTimeFraction and entity:GetExpireTimeFraction() or 0
					if expireFraction > 0 and not entity:isa("Rifle") and not entity:isa("Welder") then
						local backgroundSize = other.Background:GetSize()/2
						other.Background:SetIsVisible(true)
						other.Background:SetSize(backgroundSize)
						other.Background:SetPosition(other.Background:GetPosition() + other.Background:GetSize()/2)
						other.HealthBar:SetColor(kAmmoColors[entity.kMapName] or kAmmoColors["rifle"])
						other.HealthBar:SetSize(Vector(expireFraction * (backgroundSize.x - GUIScale(2)), backgroundSize.y, 0))
					else
						other.Background:SetIsVisible(false)
					end
				else
					other.Location:SetIsVisible(false)
				end
			end
		end
	end)