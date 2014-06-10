local originalExoHUDUpdate
originalExoHUDUpdate = Class_ReplaceMethod( "GUIExoHUD", "Update",
	function(self, deltaTime)
		originalExoHUDUpdate(self, deltaTime)
		
		local fullMode = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
		local mingui = not CHUDGetOption("mingui")

		if fullMode then
			self.innerRing:SetIsVisible(mingui)
			self.outerRing:SetIsVisible(mingui)
			self.leftInfoBar:SetIsVisible(mingui)
			self.rightInfoBar:SetIsVisible(mingui)
			self.staticRing:SetIsVisible(mingui)
		end
	end)

Script.Load("lua/Weapons/Marine/ExoWeaponHolder.lua")
local originalExoWeaponHolder
originalExoWeaponHolder = Class_ReplaceMethod( "ExoWeaponHolder", "OnUpdateRender",
	function(self)
		originalExoWeaponHolder(self)
		local parent = self:GetParent()
		if parent and parent == Client.GetLocalPlayer() then
		
			local viewModel = parent:GetViewModelEntity()
			if viewModel and viewModel:GetRenderModel() then
				if CHUDGetOption("mingui") then
					viewModel:GetRenderModel():SetMaterialParameter("scanlinesMap", "ui/blank.dds")
				else
					viewModel:GetRenderModel():SetMaterialParameter("scanlinesMap", "ui/exosuit_scanlines.dds")
				end
			end
		end
	end
)