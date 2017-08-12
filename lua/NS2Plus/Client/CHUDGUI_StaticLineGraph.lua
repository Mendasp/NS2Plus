-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\graphs\LineGraph.lua
--
-- Created by: Jon Hughes (jon@jhuze.com)
--
-- LineGraph!
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'CHUDGUI_StaticLineGraph'

local kTitleFontName = Fonts.kAgencyFB_Medium
local kFontName = Fonts.kAgencyFB_Small
local kFontScale = GUILinearScale(Vector(1,1,0))
local gridColor = Color(1,1,1,0.1)
local fontColor = Color(1,1,1,1)
local xPadding = GUILinearScale(Vector(0,10,0))
local yPadding = GUILinearScale(Vector(-10,0,0))

local function AddLine(self, linesTable, previous, current, color)
    local direction = GetNormalizedVector(previous - current)
    local rotation = math.atan2(direction.x, direction.y)
    if rotation < 0 then
        rotation = rotation + math.pi * 2
    end

    rotation = rotation + math.pi * 0.5

    local delta = current - previous
    local length = math.sqrt(delta.x ^ 2 + delta.y ^ 2)
    
    local item = GUIManager:CreateGraphicItem()
    item:SetColor(color)
    item:SetAnchor(GUIItem.Left, GUIItem.Top)
    if self.stencilFunc then
        item:SetStencilFunc(self.stencilFunc)
    end
    item:SetSize(Vector(length, 2, 0))
    item:SetPosition(previous)
    item:SetRotationOffset(Vector(-length, 0, 0))
    item:SetRotation(Vector(0, 0, rotation))
    
    self.graphBackground:AddChild(item)
    
    table.insert(linesTable, item)
end

local function ClearLines(linesTable)
    for _, item in ipairs(linesTable) do
        GUI.DestroyItem(item)
    end
end

function CHUDGUI_StaticLineGraph:Initialize()

    self.max = Vector(-999999999, -999999999, 0)
    self.min = Vector(999999999, 999999999, 0)

    self.graphSize = Vector(300,150,0)
    self.gridSpacing = Vector(1,1,0)
    self.xAxisIsTime = false
    self.xAxisToBounds = false
    self.stencilFunc = nil

    self.lines = {}
    self.colors = {}

    self.xActiveNames = {}
    self.yActiveNames = {}
    self.reuseNames = {}

    self.graphBackground = GUIManager:CreateGraphicItem()
    self.graphBackground:SetSize(self.graphSize)
    self.graphBackground:SetColor(Color(0,0,0.1,0.9))
    self.graphBackground:SetLayer(kGUILayerInsight)

    self.titleItem = GUIManager:CreateTextItem()
    self.titleItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.titleItem:SetFontName(kTitleFontName)
    self.titleItem:SetScale(kFontScale)
    GUIMakeFontScale(self.titleItem)
    self.titleItem:SetTextAlignmentX(GUIItem.Align_Center)
    self.titleItem:SetTextAlignmentY(GUIItem.Align_Max)
    self.titleItem:SetColor(fontColor)
    self.graphBackground:AddChild(self.titleItem)
    
    self.xLabelItem = GUIManager:CreateTextItem()
    self.xLabelItem:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.xLabelItem:SetFontName(kFontName)
    self.xLabelItem:SetScale(kFontScale)
    GUIMakeFontScale(self.xLabelItem)
    self.xLabelItem:SetTextAlignmentX(GUIItem.Align_Center)
    self.xLabelItem:SetTextAlignmentY(GUIItem.Align_Min)
    self.xLabelItem:SetColor(fontColor)
    self.graphBackground:AddChild(self.xLabelItem)
    
    self.yLabelItem = GUIManager:CreateTextItem()
    self.yLabelItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.yLabelItem:SetFontName(kFontName)
    self.yLabelItem:SetScale(kFontScale)
    GUIMakeFontScale(self.yLabelItem)
    self.yLabelItem:SetTextAlignmentX(GUIItem.Align_Max)
    self.yLabelItem:SetTextAlignmentY(GUIItem.Align_Center)
    self.yLabelItem:SetColor(fontColor)
    self.graphBackground:AddChild(self.yLabelItem)

    self.xGridLines = {}
    self.yGridLines = {}
    self.plotLines = {}
    
end

function CHUDGUI_StaticLineGraph:OnResolutionChanged(oldX, oldY, newX, newY)
    kFontScale = GUILinearScale(Vector(1,1,0))
    xPadding = GUILinearScale(Vector(0,10,0))
    yPadding = GUILinearScale(Vector(-10,0,0))
end

function CHUDGUI_StaticLineGraph:SetStencilFunc(stencilFunc)
    self.stencilFunc = stencilFunc
    
    self.graphBackground:SetStencilFunc(stencilFunc)
    self.titleItem:SetStencilFunc(stencilFunc)
    self.xLabelItem:SetStencilFunc(stencilFunc)
    self.yLabelItem:SetStencilFunc(stencilFunc)
    
    for _, item in ipairs(self.xGridLines) do
        item:SetStencilFunc(stencilFunc)
    end
    
    for _, item in ipairs(self.yGridLines) do
        item:SetStencilFunc(stencilFunc)
    end
    
    for _, item in ipairs(self.plotLines) do
        item:SetStencilFunc(stencilFunc)
    end
    
    for _, item in ipairs(self.xActiveNames) do
        item:SetStencilFunc(stencilFunc)
    end
    
    for _, item in ipairs(self.yActiveNames) do
        item:SetStencilFunc(stencilFunc)
    end
    
    for _, item in ipairs(self.reuseNames) do
        item:SetStencilFunc(stencilFunc)
    end
end

function CHUDGUI_StaticLineGraph:StartLine(index, lineColor)

    self.lines[index] = {}
    self.colors[index] = lineColor

end
function CHUDGUI_StaticLineGraph:SetPoints(index, points, noRefresh, preserveBounds)

    self.lines[index] = points

end

function CHUDGUI_StaticLineGraph:GiveParent(p)
    p:AddChild(self.graphBackground)
end
function CHUDGUI_StaticLineGraph:SetIsVisible(b)
    self.graphBackground:SetIsVisible(b)
end
function CHUDGUI_StaticLineGraph:Destroy()
    GUI.DestroyItem(self.graphBackground)
end
function CHUDGUI_StaticLineGraph:SetPosition(p)
    self.graphBackground:SetPosition(p)
end
function CHUDGUI_StaticLineGraph:SetAnchor(x,y)
    self.graphBackground:SetAnchor(x,y)
end
function CHUDGUI_StaticLineGraph:SetSize(s)
    self.graphSize = s
    self.graphBackground:SetSize(s)
    self:refreshGrid()
    self:refreshLines()
end
function CHUDGUI_StaticLineGraph:SetTitle(t)
    self.titleItem:SetText(t)
end
function CHUDGUI_StaticLineGraph:SetLabels(x,y)
    self.xLabelItem:SetText(x)
    self.yLabelItem:SetText(y)
end
local function adjustUpperBound(bound, spacing)
    local r = bound%spacing
    if r == 0 then
        return bound
    end
    return bound - r + spacing
end
local function adjustLowerBound(bound, spacing)
    local r = bound%spacing
    if r == 0 then
        return bound
    end
    return bound - r - spacing
end
function CHUDGUI_StaticLineGraph:adjustBoundsToGridSpacing()
    self.max.y = adjustUpperBound(self.max.y, self.gridSpacing.y)
    --self.min.y = adjustLowerBound(self.min.y, self.gridSpacing.y)
end
function CHUDGUI_StaticLineGraph:SetXGridSpacing(x)
    if self.gridSpacing.x ~= x then
        self.gridSpacing.x = x
        self:refreshGrid(false, true)
    end
end
function CHUDGUI_StaticLineGraph:SetYGridSpacing(y)
    if self.gridSpacing.y ~= y then
        self.gridSpacing.y = y
        self:adjustBoundsToGridSpacing()
        self:refreshGrid(true, false)
    end
end    
function CHUDGUI_StaticLineGraph:SetXBounds(n,x,ignoreLines)
    self.min.x = n
    self.max.x = x
    self:refreshGrid(false, true)
    if not ignoreLines then
        self:refreshLines()
    end
end
function CHUDGUI_StaticLineGraph:SetYBounds(n,y,ignoreLines)
    self.min.y = n
    self.max.y = y
    self:adjustBoundsToGridSpacing()
    self:refreshGrid(true, false)
    if not ignoreLines then
        self:refreshLines()
    end
end
function CHUDGUI_StaticLineGraph:SetXAxisIsTime(bool)
    self.xAxisIsTime = bool
    self:refreshGrid(false, true)
end
function CHUDGUI_StaticLineGraph:ExtendXAxisToBounds(bool)
    self.xAxisToBounds = bool
    self:refreshLines()
end

function CHUDGUI_StaticLineGraph:toGameTimeString(timeInt)

    local minutes = math.floor(timeInt/60)
    local seconds = timeInt - minutes*60
    return string.format("%d:%02d", minutes, seconds)

end

function CHUDGUI_StaticLineGraph:scalePoint(point)
    return Vector(((point.x - self.min.x)/(self.max.x - self.min.x)) * self.graphSize.x, self.graphSize.y - ((point.y - self.min.y)/(self.max.y - self.min.y)) * self.graphSize.y,0)
end

function CHUDGUI_StaticLineGraph:refreshLines()

    ClearLines(self.plotLines)
    for l = 1, #self.lines do
        local linePoints = self.lines[l]
        local color = self.colors[l]
        -- scale and plot points
        if #linePoints > 0 then
            local previous = self:scalePoint(linePoints[1])
            for i = 2, #linePoints do
                local current = self:scalePoint(linePoints[i])
                AddLine(self, self.plotLines, previous, current, color)
                previous = current
            end
            if self.xAxisToBounds then
                local lastPoint = linePoints[#linePoints]
                if lastPoint then
                    local pointAtBounds = Vector(self.max.x, lastPoint.y, 0)
                    local toBounds = self:scalePoint(pointAtBounds)
                    AddLine(self, self.plotLines, previous, toBounds, color)
                end
            end
        end
    end
end

function CHUDGUI_StaticLineGraph:freeNameItem(index, isX)

    local nameItem
    if isX then
        nameItem = table.remove(self.xActiveNames, index)
    else
        nameItem = table.remove(self.yActiveNames, index)
    end
    
    if nameItem then
        nameItem:SetIsVisible(false)
        if self.stencilFunc then
            nameItem:SetStencilFunc(self.stencilFunc)
        end
        table.insert(self.reuseNames, nameItem) 
    end

end

function CHUDGUI_StaticLineGraph:getNameItem(isX)

    local nameItem

    if #self.reuseNames > 0 then
        nameItem = table.remove(self.reuseNames, 1)
        nameItem:SetIsVisible(true)
        if self.stencilFunc then
            nameItem:SetStencilFunc(self.stencilFunc)
        end
    else
        nameItem = GUIManager:CreateTextItem()
        if self.stencilFunc then
            nameItem:SetStencilFunc(self.stencilFunc)
        end
        nameItem:SetFontName(kFontName)
        nameItem:SetScale(kFontScale)
        GUIMakeFontScale(nameItem)
        nameItem:SetColor(fontColor)
        self.graphBackground:AddChild(nameItem)
    end
    if isX then
        table.insert(self.xActiveNames, nameItem)
    else
        table.insert(self.yActiveNames, nameItem)
    end
    return nameItem
end

function CHUDGUI_StaticLineGraph:refreshGrid(ignoreX, ignoreY)
    
    if not ignoreX then    
        ClearLines(self.xGridLines)
        for i = 1, #self.xActiveNames do
            self:freeNameItem(1, true)
        end
        for x = self.min.x, self.max.x, self.gridSpacing.x do
        
            local xOffset = self:scalePoint(Vector(x,self.min.y,0))
            AddLine(self, self.xGridLines, xOffset - Vector(0,self.graphSize.y,0), xOffset, gridColor)
            
            local lineString
            if self.xAxisIsTime then
                lineString = self:toGameTimeString(x)
            else
                lineString = tostring(x)
            end
            local nameItem = self:getNameItem(true)
            nameItem:SetText(lineString)
            nameItem:SetTextAlignmentX(GUIItem.Align_Center)
            nameItem:SetTextAlignmentY(GUIItem.Align_Min)
            nameItem:SetPosition(xOffset + xPadding)
            
        end
    end
    
    if not ignoreY then    
        ClearLines(self.yGridLines)
        for i = 1, #self.yActiveNames do
            self:freeNameItem(1, false)
        end
        for y = self.min.y, self.max.y, self.gridSpacing.y do
        
            local yOffset = self:scalePoint(Vector(self.min.x,y,0))
            AddLine(self, self.yGridLines, yOffset, yOffset + Vector(self.graphSize.x,0,0), gridColor)
            
            local lineString = tostring(y)
            local nameItem = self:getNameItem(false)
            nameItem:SetText(lineString)
            nameItem:SetTextAlignmentX(GUIItem.Align_Max)
            nameItem:SetTextAlignmentY(GUIItem.Align_Center)
            nameItem:SetPosition(yOffset + yPadding)
            
        end
    end
end