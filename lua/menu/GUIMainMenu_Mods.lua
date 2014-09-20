// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIMainMenu_Mods.lua
//
//    Created by:   Marc Delorme (marc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Translates from names returned by Client.GetModState to what we display
local kModStateNames =
    {
        getting_info = Locale.ResolveString("MODS_STATE_1"),
        queued_to_download = Locale.ResolveString("MODS_STATE_2"),
        downloading = Locale.ResolveString("MODS_STATE_3"),
        unavailable = Locale.ResolveString("MODS_STATE_4"),
        available = Locale.ResolveString("MODS_STATE_5"),
    }

function GUIMainMenu:RefreshModsList()
    Client.RefreshModList()
end

local kGetModsURL = "http://steamcommunity.com/workshop/browse?appid=4920"

local gLastSortType = 0
local gSortReversed = false

// 0 = default, 1 = NAME, 2 = STATE, 3 = SUBSCRIBED, 4 = ACTIVE
function GUIMainMenu:SortModsBy(field)

    
    if field == 0 then
        table.sort(self.modsTable.tableData, (function(a, b)
            if a[4] == b[4] then
                if a[3] == b[3] then
                    return string.lower(a[1]) < string.lower(b[1])
                else
                    return a[3] > b[3]
                end
            else
                return a[4] > b[4]
            end
        end))
    else
        if gLastSortType == field then
            gSortReversed = not gSortReversed
        else
            gSortReversed = false
        end
        
        table.sort(self.modsTable.tableData, (function(a, b)
            if string.lower(a[field]) == string.lower(b[field]) then
                -- keep it alphabetical
                return string.lower(a[1]) < string.lower(b[1])
            end
            if not gSortReversed then
                return string.lower(a[field]) > string.lower(b[field])
            else
                return string.lower(a[field]) < string.lower(b[field])
            end
        end))
    end
    
    gLastSortType = field
    
    for i, modEntry in pairs(self.modsTable.tableData) do
        self.displayedMods[modEntry.row:GetId()].rowIdx = i
    end
    self.modsTable:RenderTable()
end

function GUIMainMenu:CreateModsWindow()

    self.modsWindow = self:CreateWindow()
    self.modsWindow:DisableCloseButton()
    self.modsWindow:ResetSlideBar()
    self:SetupWindow(self.modsWindow, "MODS")
    self.modsWindow:GetContentBox():SetCSSClass("mod_list")
    
    local back = CreateMenuElement(self.modsWindow, "MenuButton")
    back:SetCSSClass("back")
    back:SetText(Locale.ResolveString("BACK"))
    back:AddEventCallbacks({ OnClick = function() self.modsWindow:SetIsVisible(false) sorted = false end })
    
    local getMods = CreateMenuElement(self.modsWindow, "MenuButton")
    getMods:SetCSSClass("getmods")
    getMods:SetText(Locale.ResolveString("GET_MODS"))
    getMods:AddEventCallbacks({ OnClick = function() Client.ShowWebpage(kGetModsURL) end })
    //getMods:AddEventCallbacks({ OnClick = function() SetMenuWebView(kGetModsURL, Vector(Client.GetScreenWidth() * 0.8, Client.GetScreenHeight() * 0.8, 0)) end })
    
    local restart = CreateMenuElement(self.modsWindow, "MenuButton")
    restart:SetCSSClass("apply")
    restart:SetText(Locale.ResolveString("RESTART"))
    restart:AddEventCallbacks({ OnClick = function() Client.RestartMain() end })
    
    self.highlightMod = CreateMenuElement(self.modsWindow:GetContentBox(), "Image")
    self.highlightMod:SetCSSClass("highlight_server")
    self.highlightMod:SetIgnoreEvents(true)
    self.highlightMod:SetIsVisible(false)
    
    self.blinkingArrow = CreateMenuElement(self.highlightMod, "Image")
    self.blinkingArrow:SetCSSClass("blinking_arrow")
    self.blinkingArrow:GetBackground():SetInheritsParentStencilSettings(false)
    self.blinkingArrow:GetBackground():SetStencilFunc(GUIItem.Always)
    
    self.selectMod = CreateMenuElement(self.modsWindow:GetContentBox(), "Image")
    self.selectMod:SetCSSClass("select_server")
    self.selectMod:SetIsVisible(false)
    self.selectMod:SetIgnoreEvents(true)
    
    self.modsRowNames = CreateMenuElement(self.modsWindow, "Table")
    self.modsTable = CreateMenuElement(self.modsWindow:GetContentBox(), "Table")
    
    local entryCallbacks = {
        { OnClick = function() self:SortModsBy(1) end },
        { OnClick = function() self:SortModsBy(2) end },
        { OnClick = function() self:SortModsBy(3) end },
        { OnClick = function() self:SortModsBy(4) end },
    }
   
    self.modsRowNames:SetEntryCallbacks(entryCallbacks)

    local columnClassNames =
    {
        "modname",
        "state",
        "subscribed",
        "active"
    }
    
    local rowNames = { { Locale.ResolveString("MODS_NAME"), Locale.ResolveString("MODS_STATE"), Locale.ResolveString("MODS_SUBSCRIBED"), Locale.ResolveString("MODS_ACTIVE") } }
    
    self.modsRowNames:SetCSSClass("server_list_row_names")
    self.modsRowNames:SetColumnClassNames(columnClassNames)
    self.modsRowNames:SetRowPattern( {RenderServerNameEntry} )
    self.modsRowNames:SetTableData(rowNames)

    local rowPattern =
    {
        RenderModName,
        RenderTextEntry,
        RenderTextEntry,
        RenderTextEntry,
    }
    
    self.modsTable:SetRowPattern(rowPattern)
    self.modsTable:SetCSSClass("mod_list")
    self.modsTable:SetColumnClassNames(columnClassNames)
    
    local OnRowCreate = function(row)
    
        local eventCallbacks =
        {
            OnMouseIn = function(self, buttonPressed)
                MainMenu_OnMouseIn()
            end,
            
            OnMouseOver = function(self)
            
                local height = self:GetHeight()
                local topOffSet = self:GetBackground():GetPosition().y + self:GetParent():GetBackground():GetPosition().y
                self.scriptHandle.highlightMod:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
                self.scriptHandle.highlightMod:SetIsVisible(true)
                
            end,
            
            OnMouseOut = function(self)
                self.scriptHandle.highlightMod:SetIsVisible(false)
            end,
            
            OnMouseDown = function(self)
            
                local height = self:GetHeight()
                local topOffSet = self:GetBackground():GetPosition().y + self:GetParent():GetBackground():GetPosition().y
                self.scriptHandle.selectMod:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
                self.scriptHandle.selectMod:SetIsVisible(true)
                
                // Toggle whether or not the mod is active
                local id = self:GetId()
                Client.SetModActive( id, not Client.GetIsModActive(id) )
                
            end
        }
        
        row:AddEventCallbacks(eventCallbacks)
        row:SetChildrenIgnoreEvents(true)
        
    end
    
    self.modsTable:SetRowCreateCallback(OnRowCreate)
    self.modsTable:SetColumnClassNames(columnClassNames)
    
    self.displayedMods = { }
    self.modsTable:ClearChildren()
        
    self.modsWindow:AddEventCallbacks({ 
        OnShow = function() 
            self.selectMod:SetIsVisible(false)
        end 
    })
    
end

function GUIMainMenu:UpdateModsWindow(self)
    
    local needsreload, needsresort = false, false
    
    -- temp variables used in loop
    local name,state,active,subscribed
    local downloading,bytesDownloaded, totalBytes
    local stateString,percent,currentStatus,visModEntry
    local rowData
    
    for clientModId = 1, Client.GetNumMods() do

        name = Client.GetModTitle(clientModId)
        state = Client.GetModState(clientModId)
        active = ( Client.GetIsModActive(clientModId) and "YES" or "NO" )
        subscribed = ( Client.GetIsSubscribedToMod(clientModId) and "YES" or "NO" )
        downloading, bytesDownloaded, totalBytes = Client.GetModDownloadProgress(clientModId)
        
        stateString = kModStateNames[state] or "??"
        percent = "100%"            
        if downloading then
            percent = "0%"
            if totalBytes > 0 then
                percent = string.format("%d%%", math.floor((bytesDownloaded / totalBytes) * 100))
            end
            stateString = stateString .. " (" .. percent .. ")"
        end
        
        -- cache status as string to easily see if anything has changed
        currentStatus = state .. name .. subscribed .. active .. percent
        
        -- if should show this mod, add or update it
        visModEntry = self.displayedMods[clientModId]
        if state ~= "getting_info" and ( not visModEntry or visModEntry.currentStatus ~= currentStatus ) then
              
            active = Locale.ResolveString(active)
            subscribed = Locale.ResolveString(subscribed)
            
            rowData = { name, stateString, subscribed, active }
            if not visModEntry then
                
                self.modsTable:AddRow( rowData, clientModId )
                self.displayedMods[ clientModId ] = { currentStatus = currentStatus, rowIdx = #self.modsTable.tableData }
            
                needsresort = true -- added new entry, need to resort
                
            else
            
                self.modsTable:UpdateRowData( visModEntry.rowIdx, rowData )
                visModEntry.currentStatus = currentStatus
                
                -- Update the data which is used when sorting
                for i,v in ipairs( rowData ) do
                    self.modsTable.tableData[visModEntry.rowIdx][i] = v
                end
    
            end
             
            needsreload = true -- entry was changed, need to reload
               
        end
        
    end

    -- If the menu was just opened or if a new entry was added and the player hasn't changed the sort mode, need to resort
    if (not self.modsWindow.sorted) or (needsresort and gLastSortType == 0) then
        self:SortModsBy(0) -- calls RenderTable()
        needsreload = false -- already handled ^
        self.modsWindow.sorted = true
    end
    
    if needsreload then
        self.modsTable:RenderTable()
    end
    
end