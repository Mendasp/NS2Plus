// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIAlienBuyMenu.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages the alien buy/evolve menu.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIParticleSystem.lua")
Script.Load("lua/tweener/Tweener.lua")

class 'GUIAlienBuyMenu' (GUIScript)

GUIAlienBuyMenu.kBuyMenuTexture = PrecacheAsset("ui/alien_buymenu.dds")
GUIAlienBuyMenu.kBuyMenuMaskTexture = PrecacheAsset("ui/alien_buymenu_mask.dds")
GUIAlienBuyMenu.kBuyHUDTexture = "ui/buildmenu.dds"
GUIAlienBuyMenu.kSlotTexture = PrecacheAsset("ui/alien_buyslot.dds")
GUIAlienBuyMenu.kSlotLockedTexture = PrecacheAsset("ui/alien_buyslot_locked.dds")
GUIAlienBuyMenu.kAbilityIcons = "ui/buildmenu.dds"

local kLargeFont = Fonts.kAgencyFB_Large
local kFont = Fonts.kAgencyFB_Small

GUIAlienBuyMenu.kAlienTypes = { { Name = Locale.ResolveString("FADE"), TextureName = "Fade", Width = GUIScale(188), Height = GUIScale(220), XPos = 4, Index = 1 },
                                { Name = Locale.ResolveString("GORGE"), TextureName = "Gorge", Width = GUIScale(200), Height = GUIScale(167), XPos = 2, Index = 2 },
                                { Name = Locale.ResolveString("LERK"), TextureName = "Lerk", Width = GUIScale(284), Height = GUIScale(253), XPos = 3, Index = 3 },
                                { Name = Locale.ResolveString("ONOS"), TextureName = "Onos", Width = GUIScale(304), Height = GUIScale(326), XPos = 5, Index = 4 },
                                { Name = Locale.ResolveString("SKULK"), TextureName = "Skulk", Width = GUIScale(240), Height = GUIScale(170), XPos = 1, Index = 5 } }

GUIAlienBuyMenu.kBackgroundTextureCoordinates = { 9, 1, 602, 424 }
GUIAlienBuyMenu.kBackgroundWidth = GUIScale((GUIAlienBuyMenu.kBackgroundTextureCoordinates[3] - GUIAlienBuyMenu.kBackgroundTextureCoordinates[1]) * 0.80)
GUIAlienBuyMenu.kBackgroundHeight = GUIScale((GUIAlienBuyMenu.kBackgroundTextureCoordinates[4] - GUIAlienBuyMenu.kBackgroundTextureCoordinates[2]) * 0.80)
// We want the background graphic to look centered around the circle even though there is the part coming off to the right.
GUIAlienBuyMenu.kBackgroundXOffset = GUIScale(75)

GUIAlienBuyMenu.kAlienButtonSize = GUIScale(150)
GUIAlienBuyMenu.kPlayersTextSize = GUIScale(24)
GUIAlienBuyMenu.kAlienSelectedButtonSize = GUIAlienBuyMenu.kAlienButtonSize * 2
GUIAlienBuyMenu.kAlienSelectedBackground = PrecacheAsset("ui/AlienBackground.dds")
GUIAlienBuyMenu.kResearchTextSize = GUIScale(24)

GUIAlienBuyMenu.kEvolveButtonWidth = GUIScale(250)
GUIAlienBuyMenu.kEvolveButtonHeight = GUIScale(80)
GUIAlienBuyMenu.kEvolveButtonYOffset = GUIScale(20)
GUIAlienBuyMenu.kEvolveButtonTextSize = GUIScale(22)
GUIAlienBuyMenu.kEvolveButtonNeedResourcesTextureCoordinates = { 87, 429, 396, 511 }
GUIAlienBuyMenu.kEvolveButtonTextureCoordinates = { 396, 428, 706, 511 }
GUIAlienBuyMenu.kEvolveButtonVeinsTextureCoordinates = { 600, 350, 915, 419 }
local kVeinsMargin = GUIScale(4)

GUIAlienBuyMenu.kResourceIconTexture = PrecacheAsset("ui/pres_icon_big.dds")

GUIAlienBuyMenu.kHighLightTexPixelCoords = { 560, 960, 640, 1040 }

GUIAlienBuyMenu.kSlotDistance = GUIScale(120)
GUIAlienBuyMenu.kSlotSize = GUIScale(54)

GUIAlienBuyMenu.kCurrentAlienSize = GUIScale(200)
GUIAlienBuyMenu.kCurrentAlienTitleTextSize = GUIScale(32)
GUIAlienBuyMenu.kCurrentAlienTitleOffset = Vector(0, GUIScale(25), 0)

GUIAlienBuyMenu.kResourceDisplayBackgroundTextureCoordinates = { 711, 295, 824, 346 }
GUIAlienBuyMenu.kResourceDisplayWidth = GUIScale((GUIAlienBuyMenu.kResourceDisplayBackgroundTextureCoordinates[3] - GUIAlienBuyMenu.kResourceDisplayBackgroundTextureCoordinates[1]) * 1.2)
GUIAlienBuyMenu.kResourceDisplayHeight = GUIScale((GUIAlienBuyMenu.kResourceDisplayBackgroundTextureCoordinates[4] - GUIAlienBuyMenu.kResourceDisplayBackgroundTextureCoordinates[2]) * 1.2)
GUIAlienBuyMenu.kResourceFontSize = GUIScale(24)
GUIAlienBuyMenu.kResourceTextYOffset = GUIScale(200)

GUIAlienBuyMenu.kResourceIconWidth = GUIScale(33)
GUIAlienBuyMenu.kResourceIconHeight = GUIScale(33)

GUIAlienBuyMenu.kHealthIconTextureCoordinates = { 854, 318, 887, 351 }
GUIAlienBuyMenu.kHealthIconWidth = GUIScale(GUIAlienBuyMenu.kHealthIconTextureCoordinates[3] - GUIAlienBuyMenu.kHealthIconTextureCoordinates[1])
GUIAlienBuyMenu.kHealthIconHeight = GUIScale(GUIAlienBuyMenu.kHealthIconTextureCoordinates[4] - GUIAlienBuyMenu.kHealthIconTextureCoordinates[2])

GUIAlienBuyMenu.kArmorIconTextureCoordinates = { 887, 318, 920, 351 }
GUIAlienBuyMenu.kArmorIconWidth = GUIScale(GUIAlienBuyMenu.kArmorIconTextureCoordinates[3] - GUIAlienBuyMenu.kArmorIconTextureCoordinates[1])
GUIAlienBuyMenu.kArmorIconHeight = GUIScale(GUIAlienBuyMenu.kArmorIconTextureCoordinates[4] - GUIAlienBuyMenu.kArmorIconTextureCoordinates[2])

GUIAlienBuyMenu.kMouseOverTitleOffset = Vector(GUIScale(-25), GUIScale(-100), 0)

GUIAlienBuyMenu.kMouseOverInfoTextSize = GUIScale(20)
GUIAlienBuyMenu.kMouseOverInfoOffset = Vector(GUIScale(-25), GUIScale(-10), 0)

GUIAlienBuyMenu.kDisabledColor = Color(0.5, 0.5, 0.5, 0.5)
GUIAlienBuyMenu.kCannotBuyColor = Color(1, 0, 0, 0.5)
GUIAlienBuyMenu.kEnabledColor = Color(1, 1, 1, 1)

local kTooltipTextWidth = GUIScale(300)

GUIAlienBuyMenu.kMaxNumberOfUpgradeButtons = 8
GUIAlienBuyMenu.kUpgradeButtonSize = GUIScale(54)
GUIAlienBuyMenu.kUpgradeButtonDistance = GUIScale(198)
// The distance in pixels to move the button inside the embryo when selected.
GUIAlienBuyMenu.kUpgradeButtonDistanceInside = GUIScale(74)
GUIAlienBuyMenu.kUpgradeButtonTextureSize = 80
GUIAlienBuyMenu.kUpgradeButtonBackgroundTextureCoordinates = { 15, 434, 85, 505 }
GUIAlienBuyMenu.kUpgradeButtonMoveTime = 0.5

GUIAlienBuyMenu.kCloseButtonSize = GUIScale(48)
GUIAlienBuyMenu.kCloseButtonTextureCoordinates = { 612, 300, 660, 342 }
GUIAlienBuyMenu.kCloseButtonRollOverTextureCoordinates = { 664, 300, 712, 342 }

GUIAlienBuyMenu.kGlowieBigTextureCoordinates = { 860, 294, 888, 315 }
GUIAlienBuyMenu.kGlowieSmallTextureCoordinates = { 890, 294, 905, 314 }

GUIAlienBuyMenu.kSmokeBigTextureCoordinates = { { 620, 1, 759, 146 }, { 765, 1, 905, 146 }, { 624, 150, 763, 293 }, { 773, 152, 912, 297 } }
GUIAlienBuyMenu.kSmokeSmallTextureCoordinates = { { 916, 4, 1020, 108 }, { 916, 15, 1020, 219 }, { 916, 227, 1020, 332 }, { 916, 332, 1020, 436 } }

GUIAlienBuyMenu.kCornerPulseTime = 4
GUIAlienBuyMenu.kCornerTextureCoordinates = { TopLeft = { 605, 1, 765, 145 },  BottomLeft = { 605, 145, 765, 290 }, TopRight = { 765, 1, 910, 145 }, BottomRight = { 765, 145, 910, 290 } }
GUIAlienBuyMenu.kCornerWidths = { }
GUIAlienBuyMenu.kCornerHeights = { }
for location, texCoords in pairs(GUIAlienBuyMenu.kCornerTextureCoordinates) do
    GUIAlienBuyMenu.kCornerWidths[location] = GUIScale(texCoords[3] - texCoords[1])
    GUIAlienBuyMenu.kCornerHeights[location] = GUIScale(texCoords[4] - texCoords[2])
end

local kUpgradeButtonMinSizeScalar = 0.75
local kUpgradeButtonMaxSizeScalar = 1

function GUIAlienBuyMenu:Initialize()

    self.numSelectedUpgrades = 0

    self.mouseOverStates = {}
    
    self.upgradeList = {}
    
    self.upgradeTweeners = {}
    
    self.abilityIcons = {}
    
    self:_InitializeBackground()
    self:_InitializeSmokeParticles()
    self:_InitializeBackgroundCircle()    
    self:_InitializeSlots()
    self:_InitializeUpgradeButtons()
    // _InitializeMouseOverInfo() must be called before _InitializeAlienButtons().
    self:_InitializeMouseOverInfo()
    self:_InitializeAlienButtons()
    self:_InitializeCurrentAlienDisplay()
    self:_InitializeEvolveButton()
    self:_InitializeCloseButton()
    self:_InitializeGlowieParticles()
    self:_InitializeCorners()
    
    AlienBuy_OnOpen()
   
    
end

function GUIAlienBuyMenu:Uninitialize()

    self:_UninitializeBackground()
    self:_UninitializeSmokeParticles()
    self:_UninitializeBackgroundCircle()    
    //self:_UninitializeResourceDisplay()
    self:_UninitializeUpgradeButtons()
    self:_UninitializeMouseOverInfo()
    self:_UninitializeAlienButtons()
    self:_UninitializeCurrentAlienDisplay()
    self:_UninitializeEvolveButton()
    self:_UninitializeCloseButton()
    self:_UninitializeGlowieParticles()
    self:_UninitializeCorners()

end

local function CreateSlot(self, category)

    local graphic = GUIManager:CreateGraphicItem()
    graphic:SetSize(Vector(GUIAlienBuyMenu.kSlotSize, GUIAlienBuyMenu.kSlotSize, 0))
    graphic:SetTexture(GUIAlienBuyMenu.kSlotTexture)
    graphic:SetLayer(kGUILayerPlayerHUDForeground3)
    graphic:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:AddChild(graphic)
    
    table.insert(self.slots, { Graphic = graphic, Category = category } )


end

function GUIAlienBuyMenu:_InitializeSlots()

    self.slots = {}
    
    CreateSlot(self, kTechId.CragHive)
    CreateSlot(self, kTechId.ShadeHive)
    CreateSlot(self, kTechId.ShiftHive)
    
    local anglePerSlot = (math.pi * 0.6) / (#self.slots-1)
    
    for i = 1, #self.slots do
    
        local angle = (i-1) * anglePerSlot + math.pi * 0.2
        local distance = GUIAlienBuyMenu.kSlotDistance
        
        self.slots[i].Graphic:SetPosition( Vector( math.cos(angle) * distance - GUIAlienBuyMenu.kSlotSize * .5, math.sin(angle) * distance - GUIAlienBuyMenu.kSlotSize * .5, 0) )
        self.slots[i].Angle = angle
    
    end
    

end

function GUIAlienBuyMenu:GetOffsetAngleForCategory(category)

    for i = 1, #self.slots do
    
        if self.slots[i].Category == category then
            return self.slots[i].Angle
        end
        
    end

end

function GUIAlienBuyMenu:_InitializeBackground()

    // This invisible background is used for centering only.
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(GUIAlienBuyMenu.kBackgroundWidth, GUIAlienBuyMenu.kBackgroundHeight, 0))
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetPosition(Vector(-GUIAlienBuyMenu.kBackgroundWidth / 2, -GUIAlienBuyMenu.kBackgroundHeight / 2, 0))
    self.background:SetColor(Color(0, 0, 0, 0))
    self.background:SetLayer(kGUILayerPlayerHUD)
    
end

function GUIAlienBuyMenu:_UninitializeBackground()
    
    GUI.DestroyItem(self.background)
    self.background = nil
    
end

function GUIAlienBuyMenu:_InitializeBackgroundCircle()

    
    self.backgroundCircle = GUIManager:CreateGraphicItem()
    self.backgroundCircle:SetSize(Vector(GUIAlienBuyMenu.kBackgroundWidth, GUIAlienBuyMenu.kBackgroundHeight, 0))
    self.backgroundCircle:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.backgroundCircle:SetPosition(Vector((-GUIAlienBuyMenu.kBackgroundWidth / 2) + GUIAlienBuyMenu.kBackgroundXOffset, -GUIAlienBuyMenu.kBackgroundHeight / 2, 0))
    self.backgroundCircle:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    self.backgroundCircle:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kBackgroundTextureCoordinates))
    self.backgroundCircle:SetShader("shaders/GUIWavy.surface_shader")
    self.backgroundCircle:SetAdditionalTexture("wavyMask", GUIAlienBuyMenu.kBuyMenuMaskTexture)
    self.background:AddChild(self.backgroundCircle)
    
    self.backgroundCircleStencil = GUIManager:CreateGraphicItem()
    self.backgroundCircleStencil:SetIsStencil(true)
    // This never moves and we want it to draw the stencil for the upgrade buttons.
    self.backgroundCircleStencil:SetClearsStencilBuffer(false)
    self.backgroundCircleStencil:SetSize(Vector(GUIAlienBuyMenu.kBackgroundWidth, GUIAlienBuyMenu.kBackgroundHeight, 0))
    self.backgroundCircleStencil:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.backgroundCircleStencil:SetPosition(Vector((-GUIAlienBuyMenu.kBackgroundWidth / 2) + GUIAlienBuyMenu.kBackgroundXOffset, -GUIAlienBuyMenu.kBackgroundHeight / 2, 0))
    self.backgroundCircleStencil:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    self.backgroundCircleStencil:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kBackgroundTextureCoordinates))
    self.background:AddChild(self.backgroundCircleStencil)

end

function GUIAlienBuyMenu:_UninitializeBackgroundCircle()

    GUI.DestroyItem(self.backgroundCircleStencil)
    self.backgroundCircleStencil = nil
    
    GUI.DestroyItem(self.backgroundCircle)
    self.backgroundCircle = nil

end

local function CreateAbilityIcon(self, alienGraphicItem, techId)

    local graphicItem = GetGUIManager():CreateGraphicItem()
    graphicItem:SetTexture(GUIAlienBuyMenu.kAbilityIcons)
    graphicItem:SetSize(Vector(GUIAlienBuyMenu.kUpgradeButtonSize, GUIAlienBuyMenu.kUpgradeButtonSize, 0))
    graphicItem:SetAnchor(GUIItem.Right, GUIItem.Top)
    graphicItem:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(techId, false)))
    graphicItem:SetColor(kIconColors[kAlienTeamType])
    
    local highLight = GetGUIManager():CreateGraphicItem()
    highLight:SetSize(Vector(GUIAlienBuyMenu.kUpgradeButtonSize, GUIAlienBuyMenu.kUpgradeButtonSize, 0))
    highLight:SetIsVisible(false)
    highLight:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    highLight:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kUpgradeButtonBackgroundTextureCoordinates))
    
    graphicItem:AddChild(highLight)    
    alienGraphicItem:AddChild(graphicItem)
    
    return { Icon = graphicItem, TechId = techId, HighLight = highLight }

end

local function CreateAbilityIcons(self, alienGraphicItem, alienType)

    local lifeFormTechId = IndexToAlienTechId(alienType.Index)
    local availableAbilities = GetTechForCategory(lifeFormTechId)

    local numAbilities = #availableAbilities
    
    for i = 1, numAbilities do
    
        local techId = availableAbilities[#availableAbilities - i + 1]
        local ability = CreateAbilityIcon(self, alienGraphicItem, techId)
        local xPos = ((i-1) % 3 + 1) * -GUIAlienBuyMenu.kUpgradeButtonSize
        local yPos = (math.ceil(i/3)) * -GUIAlienBuyMenu.kUpgradeButtonSize
        
        ability.Icon:SetPosition(Vector(xPos, yPos, 0))    
        table.insert(self.abilityIcons, ability)
    
    end

end

function GUIAlienBuyMenu:_InitializeAlienButtons()

    self.alienButtons = { }

    for k, alienType in ipairs(GUIAlienBuyMenu.kAlienTypes) do
    
        // The alien image.
        local alienGraphicItem = GUIManager:CreateGraphicItem()
        local ARAdjustedHeight = (alienType.Height / alienType.Width) * GUIAlienBuyMenu.kAlienButtonSize
        alienGraphicItem:SetSize(Vector(GUIAlienBuyMenu.kAlienButtonSize, ARAdjustedHeight, 0))
        alienGraphicItem:SetAnchor(GUIItem.Middle, GUIItem.Center)
        alienGraphicItem:SetPosition(Vector(-GUIAlienBuyMenu.kAlienButtonSize / 2, -ARAdjustedHeight / 2, 0))
        alienGraphicItem:SetTexture("ui/" .. alienType.Name .. ".dds")
        alienGraphicItem:SetIsVisible(AlienBuy_IsAlienResearched(alienType.Index))
        
        // Create the text that indicates how many players are playing as a specific alien type.
        local playersText = GUIManager:CreateTextItem()
        playersText:SetAnchor(GUIItem.Right, GUIItem.Bottom)
        playersText:SetFontName(kFont)
        playersText:SetTextAlignmentX(GUIItem.Align_Max)
        playersText:SetTextAlignmentY(GUIItem.Align_Min)
        playersText:SetText("x" .. ToString(ScoreboardUI_GetNumberOfAliensByType(alienType.Name)))
        playersText:SetColor(ColorIntToColor(kAlienTeamColor))
        playersText:SetPosition(Vector(0, -GUIAlienBuyMenu.kPlayersTextSize, 0))
        alienGraphicItem:AddChild(playersText)
        
        // Create the text that indicates the research progress.
        local researchText = GUIManager:CreateTextItem()
        researchText:SetAnchor(GUIItem.Middle, GUIItem.Center)
        researchText:SetFontName(kFont)
        researchText:SetTextAlignmentX(GUIItem.Align_Center)
        researchText:SetTextAlignmentY(GUIItem.Align_Center)
        researchText:SetColor(ColorIntToColor(kAlienTeamColor))
        alienGraphicItem:AddChild(researchText)
        
        // Create the selected background item for this alien item.
        local selectedBackground = GUIManager:CreateGraphicItem()
        selectedBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
        selectedBackground:SetSize(Vector(GUIAlienBuyMenu.kAlienSelectedButtonSize, GUIAlienBuyMenu.kAlienSelectedButtonSize, 0))
        selectedBackground:SetTexture(GUIAlienBuyMenu.kAlienSelectedBackground)
        // Hide the selected background for now.
        selectedBackground:SetColor(Color(1, 1, 1, 0))
        selectedBackground:AddChild(alienGraphicItem)
        
        table.insert(self.alienButtons, { TypeData = alienType, Button = alienGraphicItem, SelectedBackground = selectedBackground, PlayersText = playersText, ResearchText = researchText, ARAdjustedHeight = ARAdjustedHeight })
        
        CreateAbilityIcons(self, alienGraphicItem, alienType)

        self.background:AddChild(selectedBackground)
        
    end
    
    self:_UpdateAlienButtons()

end

function GUIAlienBuyMenu:_UninitializeAlienButtons()

    for i, button in ipairs(self.alienButtons) do
        GUI.DestroyItem(button.PlayersText)
        GUI.DestroyItem(button.Button)
        GUI.DestroyItem(button.SelectedBackground)
    end
    self.alienButtons = nil
    
    GUI.DestroyItem(self.mouseOverAlienBackground)
    self.mouseOverAlienBackground = nil
    
end

function GUIAlienBuyMenu:_InitializeCurrentAlienDisplay()

    self.currentAlienDisplay = { }
    
    self.currentAlienDisplay.Icon = GUIManager:CreateGraphicItem()
    self.currentAlienDisplay.Icon:SetAnchor(GUIItem.Middle, GUIItem.Center)
    local width = GUIAlienBuyMenu.kAlienTypes[AlienBuy_GetCurrentAlien()].Width
    local height = GUIAlienBuyMenu.kAlienTypes[AlienBuy_GetCurrentAlien()].Height
    self.currentAlienDisplay.Icon:SetSize(Vector(width, height, 0))
    self.currentAlienDisplay.Icon:SetPosition(Vector((-width / 2), -height / 2, 0))
    self.currentAlienDisplay.Icon:SetTexture("ui/" .. GUIAlienBuyMenu.kAlienTypes[AlienBuy_GetCurrentAlien()].TextureName .. ".dds")
    self.currentAlienDisplay.Icon:SetLayer(kGUILayerPlayerHUDForeground2)
    self.background:AddChild(self.currentAlienDisplay.Icon)
    
    self.currentAlienDisplay.TitleShadow = GUIManager:CreateTextItem()
    self.currentAlienDisplay.TitleShadow:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.currentAlienDisplay.TitleShadow:SetPosition(GUIAlienBuyMenu.kCurrentAlienTitleOffset)
    self.currentAlienDisplay.TitleShadow:SetFontName(kLargeFont)
    self.currentAlienDisplay.TitleShadow:SetTextAlignmentX(GUIItem.Align_Center)
    self.currentAlienDisplay.TitleShadow:SetTextAlignmentY(GUIItem.Align_Min)
    self.currentAlienDisplay.TitleShadow:SetText(GUIAlienBuyMenu.kAlienTypes[AlienBuy_GetCurrentAlien()].Name)
    self.currentAlienDisplay.TitleShadow:SetColor(Color(0, 0, 0, 1))
    self.currentAlienDisplay.TitleShadow:SetLayer(kGUILayerPlayerHUDForeground3)
    self.background:AddChild(self.currentAlienDisplay.TitleShadow)
    
    self.currentAlienDisplay.Title = GUIManager:CreateTextItem()
    self.currentAlienDisplay.Title:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.currentAlienDisplay.Title:SetPosition(Vector(-2, -2, 0))
    self.currentAlienDisplay.Title:SetFontName(kLargeFont)
    self.currentAlienDisplay.Title:SetTextAlignmentX(GUIItem.Align_Center)
    self.currentAlienDisplay.Title:SetTextAlignmentY(GUIItem.Align_Min)
    self.currentAlienDisplay.Title:SetText(GUIAlienBuyMenu.kAlienTypes[AlienBuy_GetCurrentAlien()].Name)
    self.currentAlienDisplay.Title:SetColor(ColorIntToColor(kAlienTeamColor))
    self.currentAlienDisplay.Title:SetLayer(kGUILayerPlayerHUDForeground3)
    self.currentAlienDisplay.TitleShadow:AddChild(self.currentAlienDisplay.Title)

end

function GUIAlienBuyMenu:_UninitializeCurrentAlienDisplay()

    GUI.DestroyItem(self.currentAlienDisplay.Title)
    GUI.DestroyItem(self.currentAlienDisplay.TitleShadow)
    GUI.DestroyItem(self.currentAlienDisplay.Icon)
    self.currentAlienDisplay = nil
    
end

function GUIAlienBuyMenu:_InitializeMouseOverInfo()

    self.mouseOverTitle = GUIManager:CreateTextItem()
    self.mouseOverTitle:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.mouseOverTitle:SetPosition(GUIAlienBuyMenu.kMouseOverTitleOffset)
    self.mouseOverTitle:SetFontName(kLargeFont)
    self.mouseOverTitle:SetTextAlignmentX(GUIItem.Align_Min)
    self.mouseOverTitle:SetTextAlignmentY(GUIItem.Align_Min)
    self.mouseOverTitle:SetText(GUIAlienBuyMenu.kAlienTypes[AlienBuy_GetCurrentAlien()].Name)
    self.mouseOverTitle:SetColor(ColorIntToColor(kAlienTeamColor))
    self.mouseOverTitle:SetIsVisible(false)
    self.background:AddChild(self.mouseOverTitle)

    self.mouseOverInfo = GUIManager:CreateTextItem()
    self.mouseOverInfo:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.mouseOverInfo:SetPosition(GUIAlienBuyMenu.kMouseOverInfoOffset)
    self.mouseOverInfo:SetFontName(kFont)
    
    self.mouseOverInfo:SetTextAlignmentX(GUIItem.Align_Min)
    self.mouseOverInfo:SetTextAlignmentY(GUIItem.Align_Min)
    self.mouseOverInfo:SetColor(ColorIntToColor(kAlienTeamColor))
    // Only visible on mouse over.
    self.mouseOverInfo:SetIsVisible(false)
    self.background:AddChild(self.mouseOverInfo)
    
    self.mouseOverInfoResIcon = GUIManager:CreateGraphicItem()
    self.mouseOverInfoResIcon:SetSize(Vector(GUIAlienBuyMenu.kResourceIconWidth, GUIAlienBuyMenu.kResourceIconHeight, 0))
    // Anchor to parent's left so we can hard-code "float" distance
    self.mouseOverInfoResIcon:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.mouseOverInfoResIcon:SetPosition(Vector(GUIScale(-34), GUIScale(120), 0))
    self.mouseOverInfoResIcon:SetTexture(GUIAlienBuyMenu.kResourceIconTexture)
    self.mouseOverInfoResIcon:SetColor(kIconColors[kAlienTeamType])
    self.mouseOverInfoResIcon:SetIsVisible(false)
    self.background:AddChild(self.mouseOverInfoResIcon)
    
    local kStatsPadding = Vector(GUIScale(5), 0, 0)    
    self.mouseOverInfoResAmount = GUIManager:CreateTextItem()
    self.mouseOverInfoResAmount:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.mouseOverInfoResAmount:SetFontName(kFont)
    self.mouseOverInfoResAmount:SetTextAlignmentX(GUIItem.Align_Min)
    self.mouseOverInfoResAmount:SetTextAlignmentY(GUIItem.Align_Min)
    self.mouseOverInfoResAmount:SetPosition(kStatsPadding)
    self.mouseOverInfoResAmount:SetColor(ColorIntToColor(kAlienTeamColor))
    self.mouseOverInfoResIcon:AddChild(self.mouseOverInfoResAmount)
    
    // Create health and armor icons and text
    self.mouseOverInfoHealthIcon = GUIManager:CreateGraphicItem()
    self.mouseOverInfoHealthIcon:SetSize(Vector(GUIAlienBuyMenu.kResourceIconWidth, GUIAlienBuyMenu.kResourceIconHeight, 0))
    self.mouseOverInfoHealthIcon:SetAnchor(GUIItem.Right, GUIItem.Top)
    
    self.mouseOverInfoHealthIcon:SetPosition(kStatsPadding)
    self.mouseOverInfoHealthIcon:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    self.mouseOverInfoHealthIcon:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kHealthIconTextureCoordinates))
    self.mouseOverInfoHealthIcon:SetIsVisible(false)
    self.mouseOverInfoResAmount:AddChild(self.mouseOverInfoHealthIcon)

    self.mouseOverInfoHealthAmount = GUIManager:CreateTextItem()
    self.mouseOverInfoHealthAmount:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.mouseOverInfoHealthAmount:SetFontName(kFont)
    self.mouseOverInfoHealthAmount:SetTextAlignmentX(GUIItem.Align_Min)
    self.mouseOverInfoHealthAmount:SetTextAlignmentY(GUIItem.Align_Min)
    self.mouseOverInfoHealthAmount:SetPosition(kStatsPadding)
    self.mouseOverInfoHealthAmount:SetColor(ColorIntToColor(kAlienTeamColor))
    self.mouseOverInfoHealthIcon:AddChild(self.mouseOverInfoHealthAmount)

    self.mouseOverInfoArmorIcon = GUIManager:CreateGraphicItem()
    self.mouseOverInfoArmorIcon:SetSize(Vector(GUIAlienBuyMenu.kResourceIconWidth, GUIAlienBuyMenu.kResourceIconHeight, 0))
    self.mouseOverInfoArmorIcon:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.mouseOverInfoArmorIcon:SetPosition(kStatsPadding)
    self.mouseOverInfoArmorIcon:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    self.mouseOverInfoArmorIcon:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kArmorIconTextureCoordinates))
    self.mouseOverInfoArmorIcon:SetIsVisible(false)
    self.mouseOverInfoHealthAmount:AddChild(self.mouseOverInfoArmorIcon)

    self.mouseOverInfoArmorAmount = GUIManager:CreateTextItem()
    self.mouseOverInfoArmorAmount:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.mouseOverInfoArmorAmount:SetFontName(kFont)
    self.mouseOverInfoArmorAmount:SetTextAlignmentX(GUIItem.Align_Min)
    self.mouseOverInfoArmorAmount:SetTextAlignmentY(GUIItem.Align_Min)
    self.mouseOverInfoArmorAmount:SetPosition(kStatsPadding)
    self.mouseOverInfoArmorAmount:SetColor(ColorIntToColor(kAlienTeamColor))
    self.mouseOverInfoArmorIcon:AddChild(self.mouseOverInfoArmorAmount)

end

function GUIAlienBuyMenu:_UninitializeMouseOverInfo()

    GUI.DestroyItem(self.mouseOverInfoResIcon)
    self.mouseOverInfoResIcon = nil

    GUI.DestroyItem(self.mouseOverInfoResAmount)
    self.mouseOverInfoResAmount = nil
    
    GUI.DestroyItem(self.mouseOverInfoHealthIcon)
    self.mouseOverInfoHealthIcon = nil

    GUI.DestroyItem(self.mouseOverInfoHealthAmount)
    self.mouseOverInfoHealthAmount = nil

    GUI.DestroyItem(self.mouseOverInfoArmorIcon)
    self.mouseOverInfoArmorIcon = nil

    GUI.DestroyItem(self.mouseOverInfoArmorAmount)
    self.mouseOverInfoArmorAmount = nil
    
    GUI.DestroyItem(self.mouseOverInfo)
    self.mouseOverInfo = nil

    GUI.DestroyItem(self.mouseOverTitle)
    self.mouseOverTitle = nil

end

local function GetHasAnyCathegoryUpgrade(cathegory)

    local upgrades = AlienUI_GetUpgradesForCategory(cathegory)

    for i = 1, #upgrades do
        if AlienBuy_GetTechAvailable(upgrades[i]) then
            return true
        end        
    end
    
    return false

end

function GUIAlienBuyMenu:_InitializeUpgradeButtons()

    // There are purchased and unpurchased buttons. Both are managed in this list.
    self.upgradeButtons = { }
    
    local upgrades = AlienUI_GetPersonalUpgrades()
    
    for i = 1, #self.slots do
    
        local upgrades = AlienUI_GetUpgradesForCategory(self.slots[i].Category)
        local offsetAngle = self.slots[i].Angle
        local anglePerUpgrade = math.pi * 0.25 / 3
        local category = self.slots[i].Category
        
        for upgradeIndex = 1, #upgrades do
        
            local angle = offsetAngle + anglePerUpgrade * (upgradeIndex-1) - anglePerUpgrade
            local techId = upgrades[upgradeIndex]
            
            // Every upgrade has an icon.
            local buttonIcon = GUIManager:CreateGraphicItem()
            buttonIcon:SetAnchor(GUIItem.Middle, GUIItem.Center)
            buttonIcon:SetSize(Vector(GUIAlienBuyMenu.kUpgradeButtonSize, GUIAlienBuyMenu.kUpgradeButtonSize, 0))
            buttonIcon:SetPosition(Vector(-GUIAlienBuyMenu.kUpgradeButtonSize / 2, GUIAlienBuyMenu.kUpgradeButtonSize, 0))
            buttonIcon:SetTexture(GUIAlienBuyMenu.kBuyHUDTexture)
            
            local iconX, iconY = GetMaterialXYOffset(techId, false)
            iconX = iconX * GUIAlienBuyMenu.kUpgradeButtonTextureSize
            iconY = iconY * GUIAlienBuyMenu.kUpgradeButtonTextureSize        
            buttonIcon:SetTexturePixelCoordinates(iconX, iconY, iconX + GUIAlienBuyMenu.kUpgradeButtonTextureSize, iconY + GUIAlienBuyMenu.kUpgradeButtonTextureSize)
            
            // Render above the Alien image.
            buttonIcon:SetLayer(kGUILayerPlayerHUDForeground3)
            self.background:AddChild(buttonIcon)

            local unselectedPosition = Vector( math.cos(angle) * GUIAlienBuyMenu.kUpgradeButtonDistance - GUIAlienBuyMenu.kUpgradeButtonSize * .5, math.sin(angle) * GUIAlienBuyMenu.kUpgradeButtonDistance - GUIAlienBuyMenu.kUpgradeButtonSize * .5, 0 )
            
            buttonIcon:SetPosition(unselectedPosition)
            
            local purchased = AlienBuy_GetUpgradePurchased(techId)
            if purchased then
                table.insertunique(self.upgradeList, techId)
            end
            

            table.insert(self.upgradeButtons, { Background = nil, Icon = buttonIcon, TechId = techId, Category = category,
                                                Selected = purchased, SelectedMovePercent = 0, Cost = 0, Purchased = purchased, Index = nil, 
                                                UnselectedPosition = unselectedPosition, SelectedPosition = self.slots[i].Graphic:GetPosition()  })
        
        
        end
    
    end

end

function GUIAlienBuyMenu:_UninitializeUpgradeButtons()

    for i, currentButton in ipairs(self.upgradeButtons) do
    
        GUI.DestroyItem(currentButton.Icon)
        if currentButton.Background then
            GUI.DestroyItem(currentButton.Background)
        end
        
    end
    self.upgradeButtons = { }
    
end

function GUIAlienBuyMenu:_InitializeEvolveButton()

    self.selectedAlienType = AlienBuy_GetCurrentAlien()
    
    self.evolveButtonBackground = GUIManager:CreateGraphicItem()
    self.evolveButtonBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.evolveButtonBackground:SetSize(Vector(GUIAlienBuyMenu.kEvolveButtonWidth, GUIAlienBuyMenu.kEvolveButtonHeight, 0))
    self.evolveButtonBackground:SetPosition(Vector(-GUIAlienBuyMenu.kEvolveButtonWidth / 2, GUIAlienBuyMenu.kEvolveButtonHeight / 2 + GUIAlienBuyMenu.kEvolveButtonYOffset, 0))
    self.evolveButtonBackground:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    self.evolveButtonBackground:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kEvolveButtonTextureCoordinates))
    self.background:AddChild(self.evolveButtonBackground)
    
    self.evolveButtonVeins = GUIManager:CreateGraphicItem()
    self.evolveButtonVeins:SetSize(Vector(GUIAlienBuyMenu.kEvolveButtonWidth - kVeinsMargin * 2, GUIAlienBuyMenu.kEvolveButtonHeight - kVeinsMargin * 2, 0))
    self.evolveButtonVeins:SetPosition(Vector(kVeinsMargin, kVeinsMargin, 0))
    self.evolveButtonVeins:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    self.evolveButtonVeins:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kEvolveButtonVeinsTextureCoordinates))
    self.evolveButtonVeins:SetColor(Color(1, 1, 1, 0))
    self.evolveButtonBackground:AddChild(self.evolveButtonVeins)
    
    self.evolveButtonText = GUIManager:CreateTextItem()
    self.evolveButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.evolveButtonText:SetFontName(kFont)
    self.evolveButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.evolveButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.evolveButtonText:SetText(Locale.ResolveString("ABM_EVOLVE_FOR"))
    self.evolveButtonText:SetColor(Color(0, 0, 0, 1))
    self.evolveButtonText:SetPosition(Vector(0, 0, 0))
    self.evolveButtonVeins:AddChild(self.evolveButtonText)
    
    self.evolveResourceIcon = GUIManager:CreateGraphicItem()
    self.evolveResourceIcon:SetSize(Vector(GUIAlienBuyMenu.kResourceIconWidth, GUIAlienBuyMenu.kResourceIconHeight, 0))
    self.evolveResourceIcon:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.evolveResourceIcon:SetPosition(Vector(4, -GUIAlienBuyMenu.kResourceIconHeight / 2, 0))
    self.evolveResourceIcon:SetTexture(GUIAlienBuyMenu.kResourceIconTexture)
    self.evolveResourceIcon:SetColor(Color(0, 0, 0, 1))
    self.evolveResourceIcon:SetIsVisible(false)
    self.evolveButtonText:AddChild(self.evolveResourceIcon)
    
    self.evolveButtonResAmount = GUIManager:CreateTextItem()
    self.evolveButtonResAmount:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.evolveButtonResAmount:SetPosition(Vector(0, 0, 0))
    self.evolveButtonResAmount:SetFontName(kFont)
    self.evolveButtonResAmount:SetTextAlignmentX(GUIItem.Align_Min)
    self.evolveButtonResAmount:SetTextAlignmentY(GUIItem.Align_Center)
    self.evolveButtonResAmount:SetColor(Color(0, 0, 0, 1))
    self.evolveResourceIcon:AddChild(self.evolveButtonResAmount)

end

function GUIAlienBuyMenu:_UninitializeEvolveButton()

    GUI.DestroyItem(self.evolveButtonResAmount)
    self.evolveButtonResAmount = nil
    
    GUI.DestroyItem(self.evolveResourceIcon)
    self.evolveResourceIcon = nil
    
    GUI.DestroyItem(self.evolveButtonText)
    self.evolveButtonText = nil
    
    GUI.DestroyItem(self.evolveButtonVeins)
    self.evolveButtonVeins = nil
    
    GUI.DestroyItem(self.evolveButtonBackground)
    self.evolveButtonBackground = nil
    
end

function GUIAlienBuyMenu:_InitializeCloseButton()

    self.closeButton = GUIManager:CreateGraphicItem()
    self.closeButton:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.closeButton:SetSize(Vector(GUIAlienBuyMenu.kCloseButtonSize, GUIAlienBuyMenu.kCloseButtonSize, 0))
    self.closeButton:SetPosition(Vector(-GUIAlienBuyMenu.kCloseButtonSize * 2, GUIAlienBuyMenu.kCloseButtonSize, 0))
    self.closeButton:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    self.closeButton:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kCloseButtonTextureCoordinates))
    self.closeButton:SetLayer(kGUILayerPlayerHUDForeground4)
    
end

function GUIAlienBuyMenu:_UninitializeCloseButton()
    
    GUI.DestroyItem(self.closeButton)
    self.closeButton = nil

end

function GUIAlienBuyMenu:_InitializeGlowieParticles()

    self.glowieParticles = GUIParticleSystem()
    self.glowieParticles:Initialize()
    
    self.glowieParticles:AddParticleType("Glowie",
                                           { SetTexture = { GUIAlienBuyMenu.kBuyMenuTexture },
                                             SetTexturePixelCoordinates = { GUIAlienBuyMenu.kGlowieBigTextureCoordinates, GUIAlienBuyMenu.kGlowieSmallTextureCoordinates },
                                             SetStencilFunc = { GUIItem.NotEqual } })
    
    local followVelocityFunc = function(particle, lifeTime)
                                   particle.Item:SetRotation(Vector(0, 0, math.atan2(particle.velocity.x, particle.velocity.y) - math.pi / 2))
                               end
    // The glowie will fade in until the lifetime is at this amount and then fade out for the rest of the time.
    local fadeInToLifetime = 0.3
    local fadeInFunc = function(particle, lifetime) if lifetime <= fadeInToLifetime then particle.Item:SetColor(Color(1, 1, 1, lifetime / fadeInToLifetime)) end end
    local fadeOutFunc = function(particle, lifetime) if lifetime > fadeInToLifetime then particle.Item:SetColor(Color(1, 1, 1, 1 - (lifetime - fadeInToLifetime) / (1 - fadeInToLifetime))) end end
    local scaleFunc = function(particle, lifetime) particle.Item:SetScale(Vector(0.5 + (lifetime * 0.5), 0.5 + (lifetime * 0.5), 0)) end
    local centerEmitter = { Name = "CenterBig",
                            Position = Vector(0, 0, 0),
                            EmitOffsetLimits = { Min = Vector(-100, -100, 0), Max = Vector(100, 100, 0) },
                            SizeLimits = { MinX = 15, MaxX = 15, MinY = 10, MaxY = 10 },
                            VelocityLimits = { Min = Vector(-1, -1, 0), Max = Vector(1, 1, 0) },
                            AccelLimits = { Min = Vector(-0.5, -0.5, 0), Max = Vector(0.5, 0.5, 0) },
                            RateLimits = { Min = 0.5, Max = 1.0 },
                            LifeLimits = { Min = 15, Max = 20 },
                            LifeTimeFuncs = { followVelocityFunc, fadeInFunc, fadeOutFunc, scaleFunc } }
    self.glowieParticles:AddEmitter(centerEmitter)
    
    self.glowieParticles:AddParticleTypeToEmitter("Glowie", "CenterBig")
    
    local randomTurnMod = function(particle, deltaTime)
                              if math.random() < 0.20 * deltaTime then
                                  particle.velocity = Vector(particle.velocity.y, -particle.velocity.x, 0)
                              end
                          end
    self.glowieParticles:AddModifier({ Name = "RandomTurn", ModFunc = randomTurnMod })
    
    local limitVelocityMod = function(particle, deltaTime)
                                 local particleSpeed = particle.velocity:GetLengthSquared()
                                 local maxSpeed = 5
                                 if particleSpeed >= maxSpeed * maxSpeed then
                                    particle.velocity = GetNormalizedVector(particle.velocity) * maxSpeed
                                 end
                             end
    self.glowieParticles:AddModifier({ Name = "VelocityLimit", ModFunc = limitVelocityMod })
    
    self.glowieParticles:AttachToItem(self.background)
    self.glowieParticles:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.glowieParticles:SetLayer(kGUILayerPlayerHUDForeground1)
    
    // Fast forward so particles already exist when the player first sees the menu.
    self.glowieParticles:FastForward(10)
    
    // We don't want the mouse affecting the particles until the player can see the particles, so add it after the FF.
    local mouseAttractMod = function(particle, deltaTime)
                                local itemScreenPosition = particle.Item:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight())
                                itemScreenPosition.x = itemScreenPosition.x + particle.Item:GetSize().x / 2
                                itemScreenPosition.y = itemScreenPosition.y + particle.Item:GetSize().y / 2
                                local mouseX, mouseY = Client.GetCursorPosScreen()
                                local mousePos = Vector(mouseX, mouseY, 0)
                                local attractDir = mousePos - itemScreenPosition
                                local attractForce = 1 - math.min(1, attractDir:GetLengthSquared() / (200 * 200))
                                particle.velocity = particle.velocity + (attractDir * attractForce * 0.5 * deltaTime)
                            end
    self.glowieParticles:AddModifier({ Name = "MouseAttract", ModFunc = mouseAttractMod })

end

function GUIAlienBuyMenu:_UninitializeGlowieParticles()

    self.glowieParticles:Uninitialize()
    self.glowieParticles = nil

end

function GUIAlienBuyMenu:_InitializeSmokeParticles()

    self.smokeParticles = GUIParticleSystem()
    self.smokeParticles:Initialize()
    
    self.smokeParticles:AddParticleType("SmokeBig",
                                          { SetTexture = { GUIAlienBuyMenu.kBuyMenuTexture },
                                            SetTexturePixelCoordinates = GUIAlienBuyMenu.kSmokeSmallTextureCoordinates })
    
    local fadeInFunc = function(particle, lifetime) if lifetime <= 0.5 then particle.Item:SetColor(Color(1, 1, 1, lifetime / 2)) end end
    local fadeOutFunc = function(particle, lifetime) if lifetime > 0.5 then particle.Item:SetColor(Color(1, 1, 1, (1 - lifetime) / 2)) end end
    local scaleFunc = function(particle, lifetime) particle.Item:SetScale(Vector(0.5 + (1 - lifetime * 0.5), 0.5 + (1 - lifetime * 0.5), 0)) end
    
    local tailEmitter = { Name = "Tail",
                          Position = Vector(0, 0, 0),
                          EmitOffsetLimits = { Min = Vector(0, -50, 0), Max = Vector(40, 50, 0) },
                          SizeLimits = { MinX = 150, MaxX = 150, MinY = 100, MaxY = 100 },
                          VelocityLimits = { Min = Vector(10, -10, 0), Max = Vector(40, 10, 0) },
                          AccelLimits = { Min = Vector(-0.05, -5, 0), Max = Vector(0.4, 5, 0) },
                          RateLimits = { Min = 0.05, Max = 0.1 },
                          LifeLimits = { Min = 3, Max = 5 },
                          LifeTimeFuncs = { fadeInFunc, fadeOutFunc, scaleFunc } }
    self.smokeParticles:AddEmitter(tailEmitter)
    self.smokeParticles:AddParticleTypeToEmitter("SmokeBig", "Tail")
    
    local topEmitter = { Name = "Top",
                         Position = Vector(GUIScale(-300), GUIScale(-150), 0),
                         EmitOffsetLimits = { Min = Vector(-80, -80, 0), Max = Vector(50, 20, 0) },
                         SizeLimits = { MinX = 150, MaxX = 150, MinY = 100, MaxY = 100 },
                         VelocityLimits = { Min = Vector(10, 0, 0), Max = Vector(40, 10, 0) },
                         AccelLimits = { Min = Vector(-0.05, 0, 0), Max = Vector(0.4, 2.5, 0) },
                         RateLimits = { Min = 0.1, Max = 0.2 },
                         LifeLimits = { Min = 10, Max = 15 },
                         LifeTimeFuncs = { fadeInFunc, fadeOutFunc, scaleFunc } }
    self.smokeParticles:AddEmitter(topEmitter)
    self.smokeParticles:AddParticleTypeToEmitter("SmokeBig", "Top")
    
    local bottomEmitter = { Name = "Bottom",
                            Position = Vector(GUIScale(-300), GUIScale(150), 0),
                            EmitOffsetLimits = { Min = Vector(-80, -20, 0), Max = Vector(50, 80, 0) },
                            SizeLimits = { MinX = 150, MaxX = 150, MinY = 100, MaxY = 100 },
                            VelocityLimits = { Min = Vector(10, -10, 0), Max = Vector(40, 0, 0) },
                            AccelLimits = { Min = Vector(-0.05, -2.5, 0), Max = Vector(0.4, 0, 0) },
                            RateLimits = { Min = 0.1, Max = 0.2 },
                            LifeLimits = { Min = 10, Max = 15 },
                            LifeTimeFuncs = { fadeInFunc, fadeOutFunc, scaleFunc } }
    self.smokeParticles:AddEmitter(bottomEmitter)
    self.smokeParticles:AddParticleTypeToEmitter("SmokeBig", "Bottom")
    
    local frontEmitter = { Name = "Front",
                           Position = Vector(GUIScale(-500), GUIScale(0), 0),
                           EmitOffsetLimits = { Min = Vector(-100, -20, 0), Max = Vector(0, 20, 0) },
                           SizeLimits = { MinX = 150, MaxX = 150, MinY = 100, MaxY = 100 },
                           VelocityLimits = { Min = Vector(20, -30, 0), Max = Vector(30, 30, 0) },
                           AccelLimits = { Min = Vector(-0.05, -5, 0), Max = Vector(0.4, 5, 0) },
                           RateLimits = { Min = 0.5, Max = 0.1 },
                           LifeLimits = { Min = 5, Max = 10 },
                           LifeTimeFuncs = { fadeInFunc, fadeOutFunc, scaleFunc } }
    self.smokeParticles:AddEmitter(frontEmitter)
    self.smokeParticles:AddParticleTypeToEmitter("SmokeBig", "Front")
    
    local mouseRepulseMod = function(particle, deltaTime)
                                local itemScreenPosition = particle.Item:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight())
                                itemScreenPosition.x = itemScreenPosition.x + particle.Item:GetSize().x / 2
                                itemScreenPosition.y = itemScreenPosition.y + particle.Item:GetSize().y / 2
                                local mouseX, mouseY = Client.GetCursorPosScreen()
                                local mousePos = Vector(mouseX, mouseY, 0)
                                local repulsionDir = itemScreenPosition - mousePos
                                local repulsionForce = 1 - math.min(1, repulsionDir:GetLengthSquared() / (100 * 100))
                                particle.Item:SetPosition(particle.Item:GetPosition() + (repulsionDir * repulsionForce * 2 * deltaTime))
                            end
    self.smokeParticles:AddModifier({ Name = "MouseRepulse", ModFunc = mouseRepulseMod })
    
    self.smokeParticles:AttachToItem(self.background)
    self.smokeParticles:SetAnchor(GUIItem.Right, GUIItem.Center)
    --self.smokeParticles:SetLayer(kGUILayerPlayerHUDBackground)
    
    // Fast forward so particles already exist when the player first sees the menu.
    self.smokeParticles:FastForward(3)

end

function GUIAlienBuyMenu:_UninitializeSmokeParticles()

    self.smokeParticles:Uninitialize()
    self.smokeParticles = nil
    
end

function GUIAlienBuyMenu:_InitializeCorners()

    self.corners = { }
    
    local topLeftCorner = GUIManager:CreateGraphicItem()
    topLeftCorner:SetAnchor(GUIItem.Left, GUIItem.Top)
    topLeftCorner:SetSize(Vector(GUIAlienBuyMenu.kCornerWidths.TopLeft, GUIAlienBuyMenu.kCornerHeights.TopLeft, 0))
    topLeftCorner:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    topLeftCorner:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kCornerTextureCoordinates.TopLeft))
    topLeftCorner:SetLayer(kGUILayerPlayerHUDBackground)
    topLeftCorner:SetShader("shaders/GUIWavyNoMask.surface_shader")
    self.corners.TopLeft = topLeftCorner
    
    local bottomLeftCorner = GUIManager:CreateGraphicItem()
    bottomLeftCorner:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    bottomLeftCorner:SetPosition(Vector(0, -GUIAlienBuyMenu.kCornerHeights.BottomLeft, 0))
    bottomLeftCorner:SetSize(Vector(GUIAlienBuyMenu.kCornerWidths.BottomLeft, GUIAlienBuyMenu.kCornerHeights.BottomLeft, 0))
    bottomLeftCorner:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    bottomLeftCorner:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kCornerTextureCoordinates.BottomLeft))
    bottomLeftCorner:SetLayer(kGUILayerPlayerHUDBackground)
    bottomLeftCorner:SetShader("shaders/GUIWavyNoMask.surface_shader")
    self.corners.BottomLeft = bottomLeftCorner
    
    local topRightCorner = GUIManager:CreateGraphicItem()
    topRightCorner:SetAnchor(GUIItem.Right, GUIItem.Top)
    topRightCorner:SetPosition(Vector(-GUIAlienBuyMenu.kCornerWidths.TopRight, 0, 0))
    topRightCorner:SetSize(Vector(GUIAlienBuyMenu.kCornerWidths.TopRight, GUIAlienBuyMenu.kCornerHeights.TopRight, 0))
    topRightCorner:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    topRightCorner:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kCornerTextureCoordinates.TopRight))
    topRightCorner:SetLayer(kGUILayerPlayerHUDBackground)
    topRightCorner:SetShader("shaders/GUIWavyNoMask.surface_shader")
    self.corners.TopRight = topRightCorner
    
    local bottomRightCorner = GUIManager:CreateGraphicItem()
    bottomRightCorner:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    bottomRightCorner:SetPosition(Vector(-GUIAlienBuyMenu.kCornerWidths.BottomRight, -GUIAlienBuyMenu.kCornerHeights.BottomRight, 0))
    bottomRightCorner:SetSize(Vector(GUIAlienBuyMenu.kCornerWidths.BottomRight, GUIAlienBuyMenu.kCornerHeights.BottomRight, 0))
    bottomRightCorner:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    bottomRightCorner:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kCornerTextureCoordinates.BottomRight))
    bottomRightCorner:SetLayer(kGUILayerPlayerHUDBackground)
    bottomRightCorner:SetShader("shaders/GUIWavyNoMask.surface_shader")
    self.corners.BottomRight = bottomRightCorner
    
    self.cornerTweeners = { }
    for cornerName, _ in pairs(self.corners) do
        self.cornerTweeners[cornerName] = Tweener("loopforward")
        self.cornerTweeners[cornerName].add(GUIAlienBuyMenu.kCornerPulseTime, { percent = 1 }, Easing.linear)
        self.cornerTweeners[cornerName].add(GUIAlienBuyMenu.kCornerPulseTime, { percent = 0 }, Easing.linear)
    end

end

function GUIAlienBuyMenu:_UninitializeCorners()

    for cornerName, cornerItem in pairs(self.corners) do
        GUI.DestroyItem(cornerItem)
    end
    self.corners = { }
    
    self.cornerTweeners = { }

end

local function GetUpgradeCostForLifeForm(player, alienType, upgradeId)

    if player then
    
        local alienTechNode = GetAlienTechNode(alienType, true)
        if alienTechNode then

            if player:GetTechId() == alienTechNode:GetTechId() and player:GetHasUpgrade(upgradeId) then
                return 0
            end    
        
            return LookupTechData(alienTechNode:GetTechId(), kTechDataUpgradeCost, 0)
            
        end
    
    end
    
    return 0

end

local function GetSelectedUpgradesCost(self, alienType)

    local cost = 0
    for i, currentButton in ipairs(self.upgradeButtons) do
    
        local upgradeCost = GetUpgradeCostForLifeForm(Client.GetLocalPlayer(), alienType, currentButton.TechId)
    
        if currentButton.Selected then
            cost = cost + upgradeCost
        end
        
    end   
    
    return cost
    
end

local function GetNumberOfNewlySelectedUpgrades(self)

    local numSelected = 0
    local player = Client.GetLocalPlayer()
    
    if player then
    
        for i, currentButton in ipairs(self.upgradeButtons) do
        
            if currentButton.Selected and not player:GetHasUpgrade(currentButton.TechId) then
                numSelected = numSelected + 1
            end
            
        end
    
    end
    
    return numSelected 

end

local function GetNumberOfSelectedUpgrades(self)

    local numSelected = 0
    for i, currentButton in ipairs(self.upgradeButtons) do
    
        if currentButton.Selected then
            numSelected = numSelected + 1
        end
        
    end
    
    return numSelected
    
end

local function GetCanAffordAlienTypeAndUpgrades(self, alienType)

    local alienCost = AlienBuy_GetAlienCost(alienType, false)
    local upgradesCost = GetSelectedUpgradesCost(self, alienType)
    // Cannot buy the current alien without upgrades.
    if alienType == AlienBuy_GetCurrentAlien() then
        alienCost = 0
    end
    
    return PlayerUI_GetPlayerResources() >= alienCost + upgradesCost
    
end

/**
 * Returns true if the player has a different Alien or any upgrade selected.
 */
local function GetAlienOrUpgradeSelected(self)
    return self.selectedAlienType ~= AlienBuy_GetCurrentAlien() or GetNumberOfNewlySelectedUpgrades(self) > 0
end

local function UpdateEvolveButton(self)

    local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(GUIAlienBuyMenu.kAlienTypes[self.selectedAlienType].Index)
    local selectedUpgradesCost = GetSelectedUpgradesCost(self, self.selectedAlienType)
    local numberOfSelectedUpgrades = GetNumberOfNewlySelectedUpgrades(self)
    local evolveButtonTextureCoords = GUIAlienBuyMenu.kEvolveButtonTextureCoordinates
    local hasGameStarted = PlayerUI_GetHasGameStarted()
    local evolveText = Locale.ResolveString("ABM_GAME_NOT_STARTED")
    local evolveCost = nil
    
    if hasGameStarted then
    
        evolveText = Locale.ResolveString("ABM_SELECT_UPGRADES")
        
        // If the current alien is selected with no upgrades, cannot evolve.
        if self.selectedAlienType == AlienBuy_GetCurrentAlien() and numberOfSelectedUpgrades == 0 then
            evolveButtonTextureCoords = GUIAlienBuyMenu.kEvolveButtonNeedResourcesTextureCoordinates
        elseif not GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType) then
        
            // If cannot afford selected alien type and/or upgrades, cannot evolve.
            evolveButtonTextureCoords = GUIAlienBuyMenu.kEvolveButtonNeedResourcesTextureCoordinates
            evolveText = Locale.ResolveString("ABM_NEED")
            evolveCost = AlienBuy_GetAlienCost(self.selectedAlienType, false) + selectedUpgradesCost
            
        else
        
            // Evolution is possible! Darwin would be proud.
            local totalCost = selectedUpgradesCost
            
            // Cannot buy the current alien.
            if self.selectedAlienType ~= AlienBuy_GetCurrentAlien() then
                totalCost = totalCost + AlienBuy_GetAlienCost(self.selectedAlienType, false)
            end
            
            evolveText = Locale.ResolveString("ABM_EVOLVE_FOR")
            evolveCost = totalCost
            
        end
        
    end
    
    self.evolveButtonBackground:SetTexturePixelCoordinates(unpack(evolveButtonTextureCoords))
    self.evolveButtonText:SetText(evolveText)
    self.evolveResourceIcon:SetIsVisible(evolveCost ~= nil)
    local totalEvolveButtonTextWidth = 0
    
    if evolveCost ~= nil then
    
        local evolveCostText = ToString(evolveCost)
        self.evolveButtonResAmount:SetText(evolveCostText)
        totalEvolveButtonTextWidth = totalEvolveButtonTextWidth + self.evolveResourceIcon:GetSize().x +
                                     self.evolveButtonResAmount:GetTextWidth(evolveCostText)
        
    end
    
    self.evolveButtonText:SetPosition(Vector(-totalEvolveButtonTextWidth / 2, 0, 0))
    
    local allowedToEvolve = not researching and GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType) and hasGameStarted
    allowedToEvolve = allowedToEvolve and GetAlienOrUpgradeSelected(self)
    local veinsAlpha = 0
    self.evolveButtonBackground:SetScale(Vector(1, 1, 0))
    
    if allowedToEvolve then
    
        if self:_GetIsMouseOver(self.evolveButtonBackground) then
        
            veinsAlpha = 1
            self.evolveButtonBackground:SetScale(Vector(1.1, 1.1, 0))
            
        else
            veinsAlpha = (math.sin(Shared.GetTime() * 4) + 1) / 2
        end
        
    end
    
    self.evolveButtonVeins:SetColor(Color(1, 1, 1, veinsAlpha))
    
end

function GUIAlienBuyMenu:Update(deltaTime)

    // Assume there is no mouse over info to start.
    self:_HideMouseOverInfo()
    
    self.currentAlienDisplay.Icon:SetTexture("ui/" .. GUIAlienBuyMenu.kAlienTypes[self.selectedAlienType].Name .. ".dds")
    local width = GUIAlienBuyMenu.kAlienTypes[self.selectedAlienType].Width
    local height = GUIAlienBuyMenu.kAlienTypes[self.selectedAlienType].Height
    self.currentAlienDisplay.Icon:SetSize(Vector(width, height, 0))
    self.currentAlienDisplay.Icon:SetPosition(Vector((-width / 2), -height / 2, 0))
    
    self.currentAlienDisplay.TitleShadow:SetText(GUIAlienBuyMenu.kAlienTypes[self.selectedAlienType].Name)
    self.currentAlienDisplay.Title:SetText(GUIAlienBuyMenu.kAlienTypes[self.selectedAlienType].Name)
    
    self:_UpdateAlienButtons()
    
    UpdateEvolveButton(self)
    
    self:_UpdateUpgrades(deltaTime)
    
    self:_UpdateCloseButton(deltaTime)
    
    self:_UpdateParticles(deltaTime)
    
    self:_UpdateCorners(deltaTime)
    
    self:_UpdateAbilityIcons(deltaTime)
    
    table.foreach(self.upgradeTweeners, function(tweener) self.upgradeTweeners[tweener].update(deltaTime) end)
    
end

function GUIAlienBuyMenu:_UpdateAbilityIcons()

    for index, abilityItem in ipairs(self.abilityIcons) do
    
        if GetIsTechUnlocked(Client.GetLocalPlayer(), abilityItem.TechId) then        
            abilityItem.Icon:SetColor(kIconColors[kAlienTeamType])            
        else
            abilityItem.Icon:SetColor(Color(0,0,0,1))
        end
        
        local mouseOver = self:_GetIsMouseOver(abilityItem.Icon)    
        abilityItem.HighLight:SetIsVisible(mouseOver)
        
        if mouseOver then
        
            local abilityInfoText = Locale.ResolveString(LookupTechData(abilityItem.TechId, kTechDataDisplayName, ""))
            local tooltip = Locale.ResolveString(LookupTechData(abilityItem.TechId, kTechDataTooltipInfo, ""))
            
            self:_ShowMouseOverInfo(abilityInfoText, tooltip)
            
        end
        
    end
    
end

function GUIAlienBuyMenu:_GetCanAffordAlienType(alienType)

    local alienCost = AlienBuy_GetAlienCost(alienType, false)
    // Cannot buy the current alien without upgrades.
    if alienType == AlienBuy_GetCurrentAlien() then
        return false
    end

    return PlayerUI_GetPlayerResources() >= alienCost
    
end

function GUIAlienBuyMenu:_GetAlienTypeResearchInfo(alienType)
    local researched = AlienBuy_IsAlienResearched(alienType)
    local researchProgress = AlienBuy_GetAlienResearchProgress(alienType)
    local researching = researchProgress > 0 and researchProgress < 1
    return researched, researchProgress, researching
end

function GUIAlienBuyMenu:_GetNumberOfAliensAvailable()

    local numberResearched = 0
    for k, alienType in ipairs(GUIAlienBuyMenu.kAlienTypes) do
        local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(alienType.Index)
        numberResearched = numberResearched + (((researched or researching) and 1) or 0)
    end
    return numberResearched

end

function GUIAlienBuyMenu:_UpdateAlienButtons()

    local numAlienTypes = self:_GetNumberOfAliensAvailable()
    local totalAlienButtonsWidth = GUIAlienBuyMenu.kAlienButtonSize * numAlienTypes
    
    local mouseX, mouseY = Client.GetCursorPosScreen()
    
    for k, alienButton in ipairs(self.alienButtons) do
    
        // Info needed for the rest of this code.
        local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(alienButton.TypeData.Index)
        
        local buttonIsVisible = researched or researching
        alienButton.Button:SetIsVisible(buttonIsVisible)
        
        // Don't bother updating anything else unless it is visible.
        if buttonIsVisible then
        
            local isCurrentAlien = AlienBuy_GetCurrentAlien() == alienButton.TypeData.Index
            if researched and (isCurrentAlien or self:_GetCanAffordAlienType(alienButton.TypeData.Index)) then
                alienButton.Button:SetColor(GUIAlienBuyMenu.kEnabledColor)
            elseif researched and not self:_GetCanAffordAlienType(alienButton.TypeData.Index) then
                alienButton.Button:SetColor(GUIAlienBuyMenu.kCannotBuyColor)
            elseif researching then
                alienButton.Button:SetColor(GUIAlienBuyMenu.kDisabledColor)
            end
            
            local mouseOver = self:_GetIsMouseOver(alienButton.Button)
            
            if mouseOver then
            
                local classStats = AlienBuy_GetClassStats(GUIAlienBuyMenu.kAlienTypes[alienButton.TypeData.Index].Index)
                local mouseOverName = GUIAlienBuyMenu.kAlienTypes[alienButton.TypeData.Index].Name
                local health = classStats[2]
                local armor = classStats[3]
                self:_ShowMouseOverInfo(mouseOverName, GetTooltipInfoText(IndexToAlienTechId(alienButton.TypeData.Index)), classStats[4], health, armor)
                
            end
            
            // Only show the background if the mouse is over this button.
            alienButton.SelectedBackground:SetColor(Color(1, 1, 1, ((mouseOver and 1) or 0)))

            local offset = Vector((((alienButton.TypeData.XPos - 1) / numAlienTypes) * (GUIAlienBuyMenu.kAlienButtonSize * numAlienTypes)) - (totalAlienButtonsWidth / 2), 0, 0)
            alienButton.SelectedBackground:SetPosition(Vector(-GUIAlienBuyMenu.kAlienButtonSize / 2, -GUIAlienBuyMenu.kAlienSelectedButtonSize / 2 - alienButton.ARAdjustedHeight / 2, 0) + offset)

            alienButton.PlayersText:SetText("x" .. ToString(ScoreboardUI_GetNumberOfAliensByType(alienButton.TypeData.Name)))
            
            alienButton.ResearchText:SetIsVisible(researching)
            if researching then
                alienButton.ResearchText:SetText(string.format("%d%%", researchProgress * 100))
            end
            
        end
        
    end

end

local kDefaultColor = Color(kIconColors[kAlienTeamType])
local kNotAvailableColor = Color(0.0, 0.0, 0.0, 1)
local kNotAllowedColor = Color(1, 0,0,1)
local kPurchasedColor = Color(1, 0.6, 0, 1)

function GUIAlienBuyMenu:_UpdateUpgrades(deltaTime)

    for i, slot in ipairs(self.slots) do

        if GetHasAnyCathegoryUpgrade(slot.Category) then
            slot.Graphic:SetTexture(GUIAlienBuyMenu.kSlotTexture)    
        else
            slot.Graphic:SetTexture(GUIAlienBuyMenu.kSlotLockedTexture)
        end   
    
    end

    for i, currentButton in ipairs(self.upgradeButtons) do

        local useColor = kDefaultColor
        
        if currentButton.Purchased then
            useColor = kPurchasedColor

        elseif not AlienBuy_GetTechAvailable(currentButton.TechId) then           
            useColor = kNotAvailableColor
            
            // unselect button if tech becomes unavailable
            if currentButton.Selected then
                currentButton.Selected = false
            end
            
        elseif not currentButton.Selected and not AlienBuy_GetIsUpgradeAllowed(currentButton.TechId, self.upgradeList) then
            useColor = kNotAllowedColor
        end
        
        currentButton.Icon:SetColor(useColor)
        
        if currentButton.Selected then
            currentButton.Icon:SetPosition(currentButton.SelectedPosition)
        else
            currentButton.Icon:SetPosition(currentButton.UnselectedPosition)
        end
        
       if self:_GetIsMouseOver(currentButton.Icon) then
       
            local currentUpgradeInfoText = GetDisplayNameForTechId(currentButton.TechId)
            local tooltipText = GetTooltipInfoText(currentButton.TechId)

            //local health = LookupTechData(currentButton.TechId, kTechDataMaxHealth)
            //local armor = LookupTechData(currentButton.TechId, kTechDataMaxArmor)

            self:_ShowMouseOverInfo(currentUpgradeInfoText, tooltipText, GetUpgradeCostForLifeForm(Client.GetLocalPlayer(), self.selectedAlienType, currentButton.TechId))
           
        end

    end

end

function GUIAlienBuyMenu:_UpdateCloseButton(deltaTime)

    self.closeButton:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kCloseButtonTextureCoordinates))
    if self:_GetIsMouseOver(self.closeButton) then
        self.closeButton:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kCloseButtonRollOverTextureCoordinates))
    end

end

function GUIAlienBuyMenu:_UpdateParticles(deltaTime)

    self.glowieParticles:Update(deltaTime)
    self.smokeParticles:Update(deltaTime)

end

function GUIAlienBuyMenu:_UpdateCorners(deltaTime)

    table.foreach(self.cornerTweeners,
        function(corner)
            self.cornerTweeners[corner].update(deltaTime)
            local percent = self.cornerTweeners[corner].getCurrentProperties().percent
            self.corners[corner]:SetColor(Color(1, percent, percent, math.abs(percent - 0.5) + 0.5))
        end)

end

function GUIAlienBuyMenu:_ShowMouseOverInfo(lifeformText, infoText, costAmount, health, armor)

    self.mouseOverTitle:SetIsVisible(true)
    self.mouseOverTitle:SetText(lifeformText)
    self.mouseOverTitle:SetTextClipped(true, kTooltipTextWidth, 1024)

    self.mouseOverInfo:SetIsVisible(true)
    self.mouseOverInfo:SetText(infoText)
    self.mouseOverInfo:SetTextClipped(true, kTooltipTextWidth, 1024)
    
    self.mouseOverInfoResIcon:SetIsVisible(costAmount ~= nil)
    
    self.mouseOverInfoHealthIcon:SetIsVisible(health ~= nil)
    self.mouseOverInfoArmorIcon:SetIsVisible(health ~= nil)
    
    self.mouseOverInfoHealthAmount:SetIsVisible(armor ~= nil)
    self.mouseOverInfoArmorAmount:SetIsVisible(armor ~= nil)
    
    if costAmount then
        self.mouseOverInfoResAmount:SetText(ToString(costAmount))
    end
    
    if health then
        self.mouseOverInfoHealthAmount:SetText(ToString(health))
    end

    if armor then
        self.mouseOverInfoArmorAmount:SetText(ToString(armor))
    end
    
    

end

function GUIAlienBuyMenu:_HideMouseOverInfo()

    self.mouseOverTitle:SetIsVisible(false)
    self.mouseOverInfo:SetIsVisible(false)
    self.mouseOverInfoResIcon:SetIsVisible(false)
    self.mouseOverInfoHealthIcon:SetIsVisible(false)
    self.mouseOverInfoArmorIcon:SetIsVisible(false)
    self.mouseOverInfoHealthAmount:SetIsVisible(false)
    self.mouseOverInfoArmorAmount:SetIsVisible(false)
    
end

function GUIAlienBuyMenu:GetNewLifeFormSelected()

    return self.selectedAlienType ~= AlienBuy_GetCurrentAlien()

end

function GUIAlienBuyMenu:SetPurchasedSelected()

    for i, button in ipairs(self.upgradeButtons) do    
        button.Selected = button.Purchased
        
        if button.Selected then
            table.insertunique(self.upgradeList, button.TechId)
        else
            table.removevalue(self.upgradeList, button.TechId)
        end    
        
    end

end

function GUIAlienBuyMenu:GetHasNewLifeFormSelected()
    return self.selectedAlienType ~= AlienBuy_GetCurrentAlien()
end

function GUIAlienBuyMenu:SendKeyEvent(key, down)

    local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then
    
        self.mousePressed = down
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if down then
        
            // Check if the evolve button was selected.
            local allowedToEvolve = GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType) and PlayerUI_GetHasGameStarted()
            allowedToEvolve = allowedToEvolve and GetAlienOrUpgradeSelected(self)
            if allowedToEvolve and self:_GetIsMouseOver(self.evolveButtonBackground) then
            
                local purchases = { }
                // Buy the selected alien if we have a different one selected.
                if self.selectedAlienType ~= AlienBuy_GetCurrentAlien() then
                    table.insert(purchases, { Type = "Alien", Alien = self.selectedAlienType })
                end
                
                // Buy all selected upgrades.
                for i, currentButton in ipairs(self.upgradeButtons) do
                
                    if currentButton.Selected then
                        table.insert(purchases, { Type = "Upgrade", Alien = self.selectedAlienType, UpgradeIndex = currentButton.Index, TechId = currentButton.TechId })
                    end
                    
                end
                
                closeMenu = true
                inputHandled = true
                
                if #purchases > 0 then
                    AlienBuy_Purchase(purchases)
                end
                
                AlienBuy_OnPurchase()
                
            end
            
            inputHandled = self:_HandleUpgradeClicked(mouseX, mouseY) or inputHandled
            
            if not inputHandled then
            
                // Check if an alien was selected.
                for k, buttonItem in ipairs(self.alienButtons) do
                
                    local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(buttonItem.TypeData.Index)
                    if (researched or researching) and self:_GetIsMouseOver(buttonItem.Button) then
                    
                        // Deselect all upgrades when a different alien type is selected.
                        if self.selectedAlienType ~= buttonItem.TypeData.Index then
                        
                            AlienBuy_OnSelectAlien(GUIAlienBuyMenu.kAlienTypes[buttonItem.TypeData.Index].Name)

                        end

                        self.selectedAlienType = buttonItem.TypeData.Index
                        
                        if self.selectedAlienType ~= AlienBuy_GetCurrentAlien() then 
                            self:_DeselectAllUpgrades()
                        end
                        
                        inputHandled = true
                        break
                        
                    end
                    
                end
                
                // Check if the close button was pressed.
                if self:_GetIsMouseOver(self.closeButton) then
                
                    closeMenu = true
                    inputHandled = true
                    AlienBuy_OnClose()
                    
                end
                
            end
            
        end
        
    end
    
    // No matter what, this menu consumes MouseButton0/1 down.
    if down and (key == InputKey.MouseButton0 or key == InputKey.MouseButton1) then
        inputHandled = true
    end
    
    // AlienBuy_Close() must be the last thing called.
    if closeMenu then
    
        self.closingMenu = true
        AlienBuy_Close()
        
    end
    
    return inputHandled
    
end

function GUIAlienBuyMenu:_GetUpgradeTweener(forButton)

    ASSERT(forButton ~= nil)
    
    if self.upgradeTweeners[forButton] == nil then
        self.upgradeTweeners[forButton] = Tweener("forward")
        local amplitude = 0.005
        local period = GUIAlienBuyMenu.kUpgradeButtonMoveTime * 0.75
        self.upgradeTweeners[forButton].add(GUIAlienBuyMenu.kUpgradeButtonMoveTime, { percent = 0 }, Easing.outElastic, { amplitude, period })
        self.upgradeTweeners[forButton].add(GUIAlienBuyMenu.kUpgradeButtonMoveTime, { percent = 1 }, Easing.outElastic, { amplitude, period })
    end
    return self.upgradeTweeners[forButton]

end

function GUIAlienBuyMenu:_DeselectAllUpgrades()

    for i, currentButton in ipairs(self.upgradeButtons) do
 
        currentButton.Selected = false
        table.removevalue(self.upgradeList, currentButton.TechId)
        self.numSelectedUpgrades = self.numSelectedUpgrades - 1
  
    end

end

function GUIAlienBuyMenu:GetCanSelect(upgradeButton)

    return AlienBuy_GetTechAvailable(upgradeButton.TechId) and AlienBuy_GetIsUpgradeAllowed(upgradeButton.TechId, self.upgradeList)
    
end

function GUIAlienBuyMenu:_HandleUpgradeClicked(mouseX, mouseY)

    local inputHandled = false
    
    for i, currentButton in ipairs(self.upgradeButtons) do
        // Can't select if it has been purchased already.
        
        local allowedToUnselect = currentButton.Selected or currentButton.Purchased
        local allowedToPuchase = not currentButton.Selected and self:GetCanSelect(currentButton)
                
        if (allowedToUnselect or allowedToPuchase) and self:_GetIsMouseOver(currentButton.Icon) then
        
            currentButton.Selected = not currentButton.Selected
            
            if currentButton.Purchased then
                currentButton.Purchased = false
            end
            
            inputHandled = true
            
            if currentButton.Selected then
                table.insertunique(self.upgradeList, currentButton.TechId)
                AlienBuy_OnUpgradeSelected()
            else
                table.removevalue(self.upgradeList, currentButton.TechId)
                AlienBuy_OnUpgradeDeselected()
            end
            
            break
            
        end
    end
    
    return inputHandled

end

/**
 * Checks if the mouse is over the passed in GUIItem and plays a sound if it has just moved over.
 */
function GUIAlienBuyMenu:_GetIsMouseOver(overItem)

    local mouseOver = GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    if mouseOver and not self.mouseOverStates[overItem] then
        AlienBuy_OnMouseOver()
    end
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver
    
end

function GUIAlienBuyMenu:OnClose()

    // Check if GUIAlienBuyMenu is what is causing itself to close.
    if not self.closingMenu then
        // Play the close sound since we didn't trigger the close.
        AlienBuy_OnClose()
    end

end