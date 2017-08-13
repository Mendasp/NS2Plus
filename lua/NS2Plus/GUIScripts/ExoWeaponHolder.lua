local originalExoWeaponHolder = ExoWeaponHolder.OnUpdateRender
function ExoWeaponHolder:OnUpdateRender()
	originalExoWeaponHolder(self)

	local parent = self:GetParent()
	if parent and parent == Client.GetLocalPlayer() then

		local viewModel = parent:GetViewModelEntity()
		if viewModel and viewModel:GetRenderModel() then
			if CHUDGetOption("mingui") then
				viewModel:GetRenderModel():SetMaterialParameter("scanlinesMap", "ui/transparent.dds")
			else
				viewModel:GetRenderModel():SetMaterialParameter("scanlinesMap", "ui/exosuit_scanlines.dds")
			end
		end
	end
end