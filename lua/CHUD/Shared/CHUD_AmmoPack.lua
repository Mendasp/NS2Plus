function RifleAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)
    self:SetModel(RifleAmmo.kModelName)

end

function ShotgunAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)    
    self:SetModel(ShotgunAmmo.kModelName)

end

function FlamethrowerAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)    
    self:SetModel(FlamethrowerAmmo.kModelName)

end

function GrenadeLauncherAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)    
    self:SetModel(GrenadeLauncherAmmo.kModelName)

end