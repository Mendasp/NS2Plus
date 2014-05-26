// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\ReadyRoomLeap.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
// 
// Bite is main attack, leap is secondary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/LeapMixin.lua")

class 'ReadyRoomLeap' (Ability)

ReadyRoomLeap.kMapName = "ready_room_leap"

local networkVars =
{
}


function ReadyRoomLeap:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, LeapMixin)
    
	self.GetHasSecondary = self.GetHasSecondaryOverride
    self.primaryAttacking = false
    self.secondaryAttacking = false

end


function ReadyRoomLeap:GetAnimationGraphName()
    return kAnimationGraph
end

function ReadyRoomLeap:GetHUDSlot()
    return 1
end

function ReadyRoomLeap:GetSecondaryTechId()
    return kTechId.Leap
end

-- This is set up in Leap:OnCreate
function ReadyRoomLeap:GetHasSecondaryOverride(player)
    return player.twoHives
end

function ReadyRoomLeap:GetViewModelName()
	return ""
end


Shared.LinkClassToMap("ReadyRoomLeap", ReadyRoomLeap.kMapName, networkVars)