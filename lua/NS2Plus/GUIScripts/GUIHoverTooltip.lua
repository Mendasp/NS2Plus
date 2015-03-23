local kBorderWidth = 2
local kBackgroundColor = Color(0, 0, 0, 0.9)
local kDefaultBorderColor = ColorIntToColor(kMarineTeamColor)
local chud_tooltip = PrecacheAsset("ui/chud_tooltip.dds")
local originalTooltipInit
originalTooltipInit = Class_ReplaceMethod("GUIHoverTooltip", "Initialize",
	function(self)
		originalTooltipInit(self)
		
		self.tooltip:SetAnchor(GUIItem.Left, GUIItem.Top)
		
		self.background:SetTexture(nil)
		self.background:SetColor(kBackgroundColor)
		
		self.image = GetGUIManager():CreateGraphicItem()
		self.image:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
		self.image:SetInheritsParentAlpha(true)
		self.background:AddChild(self.image)
		
		self.borderTop = GetGUIManager():CreateGraphicItem()
		self.borderTop:SetAnchor(GUIItem.Left, GUIItem.Top)
		self.borderTop:SetColor(kDefaultBorderColor)
		self.borderTop:SetInheritsParentAlpha(true)
		
		self.borderBottom = GetGUIManager():CreateGraphicItem()
		self.borderBottom:SetAnchor(GUIItem.Left, GUIItem.Bottom)
		self.borderBottom:SetColor(kDefaultBorderColor)
		self.borderBottom:SetInheritsParentAlpha(true)
		
		self.borderLeft = GetGUIManager():CreateGraphicItem()
		self.borderLeft:SetAnchor(GUIItem.Left, GUIItem.Top)
		self.borderLeft:SetColor(kDefaultBorderColor)
		self.borderLeft:SetInheritsParentAlpha(true)
		
		self.borderRight = GetGUIManager():CreateGraphicItem()
		self.borderRight:SetAnchor(GUIItem.Right, GUIItem.Top)
		self.borderRight:SetColor(kDefaultBorderColor)
		self.borderRight:SetInheritsParentAlpha(true)
		
		self.background:AddChild(self.borderTop)
		self.background:AddChild(self.borderBottom)
		self.background:AddChild(self.borderLeft)
		self.background:AddChild(self.borderRight)
	end)
	
local originalTooltipShow
originalTooltipShow = Class_ReplaceMethod("GUIHoverTooltip", "Show",
	function(self, displayTime)
		originalTooltipShow(self, displayTime)
		
		self.background:SetColor(kBackgroundColor, 0.25, "TOOLTIP_SHOW")
	end)
	
local originalTooltipUpdate
originalTooltipUpdate = Class_ReplaceMethod("GUIHoverTooltip", "Update",
	function(self, deltaTime)
		originalTooltipUpdate(self, deltaTime)
		
		local mouseX, mouseY = Client.GetCursorPosScreen()
		local xPos, yPos
		if mouseX > Client.GetScreenWidth() - self.background:GetSize().x then
			xPos = mouseX - self.background:GetSize().x - 10
		else
			xPos = mouseX + 20
		end
		
		if mouseY > Client.GetScreenHeight() - self.background:GetSize().y then
			yPos = mouseY - self.background:GetSize().y - 5
		else
			yPos = mouseY
		end
		
		self.background:SetPosition(Vector(xPos, yPos, 0))
	end)
local function UpdateBorders(self)
	local borderSize = Vector(self.background:GetSize())
	borderSize.x = borderSize.x + 2 * kBorderWidth
	borderSize.y = borderSize.y
	
	self.borderTop:SetPosition(Vector(-kBorderWidth, -kBorderWidth, 0))
	self.borderTop:SetSize(Vector(borderSize.x, kBorderWidth, 0))
	
	self.borderBottom:SetPosition(Vector(-kBorderWidth, 0, 0))
	self.borderBottom:SetSize(Vector(borderSize.x, kBorderWidth, 0))

	self.borderLeft:SetPosition(Vector(-kBorderWidth, 0, 0))
	self.borderLeft:SetSize(Vector(kBorderWidth, borderSize.y, 0))

	self.borderRight:SetPosition(Vector(0, 0, 0))
	self.borderRight:SetSize(Vector(kBorderWidth, borderSize.y, 0))
end

local offset = 15
local originalTooltipSetText
originalTooltipSetText = Class_ReplaceMethod("GUIHoverTooltip", "SetText",
	function(self, string, texture, textureSize)
		originalTooltipSetText(self, string)
		
		self.tooltip:SetPosition(Vector(offset, offset, 0))
		self.tooltip:SetTextAlignmentY(GUIItem.Align_Min)
		
		if texture then
			self.image:SetTexture(texture)
			self.image:SetSize(textureSize)
			self.image:SetPosition(Vector(-textureSize.x/2, -offset-textureSize.y, 0))
			local width = math.max(self.background:GetSize().x, self.image:GetSize().x + offset*2)
			local height = self.background:GetSize().y + textureSize.y + 5
			
			self.background:SetSize(Vector(width, height, 0))
		else
			self.image:SetTexture(nil)
			self.image:SetSize(Vector(0,0,0))
		end
		
		UpdateBorders(self)
	end)