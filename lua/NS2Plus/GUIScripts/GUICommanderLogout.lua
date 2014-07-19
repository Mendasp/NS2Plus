Script.Load("lua/GUICommanderLogout.lua")

function GUICommanderLogout:SendKeyEvent(key, down)

    if key == InputKey.MouseButton0 then

        local mouseX, mouseY = Client.GetCursorPosScreen()
        local containsPoint, withinX, withinY = GUIItemContainsPoint(self.background, mouseX, mouseY)
        
        if containsPoint and GetCommanderLogoutAllowed() then
            // Check if the button was pressed.
            if not down then
                CommanderUI_Logout()
                return false
            end
            return true
        end
        
    end
    
    return false
    
end