local mainMenu

function CHUDHitIndicatorSlider()
	if mainMenu ~= nil and mainMenu.CHUDOptionElements ~= nil then
		local value = mainMenu.CHUDOptionElements.CHUD_HitIndicator:GetValue()
		CHUDSetOption("hitindicator", value)
	end
end

function CHUDLocationSlider()
	if mainMenu ~= nil and mainMenu.CHUDOptionElements ~= nil then
		local value = mainMenu.CHUDOptionElements.CHUD_LocationAlpha:GetValue()
		CHUDSetOption("locationalpha", value)
	end
end

function CHUDMinimapSlider()
	if mainMenu ~= nil and mainMenu.CHUDOptionElements ~= nil then
		local value = mainMenu.CHUDOptionElements.CHUD_MinimapAlpha:GetValue()
		CHUDSetOption("minimapalpha", value)
	end
end

function CHUDSaveMenuSettings()
	if mainMenu ~= nil and mainMenu.CHUDOptionElements ~= nil then
		for _, option in pairs(mainMenu.CHUDOptionElements) do
			CHUDOption = CHUDOptions[option.index]
			if CHUDOption then
				if CHUDOption.valueType == "bool" then
					CHUDSetOption(option.index, option:GetActiveOptionIndex() > 1)
				elseif CHUDOption.valueType == "int" and CHUDOption.type == "select" then
					CHUDSetOption(option.index, option:GetActiveOptionIndex()-1)
				elseif CHUDOption.valueType == "float" then
					CHUDSetOption(option.index, option:GetValue())
				end
			end
		end
	end
end
	
local function BoolToIndex(value)
	if value then
		return 2
	end
	return 1
end

// Set appropriate form size without CSS		
originalMenuCreateOptions = Class_ReplaceMethod( "GUIMainMenu", "CreateOptionsForm",
	function(mainMenu, content, options, optionElements)
		local form = originalMenuCreateOptions(mainMenu, content, options, optionElements)
		form:SetHeight(#options*50)
		return form
	end)
	
local menuLinks = { }
originalInitMainMenu = Class_ReplaceMethod( "GUIMainMenu", "Initialize",
	function(self)

		mainMenu = self
		local optionsNr
		// Override CreateMainLink so we can get a table with menu entries
		// When we have a table with main menu entries we can sort it ourselves
		// Seems like the positions are 70px apart looking at the CSS, so we can do this in code!
		originalCreateMainLink = Class_ReplaceMethod( "GUIMainMenu", "CreateMainLink",
			function(self, text, className, linkNum)
				if className == "options_ingame" then
					optionsNr = linkNum
				end
				if optionsNr and optionsNr <= linkNum and text ~= "NS2+ OPTIONS" then
					linkNum = tostring(tonumber(linkNum)+1)
					if tonumber(linkNum) < 10 then
						linkNum = "0" .. linkNum
					end
				end
				local menuLink = originalCreateMainLink(self, text, className, linkNum)
				menuLink.linkNr = tonumber(linkNum)-1
				table.insert(menuLinks, menuLink)
				return menuLink
			end)

		originalInitMainMenu(self)
        self.chudOptionLink = self:CreateMainLink("NS2+ OPTIONS", "options", "06")
        self.chudOptionLink:AddEventCallbacks(
        {
            OnClick = function(self)
            
                if not mainMenu.CHUDOptionWindow then
					mainMenu:CreateCHUDOptionWindow()
                end
                mainMenu:TriggerOpenAnimation(mainMenu.CHUDOptionWindow)
                mainMenu:HideMenu()
                
            end
        })

		for _, menuLink in pairs(menuLinks) do
			menuLink:SetTopOffset(50+70*menuLink.linkNr)
		end
		
		self.profileBackground:SetTopOffset(-70)
		
	end)
	
originalHideMenu = Class_ReplaceMethod( "GUIMainMenu", "HideMenu",
	function(self)
		originalHideMenu(self)
		if self.chudOptionLink then
			self.chudOptionLink:SetIsVisible(false)
		end
	end)
	
originalMenuAnimations = Class_ReplaceMethod( "GUIMainMenu", "OnAnimationCompleted",
	function(self, animatedItem, animationName, itemHandle)
		if animationName == "ANIMATE_LINK_BG" then
			if self.chudOptionLink then
				self.chudOptionLink:SetFrameCount(15, 1.6, AnimateLinear, "ANIMATE_LINK_BG")
			end
			
		elseif animationName == "MAIN_MENU_MOVE" then
			if self.menuBackground:HasCSSClass("menu_bg_show") then
				if self.chudOptionLink then
					self.chudOptionLink:SetIsVisible(true)
				end
			end
		end
		originalMenuAnimations(self, animatedItem, animationName, itemHandle)
	end)
	
originalMainMenuResChange = Class_ReplaceMethod( "GUIMainMenu", "OnResolutionChanged",
	function(self, oldX, oldY, newX, newY)
		originalMainMenuResChange(self, oldX, oldY, newX, newY)
		for _, menuLink in pairs(menuLinks) do
			menuLink:SetTopOffset(50+70*menuLink.linkNr)
		end
		
		self.profileBackground:SetTopOffset(-70)
	end)
	
function GUIMainMenu:CreateCHUDOptionWindow()

    self.CHUDOptionWindow = self:CreateWindow()
    self.CHUDOptionWindow:DisableCloseButton()
    self.CHUDOptionWindow:SetCSSClass("option_window")
    
    self:SetupWindow(self.CHUDOptionWindow, "NS2+ OPTIONS")
    local function InitOptionWindow()
		for idx, option in pairs(CHUDOptions) do
			if option.valueType == "bool" then
				self.CHUDOptionElements[option.name]:SetOptionActive( BoolToIndex(CHUDOptions[idx].currentValue) )
			elseif option.valueType == "int" and option.type == "select" then
				self.CHUDOptionElements[option.name]:SetOptionActive( CHUDOptions[idx].currentValue+1 )
			elseif option.valueType == "float" then
				self.CHUDOptionElements[option.name]:SetValue( CHUDOptions[idx].currentValue )
			end
			self.CHUDOptionElements[option.name].index = idx
		end
		// When opening and closing menus the tooltips would appear behind the form
		// Increment the layer so it's always on top
		if mainMenu.optionTooltip then
			local background = mainMenu.optionTooltip.background
			local bgLayer = self.CHUDOptionWindow:GetContentBox():GetLayer()
			// Increment by 2 so it works for the Options menu too
			background:SetLayer(bgLayer+2)
		end
		
    end
    self.CHUDOptionWindow:AddEventCallbacks({ OnHide = InitOptionWindow })
    
    local content = self.CHUDOptionWindow:GetContentBox()
    
    local back = CreateMenuElement(self.CHUDOptionWindow, "MenuButton")
    back:SetCSSClass("back")
    back:SetText("BACK")
    back:AddEventCallbacks( { OnClick = function() self.CHUDOptionWindow:SetIsVisible(false) end } )
    
    local apply = CreateMenuElement(self.CHUDOptionWindow, "MenuButton")
    apply:SetCSSClass("apply")
    apply:SetText("APPLY")
    apply:AddEventCallbacks( { OnClick = function() CHUDSaveMenuSettings() end } )

    self.fpsDisplay = CreateMenuElement( self.CHUDOptionWindow, "MenuButton" )
    self.fpsDisplay:SetCSSClass("fps")
	
	local changelogButton = CreateMenuElement( self.CHUDOptionWindow, "MenuButton" )
	changelogButton:SetCSSClass("apply")
	changelogButton:SetLeftOffset(0)
	changelogButton:SetText("CHANGELOG")
	local kChangeURL = "http://steamcommunity.com/sharedfiles/filedetails/changelog/135458820"
    changelogButton:AddEventCallbacks( { OnClick = function() Client.ShowWebpage(kChangeURL) end } )
	
    self.warningLabel = CreateMenuElement(self.CHUDOptionWindow, "MenuButton", false)
    self.warningLabel:SetCSSClass("warning_label")
    self.warningLabel:SetText("Game restart required")
    self.warningLabel:SetIgnoreEvents(true)
    self.warningLabel:SetIsVisible(false)

    // save our option elements for future reference
    self.CHUDOptionElements = { }
	
	local HUDOptionsMenu = { }
	local FuncOptionsMenu = { }
	local CompOptionsMenu = { }
	
	// Put the options in the correct tab
	for idx, option in pairs(CHUDOptions) do
		if option.category == "hud" then
			table.insert(HUDOptionsMenu, CHUDOptions[idx])
		elseif option.category == "func" then
			table.insert(FuncOptionsMenu, CHUDOptions[idx])
		elseif option.category == "comp" then
			table.insert(CompOptionsMenu, CHUDOptions[idx])
		end
		
		function CHUDOptionsSort(a, b)	
			if a.sort == nil then
				a.sort = "Z" .. a.name
			end
			if b.sort == nil then
				b.sort = "Z" .. b.name
			end
			
			return a.sort < b.sort
		end
		table.sort(HUDOptionsMenu, CHUDOptionsSort)
		table.sort(FuncOptionsMenu, CHUDOptionsSort)
		table.sort(CompOptionsMenu, CHUDOptionsSort)
	end
    
    local CHUD_HUDForm = GUIMainMenu.CreateOptionsForm(self, content, HUDOptionsMenu, self.CHUDOptionElements)
	local CHUD_FuncForm = GUIMainMenu.CreateOptionsForm(self, content, FuncOptionsMenu, self.CHUDOptionElements)
	local CHUD_CompForm = GUIMainMenu.CreateOptionsForm(self, content, CompOptionsMenu, self.CHUDOptionElements)

    local tabs = 
        {
			{ label = "VISUAL", form = CHUD_FuncForm, scroll=true  },
			{ label = "HUD", form = CHUD_HUDForm, scroll=true  },
			{ label = "MAP", form = CHUD_CompForm, scroll=true  },
        }
        
    local xTabWidth = 256

    local tabBackground = CreateMenuElement(self.CHUDOptionWindow, "Image")
    tabBackground:SetCSSClass("tab_background")
    tabBackground:SetIgnoreEvents(true)
    
    local tabAnimateTime = 0.1
        
    for i = 1,#tabs do
    
        local tab = tabs[i]
        local tabButton = CreateMenuElement(self.CHUDOptionWindow, "MenuButton")
        
        local function ShowTab()
            for j =1,#tabs do
                tabs[j].form:SetIsVisible(i == j)
                self.CHUDOptionWindow:ResetSlideBar()
                self.CHUDOptionWindow:SetSlideBarVisible(tab.scroll == true)
                local tabPosition = tabButton.background:GetPosition()
                tabBackground:SetBackgroundPosition( tabPosition, false, tabAnimateTime ) 
            end
        end
    
        tabButton:SetCSSClass("tab")
        tabButton:SetText(tab.label)
        tabButton:AddEventCallbacks({ OnClick = ShowTab })
        
        local tabWidth = tabButton:GetWidth()
        tabButton:SetBackgroundPosition( Vector(tabWidth * (i - 1), 0, 0) )
        
        // Make the first tab visible.
        if i==1 then
            tabBackground:SetBackgroundPosition( Vector(tabWidth * (i - 1), 0, 0) )
            ShowTab()
        end
        
    end        
    
    InitOptionWindow()
  
end