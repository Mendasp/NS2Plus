--[[
-- Let drifters build tunnel's when off infestation
local oldSharedUpdate = GetUpValue( ConstructMixin.OnUpdate, "SharedUpdate" )
local kDrifterBuildRate = 1
local function ConstructMixin_NewSharedUpdate( self, deltaTime )
	if Server then
        if not self:GetIsBuilt() and GetIsAlienUnit(self) then
            if self.GetCanAutoBuild and not self:GetCanAutoBuild() then
				if self.hasDrifterEnzyme and not self:isa("Cyst") then
					local multiplier = kDrifterBuildRate - kAutoBuildRate
					self:Construct(deltaTime * multiplier)
				end
			end
		end
	end
	
	oldSharedUpdate( self, deltaTime )
end

ReplaceUpValue( ConstructMixin.OnUpdate, "SharedUpdate", ConstructMixin_NewSharedUpdate )
]]--

-- Prevent commanders giving a drifter a construct order on a structure that can't be constructed
local oldIsBeingGrown = GetUpValue( Drifter.OnOverrideOrder, "IsBeingGrown" )
local function NewIsBeingGrown(self, target )
	if target.GetCanAutoBuild and not target:GetCanAutoBuild() then
		-- returning true prevents the drifter from trying to build this structure
		-- return self:isa("Cyst")
		return true
	else
		return oldIsBeingGrown( self, target )
	end
end
ReplaceUpValue( Drifter.OnOverrideOrder, "IsBeingGrown", NewIsBeingGrown )
