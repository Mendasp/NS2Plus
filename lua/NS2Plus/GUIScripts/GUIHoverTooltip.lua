local originalTooltipInit = GUIHoverTooltip.Initialize
function GUIHoverTooltip:Initialize()
	originalTooltipInit(self)

	self.image = GetGUIManager():CreateGraphicItem()
	self.image:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
	self.image:SetInheritsParentAlpha(true)
	self.background:AddChild(self.image)
end
	
local originalTooltipSetText = GUIHoverTooltip.SetText
function GUIHoverTooltip:SetText(string, texture, textureSize)
	originalTooltipSetText(self, string)

	local offset = GUIScale(10)

	if texture then
		textureSize = GUIScale(textureSize)

		self.image:SetTexture(texture)
		self.image:SetSize(textureSize)
		self.image:SetPosition(Vector(-textureSize.x/2, -offset-textureSize.y, 0))
		local width = math.max(self.background:GetSize().x, self.image:GetSize().x + offset*2)
		local height = self.background:GetSize().y + textureSize.y + GUIScale(5)

		self.background:SetSize(Vector(width, height, 0))
	else
		self.image:SetTexture(nil)
		self.image:SetSize(Vector(0,0,0))
	end

	self:UpdateBorders()
end