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
		elem.resetOption:SetIsVisible(elem:GetIsVisible() and CHUDOptions[key].defaultValue ~= CHUDOptions[key].currentValue)
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
	if mainMenu ~= nil and mainMenu.CHUDOptionsMenu ~= nil then
		for _, optionsTable in ipairs(mainMenu.CHUDOptionsMenu) do
			local y = 0
			for _, option in ipairs(optionsTable.options) do
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
			optionsTable.form:SetHeight(y)
			if optionsTable.form:GetIsVisible() then
				mainMenu.CHUDOptionWindow.slideBar:ScrollMax()
				mainMenu.CHUDOptionWindow.slideBar:ScrollMin()
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
			
			CHUDMenuOption.resetOption:SetIsVisible(CHUDMenuOption:GetIsVisible() and CHUDOption.defaultValue ~= CHUDOption.currentValue)
			
			if CHUDOption.children then
				local show = true
				for _, value in pairs(CHUDOption.hideValues) do
					if CHUDOption.currentValue == value then
						show = false
					end
				end
				
				-- Hide children options if the parent is also hidden
				if CHUDMenuOption:GetIsVisible() == false then
					show = false
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
			
			local playRoomOffset = MainMenu_IsInGame() and 0 or 1
			if menuLink:isa("BigLink") then
				playRoomOffset = 0
			end
			
			menuLink:SetTopOffset(50+70*(i-1 + playRoomOffset))
			
			-- Some links have glowing effects applied.  Ensure we move them upwards too.
			if menuLink.mainLinkGlow then
				menuLink.mainLinkGlow:SetTopOffset(40+70*(i-1 + playRoomOffset))
			end
			if menuLink.mainLinkAlertTextGlow then
				menuLink.mainLinkAlertTextGlow:SetTopOffset(40+70*(i-1 + playRoomOffset))
			end
			if menuLink.mainLinkAlertText then
				menuLink.mainLinkAlertText:SetTextPaddingTop(3)
			end
		end
		
		self.profileBackground:SetTopOffset(-70)
	end)
	
originalMainMenuResChange = Class_ReplaceMethod( "GUIMainMenu", "OnResolutionChanged",
	function(self, oldX, oldY, newX, newY)
		originalMainMenuResChange(self, oldX, oldY, newX, newY)
		for i, menuLink in pairs(self.Links) do
			menuLink:SetTopOffset(50+70*(i-1))
			
			-- Some links have glowing effects applied.  Ensure we move them upwards too.
			if menuLink.mainLinkGlow then
				menuLink.mainLinkGlow:SetTopOffset(40+70*(i-1))
			end
			if menuLink.mainLinkAlertTextGlow then
				menuLink.mainLinkAlertTextGlow:SetTopOffset(40+70*(i-1))
			end
			if menuLink.mainLinkAlertText then
				menuLink.mainLinkAlertText:SetTextPaddingTop(3)
			end
		end
		
		self.profileBackground:SetTopOffset(-70)
		
		if CHUDGetOption("mingui") then
			mainMenu.mainWindow:SetBackgroundTexture("ui/transparent.dds")
		else
			mainMenu.mainWindow:SetBackgroundTexture("ui/menu/grid.dds")
			mainMenu.mainWindow:SetBackgroundRepeat(true)
		end
		CHUDResortForm()
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
end

function MainMenu_OnCloseMenu()
	Shared.StopSound(nil, "sound/chud.fev/CHUD/open_menu")
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
	resetButton:SetCSSClass("chud_reset_all")
	resetButton:SetText("RESET NS2+ VALUES")
	resetButton:AddEventCallbacks(resetCallbacks)
	
	local changelogButton = CreateMenuElement( self.CHUDOptionWindow, "MenuButton" )
	changelogButton:SetCSSClass("chud_changelog")
	changelogButton:SetText("CHANGELOG")
	local kChangeURL = "http://steamcommunity.com/sharedfiles/filedetails/changelog/135458820"
	changelogButton:AddEventCallbacks( { OnClick = function() Client.ShowWebpage(kChangeURL) end } )
	
	self.warningLabel = CreateMenuElement(self.CHUDOptionWindow, "MenuButton", false)
	self.warningLabel:SetCSSClass("warning_label")
	self.warningLabel:SetText("Game restart required")
	self.warningLabel:SetIgnoreEvents(true)
	self.warningLabel:SetIsVisible(false)

	-- save our option elements for future reference
	self.CHUDOptionElements = {}
	
	local OptionsMenuTable = {}
	local categoryOrder = {
		ui = 1,
		hud = 2,
		damage = 3,
		minimap = 4,
		sound = 5,
		graphics = 6,
		stats = 7,
		misc = 8
	}
	
	for idx, option in pairs(CHUDOptions) do
		if not OptionsMenuTable[option.category] then
			OptionsMenuTable[option.category] = {}
		end
		table.insert(OptionsMenuTable[option.category], CHUDOptions[idx])
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
	
	self.CHUDOptionsMenu = {}
	for name, category in pairs(OptionsMenuTable) do
		table.sort(category, CHUDOptionsSort)
		table.insert(self.CHUDOptionsMenu, {
			label = string.upper(name),
			form = GUIMainMenu.CreateCHUDOptionsForm(self, content, OptionsMenuTable[name], self.CHUDOptionElements),
			scroll = true,
			options = OptionsMenuTable[name],
			sort = categoryOrder[name],
		})
	end
	
	table.sort(self.CHUDOptionsMenu, CHUDOptionsSort)
	
	local tabBackground = CreateMenuElement(self.CHUDOptionWindow, "Image")
	tabBackground:SetCSSClass("tab_background_chudmenu")
	tabBackground:SetIgnoreEvents(true)
	
	local tabAnimateTime = 0.1
		
	for i = 1,#self.CHUDOptionsMenu do
	
		local tab = self.CHUDOptionsMenu[i]
		local tabButton = CreateMenuElement(self.CHUDOptionWindow, "MenuButton")
		
		local function ShowTab()
			for j =1,#self.CHUDOptionsMenu do
				self.CHUDOptionsMenu[j].form:SetIsVisible(i == j)
				self.CHUDOptionWindow:ResetSlideBar()
				self.CHUDOptionWindow:SetSlideBarVisible(tab.scroll == true)
				local tabPosition = tabButton.background:GetPosition()
				tabBackground:SetBackgroundPosition( tabPosition, false, tabAnimateTime ) 
			end
		end
	
		tabButton:SetCSSClass("tab_chudmenu")
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
	text_r:SetCSSClass("colorlabel_r_chud")
	text_r:SetText("R")
	
	self.colorPickerGreenInput = self.colorPickerForm:CreateFormElement(Form.kElementType.TextInput, "G", "")
	self.colorPickerGreenInput:SetCSSClass("colorpicker_g")
	self.colorPickerGreenInput:SetNumbersOnly(true)
	self.colorPickerGreenInput:SetMaxLength(3)
	self.colorPickerGreenInput:AddEventCallbacks(textInputCallbacks)
	self.colorPickerGreenInput.text:SetScale(GetScaledVector())
	
	local text_g = CreateMenuElement(colorPickerWindow, "Font", false)
	text_g:SetCSSClass("colorlabel_g_chud")
	text_g:SetText("G")
	
	self.colorPickerBlueInput = self.colorPickerForm:CreateFormElement(Form.kElementType.TextInput, "B", "")
	self.colorPickerBlueInput:SetCSSClass("colorpicker_b")
	self.colorPickerBlueInput:SetNumbersOnly(true)
	self.colorPickerBlueInput:SetMaxLength(3)
	self.colorPickerBlueInput:AddEventCallbacks(textInputCallbacks)
	self.colorPickerBlueInput.text:SetScale(GetScaledVector())
	
	local text_b = CreateMenuElement(colorPickerWindow, "Font", false)
	text_b:SetCSSClass("colorlabel_b_chud")
	text_b:SetText("B")
	
	self.colorPickerWindowText = CreateMenuElement(colorPickerWindow, "Font", false)
	self.colorPickerWindowText:SetCSSClass("colorpicker_chud")
	self.colorPickerWindowText:SetText("COLOR PICKER")
	
	self.colorPreview = self.colorPickerForm:CreateFormElement(Form.kElementType.FormButton, "COLORPREVIEW", "")
	self.colorPreview:SetTopOffset(130)
	self.colorPreview:SetLeftOffset(120)
	self.colorPreview:SetWidth(110)
	self.colorPreview:SetHeight(30)
	
	local okButton = CreateMenuElement(self.colorPickerWindow, "MenuButton")
	okButton:SetCSSClass("apply_color_chud")
	okButton:SetText(Locale.ResolveString("MENU_APPLY"))
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