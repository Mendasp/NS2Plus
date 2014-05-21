local kLineColor = Color(1, 1, 1, 0.5)

local kLineTexture = "ui/pg_line.dds"
local kLineTextureCoord = {0, 0, 32, 16}

Class_AddMethod("GUIMinimapConnection", "UpdateAnimation",
	function(self, teamNumber)
		local pglines = CHUDGetOption("pglines")
		
		local animatedArrows = teamNumber == kTeam1Index and #GetEntitiesForTeam("MapConnector", kTeam1Index) > 2

		local animation = ConditionalValue(animatedArrows and pglines > 1, (Shared.GetTime() % 1) / 1, 0)
					
		local x1Coord = kLineTextureCoord[1] - animation * (kLineTextureCoord[3] - kLineTextureCoord[1])
		local x2Coord = x1Coord + (self.length or 0)
		
		// Don't draw arrows for just 2 PGs, the direction is clear here
		// Gorge tunnels also don't need this since it is limited to entrance/exit
		local textureIndex = ConditionalValue(animatedArrows, CHUDGetOption("pglines") * 16, 0)
		
		self.line:SetTexturePixelCoordinates(x1Coord, textureIndex, x2Coord, textureIndex + 16)
		self.line:SetColor(ConditionalValue(teamNumber == kTeam1Index, kMarineFontColor, kAlienFontColor))
	end)
	
local originalMinimapConnectionSetup
originalMinimapConnectionSetup = Class_ReplaceMethod("GUIMinimapConnection", "Setup",
	function(self, startPoint, endPoint, parent)

		// Since we're using a texture now we need to move the points up a bit so it gets aligned properly
		startPoint = startPoint-(Vector(0,4,0))
		endPoint = endPoint-(Vector(0,4,0))
	
		originalMinimapConnectionSetup(self, startPoint, endPoint, parent)

	end)

local originalMinimapConnectionRender
originalMinimapConnectionRender = Class_ReplaceMethod("GUIMinimapConnection", "Render",
	function(self)
	
		if not self.line then
			self.line = GUI.CreateItem()
			self.line:SetTexture(kLineTexture)
			self.line:SetColor(kLineColor)
			self.line:SetAnchor(GUIItem.Center, GUIItem.Middle)
			self.line:SetStencilFunc(self.stencilFunc)
			
			if self.parent then
				self.parent:AddChild(self.line)
			end
		end
		
		originalMinimapConnectionRender(self)
		
		self.line:SetSize(Vector(self.length, GUIScale(10), 0))
	end)