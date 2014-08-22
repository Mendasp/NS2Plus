local kTextures =
{
    [kMarineTeamType] = PrecacheAsset("ui/progress_bar_marine.dds"),
    [kAlienTeamType] = PrecacheAsset("ui/progress_bar_alien.dds"),
}

Class_AddMethod( "GUIProgressBar", "ApplyCHUD",
	function(self)
		
		local mingui = CHUDGetOption("mingui")
		local texture = ConditionalValue(mingui, "ui/transparent.dds", kTextures[self.teamType])

		self.progressBarBg:SetTexture(texture)
		
		self.lastMinGUI = mingui
	end)

local originalProgressBarInit
originalProgressBarInit = Class_ReplaceMethod( "GUIProgressBar", "Initialize",
	function(self)
		originalProgressBarInit(self)

		self:ApplyCHUD()
	end)
	
local originalProgressBarUpdate
originalProgressBarUpdate = Class_ReplaceMethod( "GUIProgressBar", "Update",
	function(self, deltaTime)
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

	end)