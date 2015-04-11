local mainMenu
LoadCSSFile("lua/NS2Plus/Client/chud.css")

function GetCHUDMainMenu()
	return mainMenu
end

local function CHUDSliderCallback(elemId)
	if mainMenu ~= nil and mainMenu.CHUDOptionElements ~= nil then
		local key = mainMenu.CHUDOptionElements[elemId].index
		local multiplier = CHUDGetOptionParam(key, "multiplier") or 1
		local minValue = CHUDGetOptionParam(key, "minValue") or 0
		local maxValue = CHUDGetOptionParam(key, "maxValue") or 1
		local elem = mainMenu.CHUDOptionElements[elemId]
		local value = (elem:GetValue() * (maxValue - minValue) + minValue) * multiplier
		CHUDSetOption(key, Round(value, 2))
		elem.resetOption:SetIsVisible(CHUDOptions[key].defaultValue ~= CHUDOptions[key].currentValue)
	end
end

local function CHUDDisplayDefaultColorText(elemId)
	if mainMenu ~= nil and mainMenu.CHUDOptionElements ~= nil then
		local index = mainMenu.CHUDOptionElements[elemId].index
		local option = CHUDOptions[index]
		local colorInt = ColorToColorInt(mainMenu.CHUDOptionElements[elemId]:GetBackground():GetColor())
		if option and option.defaultValue == colorInt then
			mainMenu.CHUDOptionElements[elemId].text:SetIsVisible(true)
			-- Invert color
			mainMenu.CHUDOptionElements[elemId].text:SetColor(ColorIntToColor(0xFFFFFF - colorInt))
		else
			mainMenu.CHUDOptionElements[elemId].text:SetIsVisible(false)
		end
	end
end

local function CHUDSetOptionVisible(option, visible)
	option:SetIsVisible(visible)
	option.label:SetIsVisible(visible)
	if option.soundPreview then
		option.soundPreview:SetIsVisible(visible)
	end
	if option.input_display then
		option.input_display:SetIsVisible(visible)
	end
	local index = option.index
	local CHUDOption = CHUDOptions[index]
	if CHUDOption then
		option.resetOption:SetIsVisible(visible and CHUDOption.defaultValue ~= CHUDOption.currentValue)
	end
end

local function CHUDResortForm()
	if mainMenu ~= nil and mainMenu.sortedOptionTables ~= nil then
		for _, optionsTable in ipairs(mainMenu.sortedOptionTables) do
			local y = 0
			for index, option in ipairs(optionsTable) do
				local optionElem = mainMenu.CHUDOptionElements[option.name]
				if optionElem:GetIsVisible() then
					optionElem:SetTopOffset(y)
					optionElem.label:SetTopOffset(y)
					if optionElem.soundPreview then
						optionElem.soundPreview:SetTopOffset(y)
					end
					if optionElem.input_display then
						optionElem.input_display:SetTopOffset(y)
					end
					optionElem.resetOption:SetTopOffset(y)
					y = y + 50
				end
			end
		end
	end
end

local function CHUDSaveMenuSetting(name)
	if mainMenu ~= nil and mainMenu.CHUDOptionElements ~= nil then
		local CHUDMenuOption = mainMenu.CHUDOptionElements[name]
		local index = CHUDMenuOption.index
		local CHUDOption = CHUDOptions[index]
		if CHUDOption then
			-- We don't need to save floats, as that's being handled by the slider callback
			-- Which is called on menu open and close, and when changing the value, of course
			if CHUDOption.valueType == "bool" then
				CHUDSetOption(index, CHUDMenuOption:GetActiveOptionIndex() > 1)
			elseif CHUDOption.valueType == "int" and CHUDOption.type == "select" then
				CHUDSetOption(index, CHUDMenuOption:GetActiveOptionIndex()-1)
			elseif CHUDOption.valueType == "color" then
				CHUDSetOption(index, ColorToColorInt(CHUDMenuOption:GetBackground():GetColor()))
			end
			
			if CHUDOption.disabled then
				local val = ConditionalValue(CHUDOption.disabledValue == nil, CHUDOption.defaultValue, CHUDOption.disabledValue)
				if val == CHUDOption.currentValue then
					CHUDMenuOption.label:SetCSSClass("option_label")
				else
					CHUDMenuOption.label:SetCSSClass("option_label_disabled")
				end
			end
			
			CHUDMenuOption.resetOption:SetIsVisible(CHUDOption.defaultValue ~= CHUDOption.currentValue)
			
			if CHUDOption.children then
				local show = true
				for _, value in pairs(CHUDOption.hideValues) do
					if CHUDOption.currentValue == value then
						show = false
					end
				end
				
				for _, option in pairs(CHUDOption.children) do
					local optionName = CHUDGetOptionParam(option, "name")
					if optionName then
						CHUDSetOptionVisible(mainMenu.CHUDOptionElements[optionName], show)
					end
				end
				
				CHUDResortForm()
			end
		end
	end
end

local function ResetMenuOption(option)
	if mainMenu ~= nil then
		if option.type == "select" then
			local optionDefaultValue = option.defaultValue
			if option.valueType == "bool" then
				optionDefaultValue = option.defaultValue == true and 1 or 0
			end
			mainMenu.CHUDOptionElements[option.name]:SetOptionActive(optionDefaultValue+1)
			CHUDSetOption(mainMenu.CHUDOptionElements[option.name].index, option.defaultValue)
		elseif option.type == "slider" then
			local multiplier = option.multiplier or 1
			local minValue = option.minValue or 0
			local maxValue = option.maxValue or 1
			local value = (option.defaultValue - minValue) / (maxValue - minValue)
			mainMenu.CHUDOptionElements[option.name]:SetValue(value)
			CHUDSetOption(mainMenu.CHUDOptionElements[option.name].index, option.defaultValue * multiplier)
		elseif option.valueType == "color" then
			mainMenu.CHUDOptionElements[option.name]:GetBackground():SetColor(ColorIntToColor(option.defaultValue))
			CHUDSetOption(mainMenu.CHUDOptionElements[option.name].index, option.defaultValue)
			CHUDDisplayDefaultColorText(option.name)
			CHUDSaveMenuSetting(option.name)
		end
	end
end

local function ResetAllCHUDSettings()
	if mainMenu ~= nil then
		for _, option in pairs(mainMenu.CHUDOptionElements) do
			local CHUDOption = CHUDOptions[option.index]
			ResetMenuOption(CHUDOption)
		end
	end
end

local function BoolToIndex(value)
	if value then
		return 2
	end
	return 1
end

-- Set appropriate form size without CSS
local originalMenuCreateOptions
originalMenuCreateOptions = Class_ReplaceMethod( "GUIMainMenu", "CreateOptionsForm",
	function(mainMenu, content, options, optionElements)
		local form = originalMenuCreateOptions(mainMenu, content, options, optionElements)
		form:SetHeight(#options*50)
		return form
	end)
	
-- Add join button to server details window
local originalMenuServerDetails
originalMenuServerDetails = Class_ReplaceMethod( "GUIMainMenu", "CreateServerDetailsWindow",
	function(self)
		originalMenuServerDetails(self)
		
		self.serverDetailsWindow.joinButton = CreateMenuElement(self.serverDetailsWindow, "MenuButton")
		self.serverDetailsWindow.joinButton:SetCSSClass("apply")
		self.serverDetailsWindow.joinButton:SetText(Locale.ResolveString("JOIN"))
		self.serverDetailsWindow.joinButton:AddEventCallbacks( {OnClick = function(self) self.scriptHandle:ProcessJoinServer() end } )
		self.serverDetailsWindow.joinButton:SetBottomOffset(10)
		
		self.serverDetailsWindow.slideBar:SetHeight(380)
		self.serverDetailsWindow:GetContentBox():SetHeight(380)
	end)

local CreateKeyBindingsForm = GetUpValue(GUIMainMenu.CreateOptionWindow, "CreateKeyBindingsForm", { LocateRecurse = true })
local function newCreateKeyBindingsForm(self, content)
	local form = CreateKeyBindingsForm(self, content)
	local bindingsTable = BindingsUI_GetBindingsTable()
		form:SetHeight(#bindingsTable*50)
	return form
end
ReplaceUpValue(GUIMainMenu.CreateOptionWindow, "CreateKeyBindingsForm", newCreateKeyBindingsForm, { LocateRecurse = true })

originalCreateMainLinks = Class_ReplaceMethod( "GUIMainMenu", "CreateMainLinks", function(self)
		mainMenu = self
		local OnClick = function(self)
			if not self.scriptHandle.CHUDOptionWindow then
				self.scriptHandle:CreateCHUDOptionWindow()
			end
			self.scriptHandle:TriggerOpenAnimation(self.scriptHandle.CHUDOptionWindow)
			self.scriptHandle:HideMenu()
		end
		self:AddMainLink( "NS2+ OPTIONS", 6, OnClick, 3)
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
	mainMenu.tvGlareImage:SetIsVisible(not MainMenu_IsInGame())
	mainMenu.scanLine:SetIsVisible(not CHUDGetOption("mingui"))
	
	if CHUDGetOption("mingui") then
		mainMenu.mainWindow:SetBackgroundTexture("ui/transparent.dds")
	else
		mainMenu.mainWindow:SetBackgroundTexture("ui/menu/grid.dds")
		mainMenu.mainWindow:SetBackgroundRepeat(true)
	end
	
	if not CHUDMainMenu then
		if not mainMenu.CHUDNewsScript then
			mainMenu.CHUDNewsScript = GetGUIManager():CreateGUIScript("NS2Plus/Client/CHUDGUI_MenuNews")
		else
			-- Solves issue where the news were visible when you click options and then spam escape
			-- This hides the news script properly
			mainMenu.CHUDNewsScript:SetIsVisible(mainMenu.Links[1]:GetIsVisible())
		end
	end

end

function MainMenu_OnCloseMenu()
	Shared.StopSound(nil, "sound/chud.fev/CHUD/open_menu")
	
	if mainMenu and mainMenu.CHUDNewsScript then
		-- Kill it, KILL IT WITH FIRE
		GetGUIManager():DestroyGUIScript(mainMenu.CHUDNewsScript)
		mainMenu.CHUDNewsScript:Uninitialize()
		mainMenu.CHUDNewsScript = nil
	end
end
	
function GUIMainMenu:CreateCHUDOptionWindow()
	
	self:CreateColorPickerWindow()
	self.CHUDOptionWindow = self:CreateWindow()
	self.CHUDOptionWindow:DisableCloseButton()
	self.CHUDOptionWindow:SetCSSClass("option_window")
	
	self:SetupWindow(self.CHUDOptionWindow, "NS2+ OPTIONS")
	local function InitOptionWindow()
		for idx, option in pairs(CHUDOptions) do
			self.CHUDOptionElements[option.name].index = idx
			if option.valueType == "bool" then
				self.CHUDOptionElements[option.name]:SetOptionActive( BoolToIndex(CHUDOptions[idx].currentValue) )
			elseif option.valueType == "int" and option.type == "select" then
				self.CHUDOptionElements[option.name]:SetOptionActive( CHUDOptions[idx].currentValue+1 )
			elseif option.valueType == "float" then
				local minValue = option.minValue or 0
				local maxValue = option.maxValue or 1
				self.CHUDOptionElements[option.name]:SetValue( (CHUDOptions[idx].currentValue - minValue) / (maxValue - minValue) )
			elseif option.valueType == "color" then
				self.CHUDOptionElements[option.name]:GetBackground():SetColor(ColorIntToColor(CHUDOptions[idx].currentValue))
				CHUDDisplayDefaultColorText(option.name)
				CHUDSaveMenuSetting(option.name)
			end
		end
		-- When opening and closing menus the tooltips would appear behind the form
		-- Increment the layer so it's always on top
		if mainMenu.optionTooltip then
			local background = mainMenu.optionTooltip.background
			local bgLayer = self.CHUDOptionWindow:GetContentBox():GetLayer()
			-- Increment by 2 so it works for the Options menu too if we open this menu first
			background:SetLayer(bgLayer+2)
		end
		
	end
	
	local content = self.CHUDOptionWindow:GetContentBox()
	
	local back = CreateMenuElement(self.CHUDOptionWindow, "MenuButton")
	back:SetCSSClass("apply")
	back:SetText("BACK")
	back:AddEventCallbacks( { OnClick = function() self.CHUDOptionWindow:SetIsVisible(false) end } )
	
	local resetCallbacks = { 
		OnMouseOver = function(self)
			if mainMenu ~= nil then
				mainMenu.optionTooltip:SetText("WARNING: This will reset all the NS2+ options to default values.")
				mainMenu.optionTooltip:Show()
			else
				mainMenu.optionTooltip:Hide()
			end
		end,
		
		OnMouseOut = function(self)
			if mainMenu ~= nil then
				mainMenu.optionTooltip:Hide()
			end
		end,
		
		OnClick = function(self)
			ResetAllCHUDSettings()
		end,
		}
	
	local resetButton = CreateMenuElement( self.CHUDOptionWindow, "MenuButton" )
	resetButton:SetCSSClass("reset_all")
	resetButton:SetText("RESET NS2+ VALUES")
	resetButton:AddEventCallbacks(resetCallbacks)
	
	local changelogButton = CreateMenuElement( self.CHUDOptionWindow, "MenuButton" )
	changelogButton:SetCSSClass("back")
	changelogButton:SetText("CHANGELOG")
	local kChangeURL = "http://steamcommunity.com/sharedfiles/filedetails/changelog/135458820"
	changelogButton:AddEventCallbacks( { OnClick = function() Client.ShowWebpage(kChangeURL) end } )
	changelogButton:SetLeftOffset(260)
	
	self.warningLabel = CreateMenuElement(self.CHUDOptionWindow, "MenuButton", false)
	self.warningLabel:SetCSSClass("warning_label")
	self.warningLabel:SetText("Game restart required")
	self.warningLabel:SetIgnoreEvents(true)
	self.warningLabel:SetIsVisible(false)

	-- save our option elements for future reference
	self.CHUDOptionElements = { }
	
	local HUDOptionsMenu = { }
	local FuncOptionsMenu = { }
	local CompOptionsMenu = { }
	
	-- Put the options in the correct tab
	for idx, option in pairs(CHUDOptions) do
		if option.category == "hud" then
			table.insert(HUDOptionsMenu, CHUDOptions[idx])
		elseif option.category == "func" then
			table.insert(FuncOptionsMenu, CHUDOptions[idx])
		elseif option.category == "comp" then
			table.insert(CompOptionsMenu, CHUDOptions[idx])
		end
		
		local function CHUDOptionsSort(a, b)
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
		
		-- Make the first tab visible.
		if i==1 then
			tabBackground:SetBackgroundPosition( Vector(tabWidth * (i - 1), 0, 0) )
			ShowTab()
		end
		
	end
	
	InitOptionWindow()
	
	self.sortedOptionTables = {}
	table.insert(self.sortedOptionTables, CompOptionsMenu)
	table.insert(self.sortedOptionTables, FuncOptionsMenu)
	table.insert(self.sortedOptionTables, HUDOptionsMenu)
	
	CHUDResortForm()
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
		
		local resetOption = CreateMenuElement(form, "MenuButton", false)
		resetOption:SetCSSClass("reset_chud_option")
		resetOption:SetText("X")
		resetOption:SetTopOffset(y)
		
		local tooltipCallbacks = { 
			OnMouseOver = function(self)
				if mainMenu ~= nil then
					local defaultValue = option.defaultValue
					if option.valueType == "float" then
						defaultValue = tostring(defaultValue * (option.multiplier or 1))
					elseif option.valueType == "bool" then
						if option.defaultValue == true then
							defaultValue = option.values[2]
						else
							defaultValue = option.values[1]
						end
					elseif option.valueType == "int" then
						defaultValue = option.values[defaultValue+1]
					elseif option.valueType == "color" then
						local tmpColor = ColorIntToColor(defaultValue)
						defaultValue = tostring(math.floor(tmpColor.r*255)) .. " " .. tostring(math.floor(tmpColor.g*255)) .. " " .. tostring(math.floor(tmpColor.b*255))
					end
					mainMenu.optionTooltip:SetText("Reset to default value (" .. defaultValue .. ").")
					mainMenu.optionTooltip:Show()
				else
					mainMenu.optionTooltip:Hide()
				end
			end,
			
			OnMouseOut = function(self)
				if mainMenu ~= nil then
					mainMenu.optionTooltip:Hide()
				end
			end,
			
			OnClick = function(self)
				ResetMenuOption(option)
			end,
			}

		resetOption:AddEventCallbacks(tooltipCallbacks)
		
		if option.type == "select" then
			input = form:CreateFormElement(Form.kElementType.DropDown, option.name, option.value)
			if option.values then
				input:SetOptions(option.values)
			end
			
			if option.name == "CHUD_Hitsounds" then
				option.inputClass = "option_input_chud"
				local soundPreview = CreateMenuElement(form, "MenuButton", false)
				soundPreview:SetCSSClass("sound_preview_chud")
				soundPreview:SetText(">")
				soundPreview:SetTopOffset(y)
				
				function soundPreview:OnClick()
					HitSounds_PlayHitsound( 1 )
				end
				
				input.soundPreview = soundPreview
			elseif option.name == "CHUD_HitsoundsPitch" then
				option.inputClass = "option_input_chud"
				local soundPreview = CreateMenuElement(form, "MenuButton", false)
				soundPreview:SetCSSClass("sound_preview_chud")
				soundPreview:SetText(">")
				soundPreview:SetTopOffset(y)
				
				function soundPreview:OnClick()
					HitSounds_PlayHitsound( 3 )
				end
				
				input.soundPreview = soundPreview
			end
			
		elseif option.type == "slider" then
			option.inputClass = "option_input_chud"
			input = form:CreateFormElement(Form.kElementType.SlideBar, option.name, option.value)
			input_display = form:CreateFormElement(Form.kElementType.TextInput, option.name, option.value)
			input_display:SetNumbersOnly(true)
			input_display:SetXAlignment(GUIItem.Align_Min)
			input_display:SetMarginLeft(5)
			input_display:SetCSSClass("display_input_chud")
			input_display:SetTopOffset(y)
			input_display:SetValue(ToString( input:GetValue() ))
			input_display:AddEventCallbacks({ 
				
			OnEnter = function(self)
				if input_display:GetValue() ~= "" and input_display:GetValue() ~= "." then
					input:SetValue(Round(((input_display:GetValue() / multiplier) - minValue) / (maxValue - minValue),4))
				end
				if input_display:GetValue() == "" or input_display:GetValue() == "." then
					local value = (input:GetValue() * (maxValue - minValue) + minValue) * multiplier
					input_display:SetValue(ToString(string.sub(value, 0, ConditionalValue(value > 100, 5, 4))))
				end
			
			end,
			OnBlur = function(self)
				if input_display:GetValue() ~= "" and input_display:GetValue() ~= "." then
					input:SetValue(Round(((input_display:GetValue() / multiplier) - minValue) / (maxValue - minValue),4))
				end
				
				if input_display:GetValue() == "" or input_display:GetValue() == "." then
					local value = (input:GetValue() * (maxValue - minValue) + minValue) * multiplier
					input_display:SetValue(ToString(string.sub(value, 0, ConditionalValue(value > 100, 5, 4))))
				end
			end,
			})
			input:Register(
				{OnSlide =
					function(value, interest)
						CHUDSliderCallback(option.name)
						local value = (input:GetValue() * (maxValue - minValue) + minValue) * multiplier
						input_display:SetValue(ToString(string.sub(Round(value,2), 0, ConditionalValue(value > 100, 5, 4))))
					end
				}, SLIDE_HORIZONTAL)
		elseif option.valueType == "color" then
			option.inputClass = "colorpicker_input"
			input = form:CreateFormElement(Form.kElementType.FormButton, option.name, option.value)
			input.text:SetText("Default")
			input.text:SetAnchor(GUIItem.Middle, GUIItem.Center)
			input.text:SetPosition(Vector(0, 0, 0))
			input.text:SetTextAlignmentX(GUIItem.Align_Center)
			input.text:SetIsVisible(false)
			input:AddEventCallbacks({
				OnClick = function(self)
					self.scriptHandle.colorPickerWindow:SetIsVisible(true)
					local color = self:GetBackground():GetColor()
					self.scriptHandle.colorPickerRedInput:SetValue(tostring(math.floor(color.r*255)))
					self.scriptHandle.colorPickerGreenInput:SetValue(tostring(math.floor(color.g*255)))
					self.scriptHandle.colorPickerBlueInput:SetValue(tostring(math.floor(color.b*255)))
					self.scriptHandle.colorPreview:SetBackgroundColor(Color(color.r, color.g, color.b, 1))
					self.scriptHandle.colorPickerMenuElement = self
					self.scriptHandle.colorPickerWindowText:SetText(option.label)
				end})
		elseif option.type == "progress" then
			input = form:CreateFormElement(Form.kElementType.ProgressBar, option.name, option.value)
		elseif option.type == "checkbox" then
			input = form:CreateFormElement(Form.kElementType.Checkbox, option.name, option.value)
			defaultInputClass = "option_checkbox"
		else
			input = form:CreateFormElement(Form.kElementType.TextInput, option.name, option.value)
		end
		
		-- Sliders have their own callbacks/saving
		if option.type ~= "slider" then
			input:AddSetValueCallback(function() CHUDSaveMenuSetting(option.name) end)
		end
		
		local inputClass = defaultInputClass
		if option.inputClass then
			inputClass = option.inputClass
		end
		
		input:SetCSSClass(inputClass)
		input:SetTopOffset(y)
		
		-- Remove horrid white dot
		if input.label then
			input.label:SetIsVisible(false)
		end
		
		local label = CreateMenuElement(form, "Font", false)
		label:SetCSSClass("option_label")
		label:SetText(string.upper(option.label) .. ":")
		label:SetTopOffset(y)
		label:SetIgnoreEvents(false)
		
		local tooltipCallbacks = { 
			OnMouseOver = function(self)
				if mainMenu ~= nil then
					local text = option.tooltip
					local texture = option.helpImage
					local textureSize = option.helpImageSize
					if text ~= nil then
						local val = ConditionalValue(option.disabledValue == nil, option.defaultValue, option.disabledValue)
						if option.disabled and val ~= option.currentValue then
							text = text .. " (Disabled by server)."
						end
						
						mainMenu.optionTooltip:SetText(text, texture, textureSize)
						mainMenu.optionTooltip:Show()
					else
						mainMenu.optionTooltip:Hide()
					end
				end    
			end,
			
			OnMouseOut = function(self)
				if mainMenu ~= nil then
					mainMenu.optionTooltip:Hide()
				end
			end,
			}

		label:AddEventCallbacks(tooltipCallbacks)
		
		if option.valueType == "color" then
			input:AddEventCallbacks(tooltipCallbacks)
		else
			for _, child in ipairs(input.children) do
				child:AddEventCallbacks(tooltipCallbacks)
			end
		end
		
		optionElements[option.name] = input
		optionElements[option.name].input_display = input_display
		optionElements[option.name].resetOption = resetOption
		optionElements[option.name].label = label
		
		y = y + rowHeight

	end
	
	form:SetCSSClass("options")
	form:SetHeight(y)

	return form

end

function GUIMainMenu:CreateColorPickerWindow()

	self.colorPickerWindow = self:CreateWindow()
	local colorPickerWindow = self.colorPickerWindow
	colorPickerWindow:SetInitialVisible(false)
	colorPickerWindow:SetIsVisible(false)
	colorPickerWindow:DisableResizeTile()
	colorPickerWindow:DisableSlideBar()
	colorPickerWindow:DisableContentBox()
	colorPickerWindow:SetCSSClass("colorpicker_window")
	colorPickerWindow:DisableCloseButton()
	colorPickerWindow:SetLayer(kGUILayerMainMenuDialogs)
	
	self.colorPickerMenuElement = nil
		
	self.colorPickerForm = CreateMenuElement(colorPickerWindow, "Form", false)
	self.colorPickerForm:SetCSSClass("colorpicker")
	
	local function CheckAndApply(self)
		local value = tonumber(self:GetValue())
		if value and IsNumber(value) then
			if tonumber(self:GetValue()) > 255 then
				self:SetValue("255")
			end
		elseif not value or value == "" then
			self:SetValue("0")
		end
		
		local r = tonumber(self.scriptHandle.colorPickerRedInput:GetValue()) or 0
		local g = tonumber(self.scriptHandle.colorPickerGreenInput:GetValue()) or 0
		local b = tonumber(self.scriptHandle.colorPickerBlueInput:GetValue()) or 0
		self.scriptHandle.colorPreview:SetBackgroundColor(Color(r/255, g/255, b/255))
	end
	
	local textInputCallbacks = {
		OnEnter = CheckAndApply,
		OnBlur = CheckAndApply
	}
	
	self.colorPickerRedInput = self.colorPickerForm:CreateFormElement(Form.kElementType.TextInput, "R", "")
	self.colorPickerRedInput:SetCSSClass("colorpicker_r")
	self.colorPickerRedInput:SetNumbersOnly(true)
	self.colorPickerRedInput:SetMaxLength(3)
	self.colorPickerRedInput:AddEventCallbacks(textInputCallbacks)
	self.colorPickerRedInput.text:SetScale(GetScaledVector())
	
	local text_r = CreateMenuElement(colorPickerWindow, "Font", false)
	text_r:SetCSSClass("passwordprompt_title")
	text_r:SetTopOffset(190)
	text_r:SetLeftOffset(42)
	text_r:SetText("R")
	text_r.text:SetScale(GetScaledVector())
	
	self.colorPickerGreenInput = self.colorPickerForm:CreateFormElement(Form.kElementType.TextInput, "G", "")
	self.colorPickerGreenInput:SetCSSClass("colorpicker_g")
	self.colorPickerGreenInput:SetNumbersOnly(true)
	self.colorPickerGreenInput:SetMaxLength(3)
	self.colorPickerGreenInput:AddEventCallbacks(textInputCallbacks)
	self.colorPickerGreenInput.text:SetScale(GetScaledVector())
	
	local text_g = CreateMenuElement(colorPickerWindow, "Font", false)
	text_g:SetCSSClass("passwordprompt_title")
	text_g:SetTopOffset(190)
	text_g:SetLeftOffset(132)
	text_g:SetText("G")
	text_g.text:SetScale(GetScaledVector())
	
	self.colorPickerBlueInput = self.colorPickerForm:CreateFormElement(Form.kElementType.TextInput, "B", "")
	self.colorPickerBlueInput:SetCSSClass("colorpicker_b")
	self.colorPickerBlueInput:SetNumbersOnly(true)
	self.colorPickerBlueInput:SetMaxLength(3)
	self.colorPickerBlueInput:AddEventCallbacks(textInputCallbacks)
	self.colorPickerBlueInput.text:SetScale(GetScaledVector())
	
	local text_b = CreateMenuElement(colorPickerWindow, "Font", false)
	text_b:SetCSSClass("passwordprompt_title")
	text_b:SetTopOffset(190)
	text_b:SetLeftOffset(222)
	text_b:SetText("B")
	text_b.text:SetScale(GetScaledVector())
	
	self.colorPickerWindowText = CreateMenuElement(colorPickerWindow, "Font", false)
	self.colorPickerWindowText:SetCSSClass("passwordprompt_title")
	self.colorPickerWindowText:SetTopOffset(3)
	self.colorPickerWindowText:SetText("COLOR PICKER")
	self.colorPickerWindowText.text:SetScale(GetScaledVector())
	
	self.colorPreview = self.colorPickerForm:CreateFormElement(Form.kElementType.FormButton, "COLORPREVIEW", "")
	self.colorPreview:SetTopOffset(130)
	self.colorPreview:SetLeftOffset(120)
	self.colorPreview:SetWidth(110)
	self.colorPreview:SetHeight(30)
	
	local okButton = CreateMenuElement(self.colorPickerWindow, "MenuButton")
	okButton:SetCSSClass("first_run_ok")
	okButton:SetText(Locale.ResolveString("MENU_APPLY"))
	okButton:SetTopOffset(240)
	okButton:AddEventCallbacks( {
		OnClick = function(self)
			local color = self.scriptHandle.colorPreview:GetBackground():GetColor()
			self.scriptHandle.colorPickerMenuElement:GetBackground():SetColor(color)
			self.scriptHandle.colorPickerWindow:SetIsVisible(false)
			local elemName = self.scriptHandle.colorPickerMenuElement:GetFormElementName()
			CHUDSaveMenuSetting(elemName)
			CHUDDisplayDefaultColorText(elemName)
		end
	})
	
	local colors = { }
	colors[1] = { 1, 1, 1 }
	colors[2] = { 0.5, 0, 0 }
	colors[3] = { 1, 0, 0 }
	colors[4] = { 1, 0.5, 0 }
	colors[5] = { 1, 1, 0 }
	colors[6] = { 0.5, 1, 0 }
	colors[7] = { 0, 1, 0 }
	colors[8] = { 0, 1, 0.5 }
	colors[9] = { 0, 1, 1 }
	colors[10] = { 0, 0, 1  }
	colors[11] = { 0, 0, 0.5 }
	colors[12] = { 1, 0, 1 }
	colors[13] = { 0.5, 0.5, 0.5 }
	colors[14] = { 0, 0, 0 }
	
	for i = 1, 14 do
		local tmpButton = self.colorPickerForm:CreateFormElement(Form.kElementType.FormButton, "COLORBUTTON" .. i, "")
		local row = math.floor((i-1) / 7)
		local currentX = i-((row)*7)
		
		tmpButton:SetTopOffset(40 + 40 * row)
		tmpButton:SetLeftOffset((30 + 10) * currentX)
		tmpButton:SetWidth(30)
		tmpButton:SetHeight(30)
		local color = Color(unpack(colors[i]))
		tmpButton:SetBackgroundColor(color)
		tmpButton:AddEventCallbacks({ OnClick = function(self)
			self.scriptHandle.colorPickerRedInput:SetValue(tostring(math.ceil(color.r*255)))
			self.scriptHandle.colorPickerGreenInput:SetValue(tostring(math.ceil(color.g*255)))
			self.scriptHandle.colorPickerBlueInput:SetValue(tostring(math.ceil(color.b*255)))
			self.scriptHandle.colorPreview:SetBackgroundColor(color)
			end})
	end

	colorPickerWindow:AddEventCallbacks({ 
		OnBlur = function(self) 
			self:SetIsVisible(false) 
		end,
	})
	
end