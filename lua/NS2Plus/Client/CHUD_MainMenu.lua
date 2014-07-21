local mainMenu

function MakeCHUDSliderCallback( elemId, key )
	return function()
		if mainMenu ~= nil and mainMenu.CHUDOptionElements ~= nil then
			local multiplier = CHUDGetOptionParam(key, "multiplier") or 1
			local minValue = CHUDGetOptionParam(key, "minValue") or 0
			local maxValue = CHUDGetOptionParam(key, "maxValue") or 1
			local elem = mainMenu.CHUDOptionElements[elemId]
			local value = (elem:GetValue() * (maxValue - minValue) + minValue) * multiplier
			CHUDSetOption(key, value)
		end
	end
end
CHUDHitIndicatorSlider = MakeCHUDSliderCallback( "CHUD_HitIndicator", "hitindicator" )
CHUDLocationSlider = MakeCHUDSliderCallback( "CHUD_LocationAlpha", "locationalpha" )
CHUDMinimapSlider = MakeCHUDSliderCallback( "CHUD_MinimapAlpha", "minimapalpha" )
CHUDHitsoundsSlider = MakeCHUDSliderCallback( "CHUD_HitsoundsVolume", "hitsounds_vol" )
CHUDFlashAtmosSlider = MakeCHUDSliderCallback( "CHUD_FlashAtmos", "flashatmos" )
CHUDMapAtmosSlider = MakeCHUDSliderCallback( "CHUD_MapAtmos", "mapatmos" )
CHUDDMGScaleSlider = MakeCHUDSliderCallback( "CHUD_DMGScale", "dmgscale" )
CHUDDMGTimeSlider = MakeCHUDSliderCallback( "CHUD_DamageNumberTime", "damagenumbertime" )
CHUDKillFeedScaleSlider = MakeCHUDSliderCallback( "CHUD_KillFeedScale", "killfeedscale" )
CHUDKillFeedIconScaleSlider = MakeCHUDSliderCallback( "CHUD_KillFeedIconScale", "killfeediconscale" )
CHUDDecalSlider = MakeCHUDSliderCallback( "CHUD_MaxDecalLifeTime", "maxdecallifetime" )


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
					local multiplier = CHUDOption.multiplier or 1
					local minValue = CHUDOption.minValue or 0
					local maxValue = CHUDOption.maxValue or 1
					CHUDSetOption(option.index, (option:GetValue() * (maxValue - minValue) + minValue) * multiplier)
				end
							
				if CHUDOption.disabled then
					local val = ConditionalValue(CHUDOption.disabledValue == nil, CHUDOption.defaultValue, CHUDOption.disabledValue)
					if val == CHUDOption.currentValue then
						option.label:SetCSSClass("option_label")
					else
						option.label:SetCSSClass("option_label_disabled")
					end
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
	
originalCreateMainLinks = Class_ReplaceMethod( "GUIMainMenu", "CreateMainLinks", function(self)
		mainMenu = self
		local OnClick = function(self)            
			if not self.scriptHandle.CHUDOptionWindow then
				self.scriptHandle:CreateCHUDOptionWindow()
			end
			self.scriptHandle:TriggerOpenAnimation(self.scriptHandle.CHUDOptionWindow)
			self.scriptHandle:HideMenu()
		end
		self:AddMainLink( "NS2+ OPTIONS", 6, OnClick, 2)
		originalCreateMainLinks(self)
		
		for i, menuLink in pairs(self.Links) do
			menuLink:SetTopOffset(50+70*(i-1))
		end
		
		self.profileBackground:SetTopOffset(-70)
	end)
	
originalHideMenu = Class_ReplaceMethod( "GUIMainMenu", "HideMenu",
	function(self)
		if self.CHUDNewsScript then
			self.CHUDNewsScript:SetIsVisible(false)
		end
	
		originalHideMenu(self)

	end)
	
originalMenuAnimations = Class_ReplaceMethod( "GUIMainMenu", "OnAnimationCompleted",
	function(self, animatedItem, animationName, itemHandle)
		if animationName == "MAIN_MENU_MOVE" and self.menuBackground:HasCSSClass("menu_bg_show") and self.CHUDNewsScript then
			self.CHUDNewsScript:SetIsVisible(true)
		end

		originalMenuAnimations(self, animatedItem, animationName, itemHandle)
	end)
	
originalMainMenuResChange = Class_ReplaceMethod( "GUIMainMenu", "OnResolutionChanged",
	function(self, oldX, oldY, newX, newY)
		originalMainMenuResChange(self, oldX, oldY, newX, newY)
		for i, menuLink in pairs(self.Links) do
			menuLink:SetTopOffset(50+70*(i-1))
		end
		
		self.profileBackground:SetTopOffset(-70)
		
		if CHUDGetOption("mingui") then
			mainMenu.mainWindow:SetBackgroundTexture("ui/transparent.dds")
		else
			mainMenu.mainWindow:SetBackgroundTexture("ui/menu/grid.dds")
			mainMenu.mainWindow:SetBackgroundRepeat(true)
		end
	end)

Client.PrecacheLocalSound("sound/chud.fev/CHUD/open_menu")
	
function MainMenu_OnOpenMenu()
	StartSoundEffect("sound/chud.fev/CHUD/open_menu")
	mainMenu.tvGlareImage:SetIsVisible(false)
	mainMenu.scanLine:SetIsVisible(not CHUDGetOption("mingui"))
	
	if CHUDGetOption("mingui") then
		mainMenu.mainWindow:SetBackgroundTexture("ui/transparent.dds")
	else
		mainMenu.mainWindow:SetBackgroundTexture("ui/menu/grid.dds")
		mainMenu.mainWindow:SetBackgroundRepeat(true)
	end
	
	if not mainMenu.CHUDNewsScript then
		mainMenu.CHUDNewsScript = GetGUIManager():CreateGUIScript("NS2Plus/Client/CHUDGUI_MenuNews")
	else
		// Solves issue where the news were visible when you click options and then spam escape
		// This hides the news script properly
		mainMenu.CHUDNewsScript:SetIsVisible(mainMenu.Links[1]:GetIsVisible())
	end

end

function MainMenu_OnCloseMenu()
	Shared.StopSound(nil, "sound/chud.fev/CHUD/open_menu")
	
	if mainMenu and mainMenu.CHUDNewsScript then
		// Kill it, KILL IT WITH FIRE
		GetGUIManager():DestroyGUIScript(mainMenu.CHUDNewsScript)
		mainMenu.CHUDNewsScript:Uninitialize()
		mainMenu.CHUDNewsScript = nil
	end
end
	
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
				local minValue = option.minValue or 0
				local maxValue = option.maxValue or 1
				self.CHUDOptionElements[option.name]:SetValue( (CHUDOptions[idx].currentValue - minValue) / (maxValue - minValue) )
			end
			self.CHUDOptionElements[option.name].index = idx
		end
		// When opening and closing menus the tooltips would appear behind the form
		// Increment the layer so it's always on top
		if mainMenu.optionTooltip then
			local background = mainMenu.optionTooltip.background
			local bgLayer = self.CHUDOptionWindow:GetContentBox():GetLayer()
			// Increment by 2 so it works for the Options menu too if we open this menu first
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
	
	local CHUD_HUDForm = GUIMainMenu.CreateCHUDOptionsForm(self, content, HUDOptionsMenu, self.CHUDOptionElements)
	local CHUD_FuncForm = GUIMainMenu.CreateCHUDOptionsForm(self, content, FuncOptionsMenu, self.CHUDOptionElements)
	local CHUD_CompForm = GUIMainMenu.CreateCHUDOptionsForm(self, content, CompOptionsMenu, self.CHUDOptionElements)

	local tabs = 
		{
			{ label = "VISUAL", form = CHUD_FuncForm, scroll=true  },
			{ label = "HUD", form = CHUD_HUDForm, scroll=true  },
			{ label = "MISC", form = CHUD_CompForm, scroll=true  },
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

GUIMainMenu.CreateCHUDOptionsForm = function(mainMenu, content, options, optionElements)

	local form = CreateMenuElement(content, "Form", false)
	
	local rowHeight = 50
	
	local y = 0
	
	for _, option in ipairs(options) do
	
		local input
		local input_display
		local defaultInputClass = "option_input"
		local multiplier = option.multiplier or 1
		local minValue = option.minValue or 0
		local maxValue = option.maxValue or 1
		
		if option.type == "select" then
			input = form:CreateFormElement(Form.kElementType.DropDown, option.name, option.value)
			if option.values then
				input:SetOptions(option.values)
			end                
			if option.name == "CHUD_Hitsounds" then
				local soundPreview = CreateMenuElement(form, "MenuButton", false)
				soundPreview:SetCSSClass("clear_keybind")
				soundPreview:SetBorderColor(Color(0.54, 0.7, 0.75, 0.7))
				soundPreview:SetTextColor(Color(0.54, 0.7, 0.75, 0.7))
				soundPreview:SetText(">")
				soundPreview:SetTopOffset(y)
				
				function soundPreview:OnClick()
					HitSounds_PlayHitsound( 1 )
				end
				
			elseif option.name == "CHUD_HitsoundsPitch" then
				local soundPreview = CreateMenuElement(form, "MenuButton", false)
				soundPreview:SetCSSClass("clear_keybind")
				soundPreview:SetBorderColor(Color(0.54, 0.7, 0.75, 0.7))
				soundPreview:SetTextColor(Color(0.54, 0.7, 0.75, 0.7))
				soundPreview:SetText(">")
				soundPreview:SetTopOffset(y)
				
				function soundPreview:OnClick()
					HitSounds_PlayHitsound( 3 )
				end
			end
			
		elseif option.type == "slider" then
			input = form:CreateFormElement(Form.kElementType.SlideBar, option.name, option.value)
			input_display = form:CreateFormElement(Form.kElementType.TextInput, option.name, option.value)
			input_display:SetNumbersOnly(true)	
			input_display:SetXAlignment(GUIItem.Align_Min)
			input_display:SetMarginLeft(5)
			if option.formName and option.formName == "sound" then
				input_display:SetCSSClass("display_sound_input")
			else
				input_display:SetCSSClass("display_input")
			end
			input_display:SetTopOffset(y)
			input_display:SetValue(ToString( input:GetValue() ))
			input_display:AddEventCallbacks({ 
				
			OnEnter = function(self)
				if input_display:GetValue() ~= "" and input_display:GetValue() ~= "." then
					input:SetValue(((input_display:GetValue() / multiplier) - minValue) / (maxValue - minValue))
				end
				if input_display:GetValue() == "" or input_display:GetValue() == "." then
					local value = (input:GetValue() * (maxValue - minValue) + minValue) * multiplier
					input_display:SetValue(ToString(string.sub(value, 0, ConditionalValue(value > 100, 5, 4))))
				end
			
			end,
			OnBlur = function(self)
				if input_display:GetValue() ~= "" and input_display:GetValue() ~= "." then
					input:SetValue(((input_display:GetValue() / multiplier) - minValue) / (maxValue - minValue))
				end
				
				if input_display:GetValue() == "" or input_display:GetValue() == "." then
					local value = (input:GetValue() * (maxValue - minValue) + minValue) * multiplier
					input_display:SetValue(ToString(string.sub(value, 0, ConditionalValue(value > 100, 5, 4))))
				end
			end,
			})
			// HACK: Really should use input:AddSetValueCallback, but the slider bar bypasses that.
			if option.sliderCallback then
				input:Register(
					{OnSlide =
						function(value, interest)
							option.sliderCallback(mainMenu)
							local value = (input:GetValue() * (maxValue - minValue) + minValue) * multiplier
							input_display:SetValue(ToString(string.sub(value, 0, ConditionalValue(value > 100, 5, 4))))
						end
					}, SLIDE_HORIZONTAL)
			end
		elseif option.type == "progress" then
			input = form:CreateFormElement(Form.kElementType.ProgressBar, option.name, option.value)       
		elseif option.type == "checkbox" then
			input = form:CreateFormElement(Form.kElementType.Checkbox, option.name, option.value)
			defaultInputClass = "option_checkbox"
		else
			input = form:CreateFormElement(Form.kElementType.TextInput, option.name, option.value)
		end
		
		if option.callback then
			input:AddSetValueCallback(option.callback)
		end
		local inputClass = defaultInputClass
		if option.inputClass then
			inputClass = option.inputClass
		end
		
		input:SetCSSClass(inputClass)
		input:SetTopOffset(y)
		
		local label = CreateMenuElement(form, "Font", false)
		label:SetCSSClass("option_label")
		label:SetText(string.upper(option.label) .. ":")
		label:SetTopOffset(y)
		label:SetIgnoreEvents(false)
		
		local tooltipCallbacks = { 
			OnMouseOver = function(self)
				if mainMenu ~= nil then
					local text = option.tooltip
					if text ~= nil then
						local val = ConditionalValue(option.disabledValue == nil, option.defaultValue, option.disabledValue)
						if option.disabled and val ~= option.currentValue then
							text = text .. " (Disabled by server)."
						end
						
						local cutoff = 290
						
						mainMenu.optionTooltip.tooltip:SetText(WordWrap(mainMenu.optionTooltip.tooltip, text, 0, cutoff))
						
						text = mainMenu.optionTooltip.tooltip:GetText()
						local wrapped = string.find(text, "\n")
						
						mainMenu.optionTooltip.tooltip:SetPosition(Vector(15, ConditionalValue(wrapped and wrapped > 0, -10, 0), 0))
					else
						mainMenu.optionTooltip.tooltip:SetText("")
					end
				end    
			end,
			
			OnMouseOut = function(self)
				if mainMenu ~= nil then
					mainMenu.optionTooltip.tooltip:SetText("")
				end
			end,
			}

		label:AddEventCallbacks(tooltipCallbacks)
		for _, child in ipairs(input.children) do
			child:AddEventCallbacks(tooltipCallbacks)
		end
		
		optionElements[option.name] = input
		optionElements[option.name].label = label
		
		y = y + rowHeight

	end
	
	form:SetCSSClass("options")
	form:SetHeight(y)

	return form

end