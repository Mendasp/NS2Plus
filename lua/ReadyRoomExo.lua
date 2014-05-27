Script.Load( "lua/Exo.lua" )

class 'ReadyRoomExo' (Exo)

ReadyRoomExo.kMapName = "ready_room_exo"

local networkVars = {}


function ReadyRoomExo:OnCreate()
	Exo.OnCreate( self )
    self.creationTime = 0
end


function ReadyRoomExo:OnGetMapBlipInfo()	
	--return success, blipType, blipTeam, isAttacked, isParasited
	return false
end

	
function ReadyRoomExo:PerformEject()
	if Server and self:GetIsAlive() then
        
 		self:TriggerEffects("death", { classname = self:GetClassName(), effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
		
		local marine = self:Replace(self.prevPlayerMapName or Marine.kMapName, nil, nil, self:GetOrigin() + Vector(0, 0.2, 0) )					
		marine.onGround = false
		local initialVelocity = self:GetViewCoords().zAxis
		initialVelocity:Scale(4)
		initialVelocity.y = 9
		marine:SetVelocity(initialVelocity)
		
		if marine:isa("JetpackMarine") then
			marine:SetFuel(0)
		end
        
	end
end


function ReadyRoomExo:HandleButtons( input )
	if bit.band(input.commands, Move.Drop) ~= 0 then
		if self:GetIsOnGround() and not self:GetIsOnEntity() then
			self:PerformEject() -- no waiting
		end
		return
	end
	
	Exo.HandleButtons( self, input )
end


Shared.LinkClassToMap("ReadyRoomExo", ReadyRoomExo.kMapName, networkVars)