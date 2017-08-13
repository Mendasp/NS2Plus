local kBarPos
local kTextures =
{
    [kMarineTeamType] = PrecacheAsset("ui/progress_bar_marine.dds"),
    [kAlienTeamType] = PrecacheAsset("ui/progress_bar_alien.dds"),
}

function GUIProgressBar:ApplyCHUD()
	local mingui = CHUDGetOption("mingui")
	local texture = ConditionalValue(mingui, "ui/transparent.dds", kTextures[self.teamType])
	local inventoryMode = CHUDGetOption("inventory")

	self.progressBarBg:SetTexture(texture)
	if self.teamType == kMarineTeamType and (inventoryMode == 2 or inventoryMode == 4) then
		self.progressBarBg:SetPosition(kBarPos-GUIScale(Vector(0, 24, 0)))
	else
		self.progressBarBg:SetPosition(kBarPos)
	end

	self.lastMinGUI = mingui
end

local originalProgressBarInit = GUIProgressBar.Initialize
function GUIProgressBar:Initialize()
	originalProgressBarInit(self)
	kBarPos = self.progressBarBg:GetPosition()

	self:ApplyCHUD()
end
	
local originalProgressBarUpdate = GUIProgressBar.Update
function GUIProgressBar:Update(deltaTime)
	originalProgressBarUpdate(self, deltaTime)

	local mingui = CHUDGetOption("mingui")

	if mingui then
		if self.teamType == kAlienTeamType then
			self.smokeyBackground:SetColor(Color(0,0,0,0))
		elseif self.teamType == kMarineTeamType then
			self.circle:SetColor(Color(0,0,0,0))
		end
	end

	if self.lastMinGUI ~= mingui then
		self:ApplyCHUD()
	end

end