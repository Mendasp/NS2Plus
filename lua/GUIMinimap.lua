// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\GUIMinimap.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages displaying the minimap and icons on the minimap.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIMinimapConnection.lua")

class 'GUIMinimap' (GUIScript)

GUIMinimap.kBackgroundWidth = GUIScale(300)
GUIMinimap.kBackgroundHeight = GUIMinimap.kBackgroundWidth

local kBlipSize = GUIScale(30)

local kWaypointColor = Color(1, 1, 1, 1)
local kEtherealGateColor = Color(0.8, 0.6, 1, 1)
local kOverviewColor = Color(1, 1, 1, 0.85)

local kHallucinationColor = Color(0.8, 0.6, 1, 1)

// colors are defined in the dds
local kTeamColors = { }
kTeamColors[kMinimapBlipTeam.Friendly] = Color(1, 1, 1, 1)
kTeamColors[kMinimapBlipTeam.Enemy] = Color(1, 0, 0, 1)
kTeamColors[kMinimapBlipTeam.Neutral] = Color(1, 1, 1, 1)
kTeamColors[kMinimapBlipTeam.Alien] = Color(1, 138/255, 0, 1)
kTeamColors[kMinimapBlipTeam.Marine] = Color(0, 216/255, 1, 1)
// steam friend colors
kTeamColors[kMinimapBlipTeam.FriendAlien] = Color(1, 189/255, 111/255, 1)
kTeamColors[kMinimapBlipTeam.FriendMarine] = Color(164/255, 241/255, 1, 1)

kTeamColors[kMinimapBlipTeam.InactiveAlien] = Color(85/255, 46/255, 0, 1, 1)
kTeamColors[kMinimapBlipTeam.InactiveMarine] = Color(0, 72/255, 85/255, 1)

local kPowerNodeColor = Color(1, 1, 0.7, 1)
local kDestroyedPowerNodeColor = Color(0.5, 0.5, 0.35, 1)

local kDrifterColor = Color(1, 1, 0, 1)
local kMACColor = Color(0, 1, 0.2, 1)

local kBlinkInterval = 1

local kScanColor = Color(0.2, 0.8, 1, 1)
local kScanAnimDuration = 2

local kInfestationColor = { }
kInfestationColor[kMinimapBlipTeam.Friendly] = Color(1, 1, 0, .25)
kInfestationColor[kMinimapBlipTeam.Enemy] = Color(1, 0.67, 0.06, .25)
kInfestationColor[kMinimapBlipTeam.Neutral] = Color(0.2, 0.7, 0.2, .25)
kInfestationColor[kMinimapBlipTeam.Alien] = Color(0.2, 0.7, 0.2, .25)
kInfestationColor[kMinimapBlipTeam.Marine] = Color(0.2, 0.7, 0.2, .25)
kInfestationColor[kMinimapBlipTeam.InactiveAlien] = Color(0.2 /3, 0.7/3, 0.2/3, .25)
kInfestationColor[kMinimapBlipTeam.InactiveMarine] = Color(0.2/3, 0.7/3, 0.2/3, .25)

local kInfestationDyingColor = { }
kInfestationDyingColor[kMinimapBlipTeam.Friendly] = Color(1, 0.2, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.Enemy] = Color(1, 0.2, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.Neutral] =Color(1, 0.2, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.Alien] = Color(1, 0.2, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.Marine] = Color(1, 0.2, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.InactiveAlien] = Color(1/3, 0.2/3, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.InactiveMarine] = Color(1/3, 0.2/3, 0, .25)

local kShrinkingArrowInitSize = Vector(kBlipSize * 10, kBlipSize * 10, 0)

local kIconFileName = "ui/minimap_blip.dds"

local kLargePlayerArrowFileName = PrecacheAsset("ui/minimap_largeplayerarrow.dds")

local kCommanderPingMinimapSize = Vector(80, 80, 0)

local kIconWidth = 32
local kIconHeight = 32

local kInfestationBlipsLayer = 0
local kBackgroundBlipsLayer = 1
local kStaticBlipsLayer = 2
local kDynamicBlipsLayer = 3
local kLocationNameLayer = 4
local kPingLayer = 5
local kPlayerIconLayer = 6

local kBlipTexture = "ui/blip.dds"

local kBlipTextureCoordinates = { }
kBlipTextureCoordinates[kAlertType.Attack] = { X1 = 0, Y1 = 0, X2 = 64, Y2 = 64 }

local kAttackBlipMinSize = Vector(GUIScale(25), GUIScale(25), 0)
local kAttackBlipMaxSize = Vector(GUIScale(100), GUIScale(100), 0)
local kAttackBlipPulseSpeed = 6
local kAttackBlipTime = 5
local kAttackBlipFadeInTime = 4.5
local kAttackBlipFadeOutTime = 1

local kLocationFontSize = 8
local kLocationFontName = "fonts/AgencyFB_smaller_bordered.fnt"

local kPlayerIconSize = Vector(kBlipSize, kBlipSize, 0)

local kBlipColorType = enum( { 'Team', 'Infestation', 'InfestationDying', 'Waypoint', 'PowerPoint', 'DestroyedPowerPoint', 'Scan', 'Drifter', 'MAC', 'EtherealGate', 'HighlightWorld' } )
local kBlipSizeType = enum( { 'Normal', 'TechPoint', 'Infestation', 'Scan', 'Egg', 'Worker', 'EtherealGate', 'HighlightWorld', 'Waypoint' } )

local kBlipInfo = {}
kBlipInfo[kMinimapBlipType.TechPoint] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kBackgroundBlipsLayer }
kBlipInfo[kMinimapBlipType.ResourcePoint] = { kBlipColorType.Team, kBlipSizeType.Normal, kBackgroundBlipsLayer }
kBlipInfo[kMinimapBlipType.Scan] = { kBlipColorType.Scan, kBlipSizeType.Scan, kBackgroundBlipsLayer }
kBlipInfo[kMinimapBlipType.CommandStation] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.Hive] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.Egg] = { kBlipColorType.Team, kBlipSizeType.Egg, kStaticBlipsLayer, "Infestation" }
kBlipInfo[kMinimapBlipType.PowerPoint] = { kBlipColorType.PowerPoint, kBlipSizeType.Normal, kStaticBlipsLayer, "PowerPoint" }
kBlipInfo[kMinimapBlipType.DestroyedPowerPoint] = { kBlipColorType.DestroyedPowerPoint, kBlipSizeType.Normal, kStaticBlipsLayer, "PowerPoint" }
kBlipInfo[kMinimapBlipType.Infestation] = { kBlipColorType.Infestation, kBlipSizeType.Infestation, kInfestationBlipsLayer, "Infestation" }
kBlipInfo[kMinimapBlipType.InfestationDying] = { kBlipColorType.InfestationDying, kBlipSizeType.Infestation, kInfestationBlipsLayer, "Infestation" }
kBlipInfo[kMinimapBlipType.MoveOrder] = { kBlipColorType.Waypoint, kBlipSizeType.Waypoint, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.AttackOrder] = { kBlipColorType.Waypoint, kBlipSizeType.Waypoint, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.BuildOrder] = { kBlipColorType.Waypoint, kBlipSizeType.Waypoint, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.Drifter] = { kBlipColorType.Drifter, kBlipSizeType.Worker, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.MAC] = { kBlipColorType.MAC, kBlipSizeType.Worker, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.EtherealGate] = { kBlipColorType.EtherealGate, kBlipSizeType.EtherealGate, kBackgroundBlipsLayer }
kBlipInfo[kMinimapBlipType.HighlightWorld] = { kBlipColorType.HighlightWorld, kBlipSizeType.HighlightWorld, kBackgroundBlipsLayer }

local kClassToGrid = BuildClassToGrid()

local function PlotToMap(self, posX, posZ)

    local plottedX = (posX + self.plotToMapConstX) * self.plotToMapLinX
    local plottedY = (posZ + self.plotToMapConstY) * self.plotToMapLinY
    
    // The world space is oriented differently from the GUI space, adjust for that here.
    // Return 0 as the third parameter so the results can easily be added to a Vector.
    return plottedY, -plottedX, 0
    
end

local gLocationItems = {}

function GUIMinimap:Initialize()

    self.locationItems = { }
    self.timeMapOpened = 0
    self.stencilFunc = GUIItem.Always
    self.iconFileName = kIconFileName
    self.staticBlips = { }
    self.inUseStaticBlipCount = 0
    self.reuseDynamicBlips = { }
    self.inuseDynamicBlips = { }
    self.scanColor = Color(kScanColor.r, kScanColor.g, kScanColor.b, kScanColor.a)
    self.scanSize = Vector(0, 0, 0)
    self.highlightWorldColor = Color(0, 1, 0, 1)
    self.highlightWorldSize = Vector(0, 0, 0)
    self.etherealGateColor = Color(kEtherealGateColor.r, kEtherealGateColor.g, kEtherealGateColor.b, kEtherealGateColor.a)
    self.blipSizeTable = { }
    self.minimapConnections = { }

    self:SetScale(1) // Compute plot to map transformation
    self:SetBlipScale(1) // Compute blipSizeTable
    self.blipSizeTable[kBlipSizeType.Scan] = self.scanSize
    self.blipSizeTable[kBlipSizeType.HighlightWorld] = self.highlightWorldSize
    
    // Initialize blip info lookup table
    local blipInfoTable = {}
    for blipType, _ in ipairs(kMinimapBlipType) do
        local blipInfo = kBlipInfo[blipType]
        local iconCol, iconRow = GetSpriteGridByClass((blipInfo and blipInfo[4]) or EnumToString(kMinimapBlipType, blipType), kClassToGrid)
        // This looks strange, but the function returned from loadstring is faster than using unpack on a table or accessing the elements of a table manually.
        local texCoordsFunc = loadstring(string.format("return %.f, %.f, %.f, %.f", GUIGetSprite(iconCol, iconRow, kIconWidth, kIconHeight)))
        if blipInfo then
          blipInfoTable[blipType] = { texCoordsFunc, blipInfo[1], blipInfo[2], blipInfo[3] }
        else
          blipInfoTable[blipType] = { texCoordsFunc, kBlipColorType.Team, kBlipSizeType.Normal, kStaticBlipsLayer }
        end
    end
    self.blipInfoTable = blipInfoTable
    
    // Generate blip color lookup table
    local blipColorTable = {}
    for blipTeam, _ in ipairs(kMinimapBlipTeam) do
        local colorTable = {}
        colorTable[kBlipColorType.Team] = kTeamColors[blipTeam]
        colorTable[kBlipColorType.Infestation] = kInfestationColor[blipTeam]
        colorTable[kBlipColorType.InfestationDying] = kInfestationDyingColor[blipTeam]
        colorTable[kBlipColorType.Waypoint] = kWaypointColor
        colorTable[kBlipColorType.PowerPoint] = kPowerNodeColor
        colorTable[kBlipColorType.DestroyedPowerPoint] = kDestroyedPowerNodeColor
        colorTable[kBlipColorType.Scan] = self.scanColor
        colorTable[kBlipColorType.HighlightWorld] = self.highlightWorldColor
        colorTable[kBlipColorType.Drifter] = kDrifterColor
        colorTable[kBlipColorType.MAC] = kMACColor
        colorTable[kBlipColorType.EtherealGate] = self.etherealGateColor
        blipColorTable[blipTeam] = colorTable
    end
    self.blipColorTable = blipColorTable

    self:InitializeBackground()
    
    self.minimap = GUIManager:CreateGraphicItem()
    self.minimap:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.minimap:SetPosition(Vector(0, 0, 0))
    self.minimap:SetSize(Vector(GUIMinimap.kBackgroundWidth, GUIMinimap.kBackgroundHeight, 0))
    self.minimap:SetTexture("maps/overviews/" .. Shared.GetMapName() .. ".tga")
    self.minimap:SetColor(kOverviewColor)
    self.background:AddChild(self.minimap)
    
    // Used for commander / spectator.
    self:InitializeCameraLines()
    // Used for normal players.
    self:InitializePlayerIcon()
    
    // initialize commander ping
    self.commanderPing = GUICreateCommanderPing()
    self.commanderPing.Frame:SetAnchor(GUIItem.Center, GUIItem.Middle)
    self.commanderPing.Frame:SetLayer(kPingLayer)
    self.minimap:AddChild(self.commanderPing.Frame)
    
end

function GUIMinimap:InitializeBackground()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(GUIMinimap.kBackgroundWidth, GUIMinimap.kBackgroundHeight, 0))
    self.background:SetPosition(Vector(0, 0, 0))
    self.background:SetColor(Color(1, 1, 1, 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetLayer(kGUILayerMinimap)
    
    // Non-commander players assume the map isn't visible by default.
    if not PlayerUI_IsACommander() then
        self.background:SetIsVisible(false)
    end

end

function GUIMinimap:InitializeCameraLines()

    self.cameraLines = GUIManager:CreateLinesItem()
    self.cameraLines:SetAnchor(GUIItem.Center, GUIItem.Middle)
    self.cameraLines:SetLayer(kPlayerIconLayer)
    self.minimap:AddChild(self.cameraLines)
    
end

function GUIMinimap:InitializePlayerIcon()
    
    self.playerIcon = GUIManager:CreateGraphicItem()
    self.playerIcon:SetSize(kPlayerIconSize)
    self.playerIcon:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.playerIcon:SetTexture(self.iconFileName)
    iconCol, iconRow = GetSpriteGridByClass(PlayerUI_GetPlayerClass(), kClassToGrid)
    self.playerIcon:SetTexturePixelCoordinates(GUIGetSprite(iconCol, iconRow, kIconWidth, kIconHeight))
    self.playerIcon:SetIsVisible(false)
    self.playerIcon:SetLayer(kPlayerIconLayer)
    self.minimap:AddChild(self.playerIcon)

    self.playerShrinkingArrow = GUIManager:CreateGraphicItem()
    self.playerShrinkingArrow:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.playerShrinkingArrow:SetTexture(kLargePlayerArrowFileName)
    self.playerShrinkingArrow:SetLayer(kPlayerIconLayer)
    self.playerIcon:AddChild(self.playerShrinkingArrow)
    
end

local function SetupLocationTextItem(item)

    item:SetFontSize(kLocationFontSize)
    item:SetFontIsBold(false)
    item:SetFontName(kLocationFontName)
    item:SetAnchor(GUIItem.Middle, GUIItem.Center)
    item:SetTextAlignmentX(GUIItem.Align_Center)
    item:SetTextAlignmentY(GUIItem.Align_Center)
    item:SetLayer(kLocationNameLayer)

end

local function SetLocationTextPosition( item, mapPos )

    item.text:SetPosition( Vector(mapPos.x, mapPos.y, 0) )
    local offset = 1

end

function OnCommandSetMapLocationColor(r, g, b, a)

    if gLocationItems ~= nil then

        for _, locationItem in ipairs(gLocationItems) do
            locationItem.text:SetColor( Color(tonumber(r)/255, tonumber(g)/255, tonumber(b)/255, tonumber(a)/255) )
        end

    end

end


function GUIMinimap:InitializeLocationNames()

    self:UninitializeLocationNames()
    local locationData = PlayerUI_GetLocationData()
    
    // Average the position of same named locations so they don't display
    // multiple times.
    local multipleLocationsData = { }
    for i, location in ipairs(locationData) do
    
        // Filter out the ready room.
        if location.Name ~= "Ready Room" then
        
            local locationTable = multipleLocationsData[location.Name]
            if locationTable == nil then
            
                locationTable = { }
                multipleLocationsData[location.Name] = locationTable
                
            end
            table.insert(locationTable, location.Origin)
            
        end
        
    end
    
    local uniqueLocationsData = { }
    for name, origins in pairs(multipleLocationsData) do
    
        local averageOrigin = Vector(0, 0, 0)
        table.foreachfunctor(origins, function (origin) averageOrigin = averageOrigin + origin end)
        table.insert(uniqueLocationsData, { Name = name, Origin = averageOrigin / table.count(origins) })
        
    end
    
    for i, location in ipairs(uniqueLocationsData) do

        local posX, posY = PlotToMap(self, location.Origin.x, location.Origin.z)

        // Locations only supported on the big mode.
        local locationText = GUIManager:CreateTextItem()
        SetupLocationTextItem(locationText)
        locationText:SetColor(Color(1.0, 1.0, 1.0, 0.65))
        locationText:SetText(location.Name)
        locationText:SetPosition( Vector(posX, posY, 0) )

        self.minimap:AddChild(locationText)

        local locationItem = {text = locationText, origin = location.Origin}
        table.insert(self.locationItems, locationItem)

    end

    gLocationItems = self.locationItems

end

function GUIMinimap:UninitializeLocationNames()

    for _, locationItem in ipairs(self.locationItems) do
        GUI.DestroyItem(locationItem.text)
    end
    
    self.locationItems = {}

end

function GUIMinimap:Uninitialize()

    if self.background then
        GUI.DestroyItem(self.background)
        self.background = nil
    end
    
end

local function UpdatePlayerIcon(self)

    PROFILE("GUIMinimap:UpdatePlayerIcon")

    if PlayerUI_IsOverhead() and not PlayerUI_IsCameraAnimated() then -- Handle overhead viewplane points

        self.playerIcon:SetIsVisible(false)
        self.cameraLines:SetIsVisible(true)
        
        local topLeftPoint, topRightPoint, bottomLeftPoint, bottomRightPoint = OverheadUI_ViewFarPlanePoints()
        if topLeftPoint == nil then
            return
        end
        
        topLeftPoint = Vector(PlotToMap(self, topLeftPoint.x, topLeftPoint.z))
        topRightPoint = Vector(PlotToMap(self, topRightPoint.x, topRightPoint.z))
        bottomLeftPoint = Vector(PlotToMap(self, bottomLeftPoint.x, bottomLeftPoint.z))
        bottomRightPoint = Vector(PlotToMap(self, bottomRightPoint.x, bottomRightPoint.z))
        
        self.cameraLines:ClearLines()
        local lineColor = Color(1, 1, 1, 1)
        self.cameraLines:AddLine(topLeftPoint, topRightPoint, lineColor)
        self.cameraLines:AddLine(topRightPoint, bottomRightPoint, lineColor)
        self.cameraLines:AddLine(bottomRightPoint, bottomLeftPoint, lineColor)
        self.cameraLines:AddLine(bottomLeftPoint, topLeftPoint, lineColor)

    elseif PlayerUI_IsAReadyRoomPlayer() then
    
        // No icons for ready room players.
        self.cameraLines:SetIsVisible(false)
        self.playerIcon:SetIsVisible(false)

    else
    
        // Draw a player icon representing this player's position.
        local playerOrigin = PlayerUI_GetPositionOnMinimap()
        local playerRotation = PlayerUI_GetMinimapPlayerDirection()

        local posX, posY = PlotToMap(self, playerOrigin.x, playerOrigin.z)

        self.cameraLines:SetIsVisible(false)
        self.playerIcon:SetIsVisible(true)
        
        local playerIconColor = self.playerIconColor
        if playerIconColor ~= nil then
            playerIconColor = Color(playerIconColor.r, playerIconColor.g, playerIconColor.b, playerIconColor.a)
        elseif PlayerUI_IsOnMarineTeam() then
            playerIconColor = Color(kMarineTeamColorFloat)
        elseif PlayerUI_IsOnAlienTeam() then
            playerIconColor = Color(kAlienTeamColorFloat)
        else
            playerIconColor = Color(1, 1, 1, 1)
        end

        local animFraction = 1 - Clamp((Shared.GetTime() - self.timeMapOpened) / 0.5, 0, 1)
        playerIconColor.r = playerIconColor.r + animFraction
        playerIconColor.g = playerIconColor.g + animFraction
        playerIconColor.b = playerIconColor.b + animFraction
        playerIconColor.a = playerIconColor.a + animFraction
        
        local blipScale = self.blipScale
        local overLaySize = kShrinkingArrowInitSize * (animFraction * blipScale)
        local playerIconSize = Vector(kBlipSize * blipScale, kBlipSize * blipScale, 0)
        
        self.playerShrinkingArrow:SetSize(overLaySize)
        self.playerShrinkingArrow:SetPosition(-overLaySize * 0.5)
        local shrinkerColor = Color(playerIconColor.r, playerIconColor.g, playerIconColor.b, 0.35)
        self.playerShrinkingArrow:SetColor(shrinkerColor)

        self.playerIcon:SetSize(playerIconSize)        
        self.playerIcon:SetColor(playerIconColor)

        // move the background instead of the playericon in zoomed mode
        if self.moveBackgroundMode then
            local size = self.minimap:GetSize()
            self.background:SetPosition(Vector(-posX + size.x * -0.5, -posY + size.y * -0.5, 0))
        end

        posX = posX - playerIconSize.x * 0.5
        posY = posY - playerIconSize.y * 0.5
        
        self.playerIcon:SetPosition(Vector(posX, posY, 0))
        
        local rotation = Vector(0, 0, playerRotation)
        
        self.playerIcon:SetRotation(rotation)
        self.playerShrinkingArrow:SetRotation(rotation)

        local playerClass = PlayerUI_GetPlayerClass()
        if self.playerClass ~= playerClass then

            local iconCol, iconRow = GetSpriteGridByClass(playerClass, kClassToGrid)
            self.playerIcon:SetTexturePixelCoordinates(GUIGetSprite(iconCol, iconRow, kIconWidth, kIconHeight))
            self.playerClass = playerClass

        end

    end
    
end

local function PulseRed()

    local anim = (math.cos(Shared.GetTime() * 10) + 1) * 0.5
    local color = Color()
    
    color.r = 1
    color.g = anim
    color.b = anim
    
    return color

end

// Simple optimization to prevent unnecessary Vector creation inside the function.
local blipPos = Vector(0, 0, 0)
local blipRotation = Vector(0, 0, 0)
local function UpdateStaticBlips(self, deltaTime)

    PROFILE("GUIMinimap:UpdateStaticBlips")
    
    local staticBlips = PlayerUI_GetStaticMapBlips()
    local blipItemCount = 10
    local numBlips = table.count(staticBlips) / blipItemCount
    
    local staticBlipItems = self.staticBlips
    // Hide unused static blip items.
    for i = numBlips + 1, self.inUseStaticBlipCount do
        staticBlipItems[i]:SetIsVisible(false)
    end
    
    // Create all of the blips we'll need.
    for i = #staticBlipItems, numBlips do
    
        local addedBlip = GUIManager:CreateGraphicItem()
        addedBlip:SetAnchor(GUIItem.Center, GUIItem.Middle)
        addedBlip:SetLayer(kStaticBlipsLayer)
        addedBlip:SetStencilFunc(self.stencilFunc)
        addedBlip:SetTexture(self.iconFileName)
        self.minimap:AddChild(addedBlip)
        table.insert(staticBlipItems, addedBlip)
        
    end
    
    // Make sure all blips we'll need are visible.
    for i = self.inUseStaticBlipCount + 1, numBlips do
        staticBlipItems[i]:SetIsVisible(true)
    end
    
    // Update scan blip size and color.
    local scanAnimFraction = (Shared.GetTime() % kScanAnimDuration) / kScanAnimDuration
    // do not change table reference
    self.scanColor.a = 1 - scanAnimFraction
    local blipSize = self.blipSizeTable[kBlipSizeType.Normal]
    local blipScale = (0.5 + scanAnimFraction) * 2
    // do not change table reference
    self.scanSize.x = blipSize.x * blipScale
    // do not change table reference
    self.scanSize.y = blipSize.y * blipScale
    
    local highlightPos, highlightTime = GetHighlightPosition()
    if highlightTime then
    
        local createAnimFraction = 1 - Clamp((Shared.GetTime() - highlightTime) / 1.5, 0, 1)
        local sizeAnim = (1 + math.sin(Shared.GetTime() * 6)) * 0.25 + 2
    
        local blipScale = createAnimFraction * 15 + sizeAnim

        self.highlightWorldSize.x = blipSize.x * blipScale
        self.highlightWorldSize.y = blipSize.y * blipScale
        
        self.highlightWorldColor.a = 0.7 + 0.2 * math.sin(Shared.GetTime() * 5) + createAnimFraction
    
    end
    
    local etherealGateAnimFraction = 0.25 + (1 + math.sin(Shared.GetTime() * 10)) * 0.5 * 0.75
    self.etherealGateColor.a = etherealGateAnimFraction
    
    // spectating?
    local spectating = Client.GetLocalPlayer():GetTeamNumber() == kSpectatorIndex
    local playerTeam = Client.GetLocalPlayer():GetTeamNumber()
    
    if playerTeam == kMarineTeamType then
        playerTeam = kMinimapBlipTeam.Marine
    elseif playerTeam == kAlienTeamType then
        playerTeam = kMinimapBlipTeam.Alien
    end
    
    // Update each blip.
    local blipInfoTable, blipSizeTable, blipColorTable = self.blipInfoTable, self.blipSizeTable, self.blipColorTable
    local currentIndex = 1
    local GUIItemSetLayer = GUIItem.SetLayer
    local GUIItemSetTexturePixelCoordinates = GUIItem.SetTexturePixelCoordinates
    local GUIItemSetSize = GUIItem.SetSize
    local GUIItemSetPosition = GUIItem.SetPosition
    local GUIItemSetRotation = GUIItem.SetRotation
    local GUIItemSetColor = GUIItem.SetColor
    for i = 1, numBlips do

        local xPos, yPos = PlotToMap(self, staticBlips[currentIndex], staticBlips[currentIndex + 1])
        local rotation = staticBlips[currentIndex + 2]
        local blipType = staticBlips[currentIndex + 5]
        local blipTeam = staticBlips[currentIndex + 6]
        local underAttack = staticBlips[currentIndex + 7]
        local isSteamFriend = staticBlips[currentIndex + 8]
        local isHallucination = staticBlips[currentIndex + 9]
        
        local blip = staticBlipItems[i]
        local blipInfo = blipInfoTable[blipType]
        
        local blipSize = blipSizeTable[blipInfo[3]]
        blipPos.x = xPos - blipSize.x * 0.5
        blipPos.y = yPos - blipSize.y * 0.5
        blipRotation.z = rotation
        
        GUIItemSetLayer(blip, blipInfo[4])
        GUIItemSetTexturePixelCoordinates(blip, blipInfo[1]())
        GUIItemSetSize(blip, blipSize)
        GUIItemSetPosition(blip, blipPos)
        GUIItemSetRotation(blip, blipRotation)
        local blipColor = blipColorTable[blipTeam][blipInfo[2]]
		
		// Fix inactive buildings not showing up under attack in the minimap
		// Just assign the "correct" team after we got the color
		if blipTeam == kMinimapBlipTeam.InactiveMarine then
			blipTeam = kMinimapBlipTeam.Marine
		elseif blipTeam == kMinimapBlipTeam.InactiveAlien then
			blipTeam = kMinimapBlipTeam.Alien
		end
        
        if blipTeam == playerTeam or spectating then
        
            if isHallucination then
                blipColor = kHallucinationColor
            elseif underAttack then
                blipColor = PulseRed()
            end
            
        end
        
        GUIItemSetColor(blip, blipColor)
        
        currentIndex = currentIndex + blipItemCount
        
    end
    self.inUseStaticBlipCount = numBlips
    
end

local function GetFreeDynamicBlip(self, xPos, yPos, blipType)

    local returnBlip
    if table.count(self.reuseDynamicBlips) > 0 then
    
        returnBlip = table.remove(self.reuseDynamicBlips)
        table.insert(self.inuseDynamicBlips, returnBlip)
        
    else
    
        
        local returnBlipItem = GUIManager:CreateGraphicItem()
        returnBlipItem:SetLayer(kDynamicBlipsLayer) // Make sure these draw a layer above the minimap so they are on top.
        returnBlipItem:SetTexture(kBlipTexture)
        returnBlipItem:SetBlendTechnique(GUIItem.Add)
        returnBlipItem:SetAnchor(GUIItem.Center, GUIItem.Middle)
        self.minimap:AddChild(returnBlipItem)
        
        returnBlip = { Item = returnBlipItem }
        table.insert(self.inuseDynamicBlips, returnBlip)
        
    end
    
    returnBlip.X = xPos
    returnBlip.Y = yPos
    returnBlip.Type = blipType
    
    local returnBlipItem = returnBlip.Item
    
    returnBlipItem:SetIsVisible(true)
    returnBlipItem:SetColor(Color(1, 1, 1, 1))
    returnBlipItem:SetPosition(Vector(PlotToMap(self, xPos, yPos)))
    GUISetTextureCoordinatesTable(returnBlipItem, kBlipTextureCoordinates[blipType])
    returnBlipItem:SetStencilFunc(self.stencilFunc)
    
    return returnBlip
    
end

local function AddDynamicBlip(self, xPos, yPos, blipType)

    /**
     * Blip types - kAlertType
     * 
     * 0 - Attack
     * Attention-getting spinning squares that start outside the minimap and spin down to converge to point 
     * on map, continuing to draw at point for a few seconds).
     * 
     * 1 - Info
     * Research complete, area blocked, structure couldn't be built, etc. White effect, not as important to
     * grab your attention right away).
     * 
     * 2 - Request
     * Soldier needs ammo, asking for order, etc. Should be yellow or green effect that isn't as 
     * attention-getting as the under attack. Should draw for a couple seconds.)
     */
    
    if blipType == kAlertType.Attack then
    
        addedBlip = GetFreeDynamicBlip(self, xPos, yPos, blipType)
        addedBlip.Item:SetSize(Vector(0, 0, 0))
        addedBlip.Time = Shared.GetTime() + kAttackBlipTime
        
    end
    
end

local function RemoveDynamicBlip(self, blip)

    blip.Item:SetIsVisible(false)
    table.removevalue(self.inuseDynamicBlips, blip)
    table.insert(self.reuseDynamicBlips, blip)
    
end

local function UpdateAttackBlip(self, blip)

    local blipLifeRemaining = blip.Time - Shared.GetTime()
    local blipItem = blip.Item
    // Fade in.
    if blipLifeRemaining >= kAttackBlipFadeInTime then
    
        local fadeInAmount = ((kAttackBlipTime - blipLifeRemaining) / (kAttackBlipTime - kAttackBlipFadeInTime))
        blipItem:SetColor(Color(1, 1, 1, fadeInAmount))
        
    else
        blipItem:SetColor(Color(1, 1, 1, 1))
    end
    
    // Fade out.
    if blipLifeRemaining <= kAttackBlipFadeOutTime then
    
        if blipLifeRemaining <= 0 then
            return true
        end
        blipItem:SetColor(Color(1, 1, 1, blipLifeRemaining / kAttackBlipFadeOutTime))
        
    end
    
    local pulseAmount = (math.sin(blipLifeRemaining * kAttackBlipPulseSpeed) + 1) / 2
    local blipSize = LerpGeneric(kAttackBlipMinSize, kAttackBlipMaxSize / 2, pulseAmount)
    
    blipItem:SetSize(blipSize)
    // Make sure it is always centered.
    local sizeDifference = kAttackBlipMaxSize - blipSize
    local xOffset = (sizeDifference.x / 2) - kAttackBlipMaxSize.x / 2
    local yOffset = (sizeDifference.y / 2) - kAttackBlipMaxSize.y / 2
    local plotX, plotY = PlotToMap(self, blip.X, blip.Y)
    blipItem:SetPosition(Vector(plotX + xOffset, plotY + yOffset, 0))
    
    // Not done yet.
    return false
    
end

local function UpdateDynamicBlips(self)

    PROFILE("GUIMinimap:UpdateDynamicBlips")
    
    local newDynamicBlips = CommanderUI_GetDynamicMapBlips()
    local blipItemCount = 3
    local numBlips = table.count(newDynamicBlips) / blipItemCount
    local currentIndex = 1
    
    while numBlips > 0 do
    
        local blipType = newDynamicBlips[currentIndex + 2]
        AddDynamicBlip(self, newDynamicBlips[currentIndex], newDynamicBlips[currentIndex + 1], blipType)
        currentIndex = currentIndex + blipItemCount
        numBlips = numBlips - 1
        
    end
    
    local removeBlips = { }
    for _, blip in ipairs(self.inuseDynamicBlips) do
    
        if blip.Type == kAlertType.Attack then
        
            if UpdateAttackBlip(self, blip) then
                table.insert(removeBlips, blip)
            end
            
        end
    end
    
    for _, blip in ipairs(removeBlips) do
        RemoveDynamicBlip(self, blip)
    end
    
end

local function UpdateMapClick(self)

    if PlayerUI_IsOverhead() then
    
        // Don't teleport if the command is dragging a selection or pinging.
        if PlayerUI_IsACommander() and (not CommanderUI_GetUIClickable() or GetCommanderPingEnabled()) then
            return
        end
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if self.mouseButton0Down then
        
            local containsPoint, withinX, withinY = GUIItemContainsPoint(self.minimap, mouseX, mouseY)
            if containsPoint then
            
                local minimapSize = self:GetMinimapSize()
                local backgroundScreenPosition = self.minimap:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight())
                
                local cameraPosition = Vector(mouseX, mouseY, 0)
                
                cameraPosition.x = cameraPosition.x - backgroundScreenPosition.x
                cameraPosition.y = cameraPosition.y - backgroundScreenPosition.y
                
                local horizontalScale = OverheadUI_MapLayoutHorizontalScale()
                local verticalScale = OverheadUI_MapLayoutVerticalScale()
                
                local moveX = (cameraPosition.x / minimapSize.x) * horizontalScale
                local moveY = (cameraPosition.y / minimapSize.y) * verticalScale
                
                OverheadUI_MapMoveView(moveX, moveY)
                
            end
            
        end
        
    end
    
end

local function UpdateConnections(self)

    local mapConnectors = Shared.GetEntitiesWithClassname("MapConnector")
    local numConnectors = 0
    for index, connector in ientitylist(mapConnectors) do

        if not self.minimapConnections[index] then
            self.minimapConnections[index] = GUIMinimapConnection()
            self.minimapConnections[index]:SetStencilFunc(self.stencilFunc)
        end
        
        local startPoint = Vector(PlotToMap(self, connector:GetOrigin().x, connector:GetOrigin().z))
        local endPoint = Vector(PlotToMap(self, connector:GetEndPoint().x, connector:GetEndPoint().z))
        
        self.minimapConnections[index]:Setup(startPoint, endPoint, self.minimap)
        
        numConnectors = numConnectors + 1
        
    end
    
    local numMinimapConnections = #self.minimapConnections    
    if numConnectors < numMinimapConnections then
    
        for i = 1, numMinimapConnections - numConnectors do
        
            local lastIndex = #self.minimapConnections
            local minimapConnection = self.minimapConnections[lastIndex]
            minimapConnection:Uninitialize()
            self.minimapConnections[lastIndex] = nil
        
        end
    
    end

    //Print("num minimap connections %s", ToString(#self.minimapConnections))

end

function GUIMinimap:Update(deltaTime)

    PROFILE("GUIMinimap:Update")
    
    if self.background:GetIsVisible() then
    
        UpdatePlayerIcon(self)
        
        UpdateStaticBlips(self, deltaTime)
        
        UpdateDynamicBlips(self)
        
        UpdateMapClick(self)
        
        UpdateConnections(self)
        
        // update commander ping
        if self.commanderPing then
        
            local timeSincePing, position, distance = PlayerUI_GetCommanderPingInfo(true)
            local posX, posY = PlotToMap(self, position.x, position.z)
            self.commanderPing.Frame:SetPosition(Vector(posX, posY, 0))
            self.commanderPing.Frame:SetIsVisible(timeSincePing <= kCommanderPingDuration)
            GUIAnimateCommanderPing(self.commanderPing.Mark, self.commanderPing.Border, self.commanderPing.Location, kCommanderPingMinimapSize, timeSincePing, Color(1, 0, 0, 1), Color(1, 1, 1, 1))
            
        end
        
    end
    
end

function GUIMinimap:GetMinimapSize()
    return Vector(GUIMinimap.kBackgroundWidth * self.scale, GUIMinimap.kBackgroundHeight * self.scale, 0)
end

// Shows or hides the big map.
function GUIMinimap:ShowMap(showMap)

    if self.background:GetIsVisible() ~= showMap then
    
        self.background:SetIsVisible(showMap)
        if showMap then
        
            self.timeMapOpened = Shared.GetTime()
            self:Update(0)
            
        end
        
    end
    
end

function GUIMinimap:OnLocalPlayerChanged(newPlayer)
    self:ShowMap(false)
end

function GUIMinimap:SendKeyEvent(key, down)

    if PlayerUI_IsOverhead() then
    
        local mouseX, mouseY = Client.GetCursorPosScreen()
        local containsPoint, withinX, withinY = GUIItemContainsPoint(self.minimap, mouseX, mouseY)
        
        if key == InputKey.MouseButton0 then
            self.mouseButton0Down = down
        elseif key == InputKey.MouseButton1 then
        
            if down and containsPoint then
            
                if self.buttonsScript then
                
                    if PlayerUI_IsACommander() then
                    
                        // Cancel just in case the user had a targeted action selected before this press.
                        CommanderUI_ActionCancelled()
                        self.buttonsScript:SetTargetedButton(nil)
                        
                    end
                    
                end
                
                OverheadUI_MapClicked(withinX / self:GetMinimapSize().x, withinY / self:GetMinimapSize().y, 1, nil)
                return true
                
            end
            
        end
        
    end
    
    return false

end

function GUIMinimap:ContainsPoint(pointX, pointY)
    return GUIItemContainsPoint(self.background, pointX, pointY) or GUIItemContainsPoint(self.minimap, pointX, pointY)
end

function GUIMinimap:GetBackground()
    return self.background
end

function GUIMinimap:GetMinimapItem()
    return self.minimap
end

function GUIMinimap:SetButtonsScript(setButtonsScript)
    self.buttonsScript = setButtonsScript
end

function GUIMinimap:SetLocationNamesEnabled(enabled)
    for _, locationItem in ipairs(self.locationItems) do
        locationItem.text:SetIsVisible(enabled)
    end
end

function GUIMinimap:SetScale(scale)
    if scale ~= self.scale then
        self.scale = scale
        
        // compute map to minimap transformation matrix
        local xFactor = 2 * self.scale
        local mapRatio = ConditionalValue(Client.minimapExtentScale.z > Client.minimapExtentScale.x, Client.minimapExtentScale.z / Client.minimapExtentScale.x, Client.minimapExtentScale.x / Client.minimapExtentScale.z)
        local zFactor = xFactor / mapRatio
        self.plotToMapConstX = -Client.minimapExtentOrigin.x
        self.plotToMapConstY = -Client.minimapExtentOrigin.z
        self.plotToMapLinX = GUIMinimap.kBackgroundHeight / (Client.minimapExtentScale.x / xFactor)
        self.plotToMapLinY = GUIMinimap.kBackgroundWidth / (Client.minimapExtentScale.z / zFactor)
        
        // update overview size
        if self.minimap then
          local size = Vector(GUIMinimap.kBackgroundWidth * scale, GUIMinimap.kBackgroundHeight * scale, 0)
          self.minimap:SetSize(size)
        end

        // reposition location names
        if self.locationItems then
          for _, locationItem in ipairs(self.locationItems) do
            local mapPos = Vector(PlotToMap( self, locationItem.origin.x, locationItem.origin.z ))
            SetLocationTextPosition( locationItem, mapPos )
          end
        end
      
    end
end

function GUIMinimap:GetScale()
    return self.scale
end

function GUIMinimap:SetBlipScale(blipScale)

    if blipScale ~= self.blipScale then
    
        self.blipScale = blipScale
    
        local blipSizeTable = self.blipSizeTable
        local blipSize = Vector(kBlipSize, kBlipSize, 0)
        blipSizeTable[kBlipSizeType.Normal] = blipSize * (0.7 * blipScale)
        blipSizeTable[kBlipSizeType.TechPoint] = blipSize * blipScale
        blipSizeTable[kBlipSizeType.Infestation] = blipSize * (2 * blipScale)
        blipSizeTable[kBlipSizeType.Egg] = blipSize * (0.7 * 0.5 * blipScale)
        blipSizeTable[kBlipSizeType.Worker] = blipSize * (blipScale)
        blipSizeTable[kBlipSizeType.EtherealGate] = blipSize * (1.5 * blipScale)
        blipSizeTable[kBlipSizeType.Waypoint] = blipSize * (1.5 * blipScale)
        
    end
    
end

function GUIMinimap:GetBlipScale(blipScale)
    return self.blipScale
end

function GUIMinimap:SetMoveBackgroundEnabled(enabled)
    self.moveBackgroundMode = enabled
end

function GUIMinimap:SetStencilFunc(stencilFunc)

    self.stencilFunc = stencilFunc
    
    self.minimap:SetStencilFunc(stencilFunc)
    self.commanderPing.Mark:SetStencilFunc(stencilFunc)
    self.commanderPing.Border:SetStencilFunc(stencilFunc)
    
    for _, blip in ipairs(self.inuseDynamicBlips) do
        blip.Item:SetStencilFunc(stencilFunc)
    end
    
    for _, blip in ipairs(self.staticBlips) do
        blip:SetStencilFunc(stencilFunc)
    end
    
    for _, connectionLine in ipairs(self.minimapConnections) do
        connectionLine:SetStencilFunc(stencilFunc)
    end
    
end

function GUIMinimap:SetPlayerIconColor(color)
    self.playerIconColor = color
end

function GUIMinimap:SetIconFileName(fileName)
    local iconFileName = ConditionalValue(fileName, fileName, kIconFileName)
    self.iconFileName = iconFileName
    
    self.playerIcon:SetTexture(iconFileName)
    for _, blip in ipairs(self.staticBlips) do
        blip:SetTexture(iconFileName)
    end
    
end

Event.Hook("Console_setmaplocationcolor", OnCommandSetMapLocationColor)
