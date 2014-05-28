// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\ReadyRoomBlink.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Swipe/blink - Left-click to attack, right click to show ghost. When ghost is showing,
// right click again to go there. Left-click to cancel. Attacking many times in a row will create
// a cool visual "chain" of attacks, showing the more flavorful animations in sequence.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Blink.lua")

class 'ReadyRoomBlink' (Blink)
ReadyRoomBlink.kMapName = "ready_room_blink"

local networkVars =
{
}

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")

function ReadyRoomBlink:OnCreate()

    Blink.OnCreate(self)
    
    self.primaryAttacking = false

end

function ReadyRoomBlink:GetAnimationGraphName()
    return kAnimationGraph
end

function ReadyRoomBlink:GetHUDSlot()
    return 1
end

function ReadyRoomBlink:GetSecondaryTechId()
    return kTechId.Blink
end

function ReadyRoomBlink:GetBlinkAllowed()
    return true
end

function ReadyRoomBlink:GetViewModelName()
	return ""
end

Shared.LinkClassToMap("ReadyRoomBlink", ReadyRoomBlink.kMapName, networkVars)