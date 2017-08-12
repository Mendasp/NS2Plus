local widthFraction = 0.4
local kTextureName = "*chudmenu_news"
local kCHUDLogoTexture = PrecacheAsset("ui/chud_logo.dds")
local kCHUDMenuNewsURL = "http://www.mendasp.net/ns2plus-ingame/"

class 'CHUDGUI_MenuNews' (GUIScript)

function CHUDGUI_MenuNews:Initialize()

    local layer = kGUILayerMainMenuWeb

    local width = widthFraction * Client.GetScreenWidth()
    local rightMargin = math.min( 150, Client.GetScreenWidth()*0.05 )
    local logoAspect = 600/192
    local y = 10
    self.logo = GUIManager:CreateGraphicItem()
    self.logo:SetTexture(kCHUDLogoTexture)
    self.logo:SetLayer(layer)
    self.logo:SetSize(Vector(width, width/logoAspect, 0))
    self.logo:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.logo:SetPosition(Vector(-width-rightMargin, y, 0))
    y = y + width/logoAspect
    
    local newsHt = Client.GetScreenHeight() - (y*1.5)
    self.webView = Client.CreateWebView(width, newsHt)
    self.webView:SetTargetTexture(kTextureName)
    self.webView:LoadUrl(kCHUDMenuNewsURL)
    self.webContainer = GUIManager:CreateGraphicItem()
    self.webContainer:SetTexture(kTextureName)
    self.webContainer:SetLayer(layer)
    self.webContainer:SetSize(Vector(width, newsHt, 0))
    self.webContainer:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.webContainer:SetPosition(Vector(-width-rightMargin, y, 0))

    self.buttonDown = { [InputKey.MouseButton0] = false, [InputKey.MouseButton1] = false, [InputKey.MouseButton2] = false }

    self:SetIsVisible(false)

end

function CHUDGUI_MenuNews:Uninitialize()

    GUI.DestroyItem(self.webContainer)
    self.webContainer = nil
    
    Client.DestroyWebView(self.webView)
    self.webView = nil

    GUI.DestroyItem(self.logo)
    self.logo = nil
    
end

function CHUDGUI_MenuNews:SendKeyEvent(key, down, amount)

    if not self.isVisible or not MainMenu_GetIsOpened() then
        return
    end

    local isReleventKey = false
    
    if type(self.buttonDown[key]) == "boolean" then
        isReleventKey = true
    end
    
    local mouseX, mouseY = Client.GetCursorPosScreen()
    if isReleventKey then
        
        local containsPoint, withinX, withinY = GUIItemContainsPoint(self.webContainer, mouseX, mouseY)
        
        -- If we pressed the button inside the window, always send it the button up
        -- even if the cursor was outside the window.
        if containsPoint or (not down and self.buttonDown[key]) then
        
            local buttonCode = key - InputKey.MouseButton0
            if down then
                self.webView:OnMouseDown(buttonCode)
            else
                self.webView:OnMouseUp(buttonCode)
            end
            
            self.buttonDown[key] = down
            
            return true
            
        end
       
        if GUIItemContainsPoint( self.logo, mouseX, mouseY ) then
            Client.ShowWebpage("http://steamcommunity.com/sharedfiles/filedetails/?id=135458820")
        end
        
    elseif key == InputKey.MouseWheelUp then
        self.webView:OnMouseWheel(30, 0)
        MainMenu_OnSlide()
    elseif key == InputKey.MouseWheelDown then
        self.webView:OnMouseWheel(-30, 0)
        MainMenu_OnSlide()
    elseif key == InputKey.Escape and down then
        LeaveMenu()
        SetKeyEventBlocker(nil)
        return true
    end
    
    return false
    
end

function CHUDGUI_MenuNews:Update(deltaTime)
    
    if not self.isVisible then
        return
    end

    local mouseX, mouseY = Client.GetCursorPosScreen()
    local containsPoint, withinX, withinY = GUIItemContainsPoint(self.webContainer, mouseX, mouseY)
    if containsPoint or self.buttonDown[InputKey.MouseButton0] or self.buttonDown[InputKey.MouseButton1] or self.buttonDown[InputKey.MouseButton2] then
        self.webView:OnMouseMove(withinX, withinY)
    end

    if GUIItemContainsPoint( self.webContainer, mouseX, mouseY ) then
        SetKeyEventBlocker(self)
    else
        SetKeyEventBlocker(nil)
    end

end

function CHUDGUI_MenuNews:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function CHUDGUI_MenuNews:SetIsVisible(visible)
    self.webContainer:SetIsVisible(visible)
    self.logo:SetIsVisible(visible)
    self.isVisible = visible
    
    if visible == false then
        SetKeyEventBlocker(nil)
    end
end

function CHUDGUI_MenuNews:LoadURL(url)
    self.webView:LoadUrl(url)
end