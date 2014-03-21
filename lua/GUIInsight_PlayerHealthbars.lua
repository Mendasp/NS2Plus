// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIInsight_PlayerHealthbars.lua
//
// Created by: Jon 'Huze' Hughes (jon@jhuze.com)
//
// Spectator: Displays player name and healthbars
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIInsight_PlayerHealthbars' (GUIScript)

local playerList
local reusebackgrounds

local kPlayerHealthDrainRate = 0.75 --Percent per ???

local kFontName = "fonts/insight.fnt"
local kPlayerHealthBarTexture = "ui/healthbarplayer.dds"
local kPlayerHealthBarTextureSize = Vector(100, 7, 0)

local kEnergyBarTexture = "ui/healthbarsmall.dds"
local kEnergyBarTextureSize = Vector(100, 6, 0)

local kNameFontScale = GUIScale(Vector(1,1,1)) * 0.8
local kPlayerHealthBarSize = GUIScale(Vector(100, 7, 0))
local kPlayerEnergyBGSize = GUIScale(Vector(100, 6, 0))
local kPlayerEnergyBarSize = GUIScale(Vector(98, 5, 0))
local kPlayerEnergyBarOffest = GUIScale(Vector(1, 0, 0))
local kHealthbarOffset = Vector(0, -kPlayerHealthBarSize.y - GUIScale(16), 0)

-- Color constants.
local kHealthColors = {kBlueColor, kRedColor}
local kArmorColors = {Color(0, 0.5, 0.8, 1), Color(0.8,0.35,0,1)}
local kParasiteColor = Color(1, 1, 0, 1)
local kPoisonColor = Color(0, 1, 0, 1)
local kHealthDrainColor = Color(1, 0, 0, 1)
local kEnergyColor = Color(1,1,0,1)
local kAmmoColors = {
    ["rifle"] = Color(0,0,1,1), // blue
    ["pistol"] = Color(0,1,1,1), // teal
    ["axe"] = Color(1,1,1,1), // white
    ["welder"] = Color(1,1,1,1), // white
    ["builder"] = Color(1,1,1,1), // white
    ["mine"] = Color(1,1,1,1), // white
    ["shotgun"] = Color(0,1,0,1), // green
    ["flamethrower"] = Color(1,1,0,1), // yellow
    ["grenadelauncher"] = Color(1,0,1,1), // magenta
    ["minigun"] = Color(1,0,0,1), // red
    ["railgun"] = Color(1,0.5,0,1)} // orange

function GUIInsight_PlayerHealthbars:Initialize()

    playerList = table.array(16)
    reusebackgrounds = table.array(16)

end

function GUIInsight_PlayerHealthbars:Uninitialize()

    -- Players
    for i, player in pairs(playerList) do
        GUI.DestroyItem(player.Background)
    end
    
    playerList = nil
    
    -- Reuse items
    for index, background in ipairs(reusebackgrounds) do
        GUI.DestroyItem(background["Background"])
    end
    reusebackgrounds = nil

end

function GUIInsight_PlayerHealthbars:OnResolutionChanged(oldX, oldY, newX, newY)

    self:Uninitialize()
    kPlayerHealthBarSize = GUIScale(Vector(100, 7, 0))
    kPlayerEnergyBarSize = GUIScale(Vector(100, 5, 0))
    self:Initialize()

end

function GUIInsight_PlayerHealthbars:Update(deltaTime)

    local player = Client.GetLocalPlayer()
    if not player then
        return
    end

    self:UpdatePlayers(deltaTime)
    
end

function GUIInsight_PlayerHealthbars:UpdatePlayers(deltaTime)

    local players = Shared.GetEntitiesWithClassname("Player")
    
    -- Remove old players
        
    for id, player in pairs(playerList) do
    
        local contains = false
        for key, newPlayer in ientitylist(players) do
            if id == newPlayer:GetId() then
                contains = true
            end
        end

        if not contains then
        
            -- Store unused elements for later
            player.Background:SetIsVisible(false)
            table.insert(reusebackgrounds, player)
            playerList[id] = nil
            
        end
    end
    
    -- Add new and Update all players
    
    for index, player in ientitylist(players) do

        local playerIndex = player:GetId()
        local relevant = player:GetIsVisible() and player:GetIsAlive() and not player:isa("Commander") and not player:isa("Spectator") and not player:isa("ReadyRoomPlayer")
            
        if relevant then
        
            local min, max = player:GetModelExtents()       
            local nameTagWorldPosition = player:GetOrigin() + Vector(0, max.y, 0)
        
            local health = player:GetHealth()
            local armor = player:GetArmor() * kHealthPointsPerArmor
            local maxHealth = player:GetMaxHealth()
            local maxArmor = player:GetMaxArmor() * kHealthPointsPerArmor            
            local healthFraction = health/(maxHealth+maxArmor)
            local armorFraction = armor/(maxHealth+maxArmor)

            local nameTagInScreenspace = Client.WorldToScreen(nameTagWorldPosition) + kHealthbarOffset
            local textColor = Color(kNameTagFontColors[player:GetTeamType()])
            local healthColor = kHealthColors[player:GetTeamType()]
            local armorColor = kArmorColors[player:GetTeamType()]
            local isPoisoned = player.poisoned
            local isParasited = player.parasited
            
            -- Get/Create Player GUI Item
            local playerGUI
            if not playerList[playerIndex] then -- Add new GUI for new players
            
                playerGUI = self:CreatePlayerGUIItem()
                playerGUI.StoredValues.TotalFraction = healthFraction+armorFraction
                table.insert(playerList, playerIndex, playerGUI)

            else
            
                playerGUI = playerList[playerIndex]
                
            end

            playerGUI.Background:SetIsVisible(true)
            
            -- Set player info --
            
            -- background
            local background = playerGUI.Background
            background:SetPosition(nameTagInScreenspace)
            
            -- name
            local nameItem = playerGUI.Name
            nameItem:SetText(player:GetName())
            nameItem:SetColor(ConditionalValue(isParasited, kParasiteColor, textColor))
            
            -- health bar
            local healthBar = playerGUI.HealthBar
            local healthBarSize = healthFraction * kPlayerHealthBarSize.x
            local healthBarTextureSize = healthFraction * kPlayerHealthBarTextureSize.x
            healthBar:SetTexturePixelCoordinates(unpack({0, 0, healthBarTextureSize, kPlayerHealthBarTextureSize.y}))
            healthBar:SetSize(Vector(healthBarSize, kPlayerHealthBarSize.y, 0))
            healthBar:SetColor(healthColor)
            /*
            if isPoisoned then
                healthBar:SetColor(kPoisonColor)
            elseif isParasited then
                healthBar:SetColor(kParasiteColor)
            else
                healthBar:SetColor(healthColor)
            end
            */
            -- armor bar
            local armorBar = playerGUI.ArmorBar
            local armorBarSize = armorFraction * kPlayerHealthBarSize.x
            local armorBarTextureSize = armorFraction * kPlayerHealthBarTextureSize.x
            armorBar:SetTexturePixelCoordinates(unpack({healthBarTextureSize, 0, healthBarTextureSize+armorBarTextureSize, kPlayerHealthBarTextureSize.y}))
            armorBar:SetSize(Vector(armorBarSize, kPlayerHealthBarSize.y, 0))
            armorBar:SetPosition(Vector(healthBarSize, 0, 0))
            armorBar:SetColor(armorColor)
            
            -- health change bar
            local healthChangeBar = playerGUI.HealthChangeBar
            local totalFraction = healthFraction+armorFraction
            local prevTotalFraction = playerGUI.StoredValues.TotalFraction
            if prevTotalFraction > totalFraction then
            
                healthChangeBar:SetIsVisible(true)
                local changeBarSize = (prevTotalFraction - totalFraction) * kPlayerHealthBarSize.x
                local changeBarTextureSize = (prevTotalFraction - totalFraction) * kPlayerHealthBarTextureSize.x
                healthChangeBar:SetTexturePixelCoordinates(armorBarTextureSize+healthBarTextureSize, 0,  armorBarTextureSize+healthBarTextureSize + changeBarTextureSize, kPlayerHealthBarTextureSize.y)
                healthChangeBar:SetSize(Vector(changeBarSize, kPlayerHealthBarSize.y, 0))
                healthChangeBar:SetPosition(Vector(healthBarSize + armorBarSize, 0, 0))
                playerGUI.StoredValues.TotalFraction = math.max(totalFraction, prevTotalFraction - (deltaTime * kPlayerHealthDrainRate))
                
            else

                healthChangeBar:SetIsVisible(false)
                playerGUI.StoredValues.TotalFraction = totalFraction
                
            end
            
            local energyBG = playerGUI.EnergyBG
            local energyBar = playerGUI.EnergyBar
            local energyFraction = 1.0
            -- Energy bar for aliems
            if player:isa("Alien") then
                energyBG:SetIsVisible(true)
                energyFraction = player:GetEnergy() / player:GetMaxEnergy()
                energyBar:SetColor(kEnergyColor)
            -- Ammo bar for marimes
            else
                local activeWeapon = player:GetActiveWeapon()
                if activeWeapon then
                    local ammoColor = kAmmoColors[activeWeapon.kMapName] or kEnergyColor
                    if activeWeapon:isa("ClipWeapon") then
                        energyFraction = activeWeapon:GetClip() / activeWeapon:GetClipSize()
                    elseif activeWeapon:isa("ExoWeaponHolder") then
                        local leftWeapon = Shared.GetEntity(activeWeapon.leftWeaponId)
                        local rightWeapon = Shared.GetEntity(activeWeapon.rightWeaponId)
                        // Exo weapons. Dual wield will just show as the averaged value for now. Maybe 2 bars eventually?
                        if rightWeapon:isa("Railgun") then
                            energyFraction = rightWeapon:GetChargeAmount()
                            if leftWeapon:isa("Railgun") then
                                energyFraction = (energyFraction + leftWeapon:GetChargeAmount()) / 2.0
                            end
                        elseif rightWeapon:isa("Minigun") then
                            energyFraction = rightWeapon.heatAmount
                            if leftWeapon:isa("Minigun") then
                                energyFraction = (energyFraction + leftWeapon.heatAmount) / 2.0
                            end
                            energyFraction = 1 - energyFraction
                        end                            
                        ammoColor = kAmmoColors[rightWeapon.kMapName]
                    end
                    energyBar:SetColor(ammoColor)
                end
            end
            energyBar:SetTexturePixelCoordinates(0, 0, energyFraction * kEnergyBarTextureSize.x, kEnergyBarTextureSize.y)
            energyBar:SetSize(Vector(kPlayerEnergyBarSize.x * energyFraction, kPlayerEnergyBarSize.y, 0))
            
        else -- No longer relevant, remove if necessary
        
            if playerList[playerIndex] then
                GUI.DestroyItem(playerList[playerIndex].Background)
                playerList[playerIndex] = nil
            end
        
        end

    end

end

function GUIInsight_PlayerHealthbars:CreatePlayerGUIItem()

    -- Reuse an existing healthbar item if there is one.
    if table.count(reusebackgrounds) > 0 then
        local returnbackground = reusebackgrounds[1]
        table.remove(reusebackgrounds, 1)
        return returnbackground
    end

    local playerBackground = GUIManager:CreateGraphicItem()
    playerBackground:SetLayer(kGUILayerPlayerNameTags)
    playerBackground:SetColor(Color(0,0,0,0))
    
    local playerNameItem = GUIManager:CreateTextItem()
    playerNameItem:SetFontName(kFontName)
    playerNameItem:SetScale(kNameFontScale)
    playerNameItem:SetTextAlignmentX(GUIItem.Align_Center)
    playerNameItem:SetTextAlignmentY(GUIItem.Align_Max)
    playerBackground:AddChild(playerNameItem)

    local playerHealthBackground = GUIManager:CreateGraphicItem()
    playerHealthBackground:SetSize(Vector(kPlayerHealthBarSize.x, kPlayerHealthBarSize.y, 0))
    playerHealthBackground:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerHealthBackground:SetColor(Color(0,0,0,0.75))
    playerHealthBackground:SetPosition(Vector(-kPlayerHealthBarSize.x/2, 0, 0))
    playerBackground:AddChild(playerHealthBackground)

    local playerHealthBar = GUIManager:CreateGraphicItem()
    playerHealthBar:SetSize(kPlayerHealthBarSize)
    playerHealthBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerHealthBar:SetTexture(kPlayerHealthBarTexture)
    playerHealthBackground:AddChild(playerHealthBar)
    
    local playerArmorBar = GUIManager:CreateGraphicItem()
    playerArmorBar:SetSize(kPlayerHealthBarSize)
    playerArmorBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerArmorBar:SetTexture(kPlayerHealthBarTexture)
    playerHealthBackground:AddChild(playerArmorBar)
    
    local playerHealthChangeBar = GUIManager:CreateGraphicItem()
    playerHealthChangeBar:SetSize(kPlayerHealthBarSize)
    playerHealthChangeBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerHealthChangeBar:SetTexture(kPlayerHealthBarTexture)
    playerHealthChangeBar:SetColor(kHealthDrainColor)
    playerHealthChangeBar:SetIsVisible(false)
    playerHealthBackground:AddChild(playerHealthChangeBar)
    
    local playerEnergyBackground = GUIManager:CreateGraphicItem()
    playerEnergyBackground:SetSize(kPlayerEnergyBGSize)
    playerEnergyBackground:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerEnergyBackground:SetColor(Color(0,0,0,0.75))
    playerEnergyBackground:SetPosition(Vector(-kPlayerEnergyBGSize.x/2, kPlayerHealthBarSize.y, 0))
    playerBackground:AddChild(playerEnergyBackground)
    
    local playerEnergyBar = GUIManager:CreateGraphicItem()
    playerEnergyBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerEnergyBar:SetTexture(kEnergyBarTexture)
    playerEnergyBar:SetPosition(kPlayerEnergyBarOffest)
    playerEnergyBackground:AddChild(playerEnergyBar)
    
    return { Background = playerBackground, Name = playerNameItem, HealthBar = playerHealthBar, ArmorBar = playerArmorBar, HealthChangeBar = playerHealthChangeBar, EnergyBG = playerEnergyBackground, EnergyBar = playerEnergyBar, StoredValues = {TotalFraction = -1} }
end