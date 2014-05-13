local kLineColor = Color(1, 1, 1, 0.5)

local kLineTexture = "ui/pg_line.dds"
local kLineTextureCoord = {0, 0, 32, 16}

Class_AddMethod("GUIMinimapConnection", "UpdateAnimation",
	function(self, teamNumber)
		local pglines = CHUDGetOption("pglines")
	
		local animation = (pglines > 1 and (Shared.GetTime() % 1) / 1) or 0
					
		local x1Coord = kLineTextureCoord[1] - animation * (kLineTextureCoord[3] - kLineTextureCoord[1])
		local x2Coord = x1Coord + (self.length or 0)
		
		local textureIndex = CHUDGetOption("pglines") * 16
		
		if teamNumber == kTeam1Index then
			self.line:SetTexturePixelCoordinates(x1Coord, textureIndex, x2Coord, textureIndex + 16)
		else
			self.line:SetTexturePixelCoordinates(x1Coord, kLineTextureCoord[2], x2Coord, kLineTextureCoord[4])
		end
		
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