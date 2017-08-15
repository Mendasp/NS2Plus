local originalWPUpdate = GUIWaypoints.Update
function GUIWaypoints:Update(deltaTime)
	originalWPUpdate(self, deltaTime)
	local finalWaypointData = PlayerUI_GetFinalWaypointInScreenspace()
	local showWayPoint = not PlayerUI_GetIsConstructing() and not PlayerUI_GetIsRepairing() and (CHUDGetOption("wps") or Client.GetLocalPlayer():isa("Commander"))
	local fullHUD = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
	self.animatedCircle:SetIsVisible(showWayPoint and fullHUD and not CHUDGetOption("minwps"))
	self.finalWaypoint:SetIsVisible(showWayPoint)
	self.finalDistanceText:SetIsVisible(fullHUD and not CHUDGetOption("minwps"))
	self.finalNameText:SetIsVisible(fullHUD and not CHUDGetOption("minwps"))
	if CHUDGetOption("minwps") then
		self.finalWaypoint:SetTexture(kTransparentTexture)
	else
		self.finalWaypoint:SetTexture(self.usedTexture)
	end

	-- If we have disabled waypoints, we still want to see Attack waypoints
	if finalWaypointData and not CHUDGetOption("wps") then
		self.finalWaypoint:SetIsVisible(finalWaypointData.type == kTechId.Attack)
	end

	-- Disabled auto waypoints only
	if finalWaypointData and not CHUDGetOption("autowps") and CHUDGetOption("wps") then
		if finalWaypointData.type == kTechId.AutoConstruct or finalWaypointData.type == kTechId.AutoWeld then
			self.finalWaypoint:SetIsVisible(false)
		end
	end

	-- Hide the arrows in any of the modes
	for a = 1, #self.worldArrows do
		self.worldArrows[a].model:SetIsVisible(not (CHUDGetOption("minwps") or not CHUDGetOption("wps")))
		self.worldArrows[a].light:SetIsVisible(not (CHUDGetOption("minwps") or not CHUDGetOption("wps")))
	end

	if not finalWaypointData then
		self.finalWaypoint:SetColor(Color(1, 1, 1, 0))
		self.finalDistanceText:SetIsVisible(false)
		self.finalNameText:SetIsVisible(false)
		self.waypointDirection:SetIsVisible(false)
	end

end