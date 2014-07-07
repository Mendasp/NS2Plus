local kIconsTextureName = "ui/drop_icons.dds"
local kExpireBarTextureName = "ui/healthbarplayer.dds"

Class_ReplaceMethod( "GUIPickups", "GetFreePickupGraphic",
	function(self)
	
		for i, pickupGraphic in ipairs(self.allPickupGraphics) do
		
			if pickupGraphic:GetIsVisible() == false then
				return pickupGraphic
			end
		
		end
	
		local newPickupGraphic = GUIManager:CreateGraphicItem()
		newPickupGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
		newPickupGraphic:SetTexture(kIconsTextureName)
		newPickupGraphic:SetIsVisible(false)
		
		local newPickupGraphicExpireBarBg = GUIManager:CreateGraphicItem()
		newPickupGraphicExpireBarBg:SetAnchor(GUIItem.Left, GUIItem.Top)
		newPickupGraphicExpireBarBg:SetTexture(kExpireBarTextureName)
		newPickupGraphicExpireBarBg:SetIsVisible(false)
		
		local newPickupGraphicExpireBar = GUIManager:CreateGraphicItem()
		newPickupGraphicExpireBar:SetAnchor(GUIItem.Left, GUIItem.Top)
		newPickupGraphicExpireBar:SetTexture(kExpireBarTextureName)
		newPickupGraphicExpireBar:SetIsVisible(false)
		
		newPickupGraphic.expireBarBg = newPickupGraphicExpireBarBg
		newPickupGraphic.expireBar = newPickupGraphicExpireBar
		
		table.insert(self.allPickupGraphics, newPickupGraphic)
		
		return newPickupGraphic
	end)
	
local originalGUIPickupsUninit
originalGUIPickupsUninit = Class_ReplaceMethod( "GUIPickups", "Uninitialize",
	function(self)
	
		for i, pickupGraphic in ipairs(self.allPickupGraphics) do
			GUI.DestroyItem(pickupGraphic.expireBarBg)
			GUI.DestroyItem(pickupGraphic.expireBar)
		end
		originalGUIPickupsUninit(self)
	
	end)
	
local GetPickupTextureCoordinates, GetNearbyPickups, kBounceSpeed, kMaxPickupSize, kPickupsVisibleRange,
	kIconWorldOffset, kBounceAmount, kMinPickupSize
local originalGUIPickupsUpdate
originalGUIPickupsUpdate = Class_ReplaceMethod( "GUIPickups", "Update",
	function(self, deltaTime)

		PROFILE("GUIPickups:Update")
		
		local localPlayer = Client.GetLocalPlayer()
		
		if localPlayer then
		
			for i, pickupGraphic in ipairs(self.allPickupGraphics) do
				pickupGraphic:SetIsVisible(false)
				pickupGraphic.expireBarBg:SetIsVisible(false)
				pickupGraphic.expireBar:SetIsVisible(false)
			end
			
			local nearbyPickups = GetNearbyPickups()
			for i, pickup in ipairs(nearbyPickups) do
				local timeLeft = -1
				
				local time = kItemStayTime
				
				// CompMod compatibility
				if pickup:isa("Weapon") and kWeaponStayTime then
					time = kWeaponStayTime
				end
				
				if pickup.expireTime and pickup.expireTime ~= 0 then
					timeLeft = Clamp(math.abs(pickup.expireTime - Shared.GetTime())/time, 0, 1)
				end
				
				// Check if the pickup is in front of the player.
				local playerForward = localPlayer:GetCoords().zAxis
				local playerToPickup = GetNormalizedVector(pickup:GetOrigin() - localPlayer:GetOrigin())
				local dotProduct = Math.DotProduct(playerForward, playerToPickup)
				
				if dotProduct > 0 then
				
					local pickupExpire = (CHUDGetOption("pickupexpire") > 0 and pickup:isa("Weapon")) or CHUDGetOption("pickupexpire") == 2
					local freePickupGraphic = self:GetFreePickupGraphic()
					freePickupGraphic:SetIsVisible(true)
					freePickupGraphic.expireBarBg:SetIsVisible(timeLeft > 0 and pickupExpire)
					freePickupGraphic.expireBar:SetIsVisible(timeLeft > 0 and pickupExpire)
								   
					local distance = pickup:GetDistanceSquared(localPlayer)
					distance = distance / (kPickupsVisibleRange * kPickupsVisibleRange)
					distance = 1 - distance
					
					local barColor = Color(0, 0.6117, 1, distance)
					
					if timeLeft >= 0.5 and timeLeft < 0.75 then
						barColor = Color(1, 1, 0, distance)
					elseif timeLeft >= 0.25 and timeLeft < 0.5 then
						barColor = Color(1, 0.5, 0, distance)
					elseif timeLeft < 0.25 then
						barColor = Color(1, 0, 0, distance)
					end
					
					freePickupGraphic:SetColor(Color(1, 1, 1, distance))
					freePickupGraphic.expireBarBg:SetColor(Color(0, 0, 0, distance*0.75))
					freePickupGraphic.expireBar:SetColor(barColor)
					
					local pickupSize = kMinPickupSize + ((kMaxPickupSize - kMinPickupSize) * distance)
					freePickupGraphic:SetSize(Vector(pickupSize, pickupSize, 0))
					freePickupGraphic.expireBarBg:SetSize(Vector(pickupSize, 6, 0))
					freePickupGraphic.expireBar:SetSize(Vector(pickupSize*timeLeft, 6, 0))
					freePickupGraphic.expireBar:SetTexturePixelCoordinates(0,0,100*timeLeft,7)
					
					local bounceAmount = math.sin(Shared.GetTime() * kBounceSpeed) * kBounceAmount
					local pickupWorldPosition = pickup:GetOrigin() + kIconWorldOffset + Vector(0, bounceAmount, 0)
					local pickupInScreenspace = Client.WorldToScreen(pickupWorldPosition)
					// Adjust for the size so it is in the middle.
					pickupInScreenspace = pickupInScreenspace + Vector(-pickupSize / 2, -pickupSize / 2, 0)
					freePickupGraphic:SetPosition(Vector(pickupInScreenspace.x, pickupInScreenspace.y-5*distance, 0))
					freePickupGraphic.expireBar:SetPosition(Vector(pickupInScreenspace.x, pickupInScreenspace.y+pickupSize, 0))
					freePickupGraphic.expireBarBg:SetPosition(Vector(pickupInScreenspace.x, pickupInScreenspace.y+pickupSize, 0))
					
					freePickupGraphic:SetTexturePixelCoordinates(GetPickupTextureCoordinates(pickup))
					
				end
			
			end
			
		end
    
	end)

CopyUpValues(GUIPickups.Update, originalGUIPickupsUpdate)