Script.Load("lua/NS2Plus/CHUD_Shared.lua")

Script.Load("lua/NS2Plus/Client/CHUD_Particles.lua")
Script.Load("lua/NS2Plus/Client/CHUD_MainMenu.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Settings.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Options.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Atmospherics.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Lights.lua")
Script.Load("lua/NS2Plus/Client/CHUD_UnitStatus.lua")
Script.Load("lua/NS2Plus/Client/CHUD_PlayerClient.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Tracers.lua")
Script.Load("lua/NS2Plus/Client/CHUD_ScoreDisplay.lua")
Script.Load("lua/NS2Plus/Client/CHUD_ServerBrowser.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Sounds.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Hitsounds.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Outlines.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Decals.lua")
Script.Load("lua/NS2Plus/Client/CHUD_WeaponTime.lua")
Script.Load("lua/NS2Plus/Client/CHUD_Dissolve.lua")
Script.Load("lua/NS2Plus/Client/CHUD_ViewModel.lua")
Script.Load("lua/NS2Plus/Client/CHUD_GoldenMode.lua")
Script.Load("lua/NS2Plus/Client/CHUD_DropPack.lua")
Script.Load("lua/NS2Plus/Client/CHUD_TeamMessenger.lua")

-- Add drop circles for some tech
LookupTechData(kTechId.Hallucinate, kTechDataGhostModelClass, "AlienGhostModel")
LookupTechData(kTechId.Hallucinate, kVisualRange, HallucinationCloud.kRadius)
LookupTechData(kTechId.Hallucinate, kTechDataModel, BoneWall.kModelName)
LookupTechData(kTechId.Hallucinate, kTechDataIgnorePathingMesh, true)
LookupTechData(kTechId.Hallucinate, kTechDataAllowStacking, true)

LookupTechData(kTechId.EnzymeCloud, kTechDataGhostModelClass, "AlienGhostModel")
LookupTechData(kTechId.EnzymeCloud, kVisualRange, EnzymeCloud.kRadius)
LookupTechData(kTechId.EnzymeCloud, kTechDataModel, BoneWall.kModelName)
LookupTechData(kTechId.EnzymeCloud, kTechDataIgnorePathingMesh, true)
LookupTechData(kTechId.EnzymeCloud, kTechDataAllowStacking, true)

LookupTechData(kTechId.MucousMembrane, kTechDataGhostModelClass, "AlienGhostModel")
LookupTechData(kTechId.MucousMembrane, kVisualRange, MucousMembrane.kRadius)
LookupTechData(kTechId.MucousMembrane, kTechDataModel, BoneWall.kModelName)
LookupTechData(kTechId.MucousMembrane, kTechDataIgnorePathingMesh, true)
LookupTechData(kTechId.MucousMembrane, kTechDataAllowStacking, true)

LookupTechData(kTechId.NutrientMist, kTechDataGhostModelClass, "AlienGhostModel")
LookupTechData(kTechId.NutrientMist, kVisualRange, NutrientMist.kSearchRange)
LookupTechData(kTechId.NutrientMist, kTechDataModel, BoneWall.kModelName)
LookupTechData(kTechId.NutrientMist, kTechDataIgnorePathingMesh, true)
LookupTechData(kTechId.NutrientMist, kTechDataAllowStacking, true)

LookupTechData(kTechId.Rupture, kTechDataGhostModelClass, "AlienGhostModel")
LookupTechData(kTechId.Rupture, kVisualRange, Rupture.kRadius)
LookupTechData(kTechId.Rupture, kTechDataModel, BoneWall.kModelName)
LookupTechData(kTechId.Rupture, kTechDataIgnorePathingMesh, true)
LookupTechData(kTechId.Rupture, kTechDataAllowStacking, true)

local function OnLoadComplete()
	GetCHUDSettings()
	Script.Load("lua/NS2Plus/CHUD_GUIScripts.lua")
	Shared.Message("NS2+ v" .. kCHUDVersion .. " loaded (NS2 Build " .. Shared.GetBuildNumber() .. "). Type \"plus\" in console for available commands. You can also customize your game from the options menu.")
end

local function OnLocalPlayerChanged()
	CHUDLoadLights()
	CHUDEvaluateGUIVis()
end

-- Apparently NS2 doesn't always call OnLocalPlayerChanged when changing teams, so this
local lastTeam
local function OnUpdateClient()
	if Client.GetLocalPlayer() and lastTeam ~= Client.GetLocalPlayer():GetTeamNumber() then
		CHUDApplyTeamSpecificStuff()
		lastTeam = Client.GetLocalPlayer():GetTeamNumber()
	end
end

Event.Hook("UpdateClient", OnUpdateClient)
Event.Hook("LoadComplete", OnLoadComplete)
Event.Hook("LocalPlayerChanged", OnLocalPlayerChanged)

function Client.AddWorldMessage(messageType, message, position, entityId)

	// Only add damage messages if we have it enabled
	if messageType ~= kWorldTextMessageType.Damage or Client.GetOptionBoolean( "drawDamage", true ) then

		// If we already have a message for this entity id, update existing message instead of adding new one
		local time = Client.GetTime()
			
		local updatedExisting = false
		
		if messageType == kWorldTextMessageType.Damage and entityId ~= nil and entityId ~= Entity.invalidId then
		
			for _, currentWorldMessage in ipairs(Client.worldMessages) do
			
				if currentWorldMessage.messageType == messageType and currentWorldMessage.entityId == entityId and currentWorldMessage.canAccumulate then

					currentWorldMessage.creationTime = time
					currentWorldMessage.position = position
					currentWorldMessage.previousNumber = tonumber(currentWorldMessage.message)
					currentWorldMessage.message = currentWorldMessage.message + message
					currentWorldMessage.minimumAnimationFraction = kWorldDamageRepeatAnimationScalar
					
					updatedExisting = true
					break
					
				end
				
			end
			
		end
		
		if not updatedExisting then
		
			local worldMessage = {}
			
			worldMessage.messageType = messageType
			worldMessage.message = message
			worldMessage.position = position        
			worldMessage.creationTime = time
			worldMessage.entityId = entityId
			worldMessage.animationFraction = 0
			worldMessage.lifeTime = ConditionalValue(kWorldTextMessageType.CommanderError == messageType, kCommanderErrorMessageLifeTime, kWorldMessageLifeTime)
			
			if messageType == kWorldTextMessageType.Damage then
				
				worldMessage.lifeTime = CHUDGetOption("damagenumbertime")
				
				local player = Client.GetLocalPlayer()
				local weapon = player and player:GetActiveWeapon()
				if weapon and weapon:isa("Shotgun") and CHUDGetOption( "uniqueshotgunhits" ) then
					worldMessage.canAccumulate = false
				else
					worldMessage.canAccumulate = true
				end
					
			end
			
			if messageType == kWorldTextMessageType.CommanderError then
			
				local commander = Client.GetLocalPlayer()
				if commander then
					commander:TriggerInvalidSound()
				end
				
			end
			
			table.insert(Client.worldMessages, worldMessage)
			
		end
		
	end
	
end

local kNS2PlusDevBadgeTexture = PrecacheAsset("ui/badges/ns2plus_dev_20.dds")
local oldBadgesGetBadgeTextures = Badges_GetBadgeTextures
function Badges_GetBadgeTextures( clientId, usecase )
	local badges, badgeNames = oldBadgesGetBadgeTextures( clientId, usecase )
	if usecase == "scoreboard" then
		local steamid = GetSteamIdForClientIndex( clientId )
		local playerName = string.UTF8Lower(Scoreboard_GetPlayerData(clientId, "Name"))
		if steamid == 49009641 and not table.contains(badgeNames, "ns2plus_dev") then
			-- remi.D
			badges[#badges+1] = "ui/badges/community_dev_20.dds"
			badgeNames[#badgeNames+1] = "community_dev"
			badges[#badges+1] = kNS2PlusDevBadgeTexture
			badgeNames[#badgeNames+1] = "ns2plus_dev"
		end
		if steamid == 39843 and not table.contains(badgeNames, "ns2plus_god") then
			-- mendasp
			badges[#badges+1] = kNS2PlusDevBadgeTexture
			badgeNames[#badgeNames+1] = "ns2plus_god"
		end
	end
	return badges, badgeNames
end

local oldGetBadgeFormalName = GetBadgeFormalName
function GetBadgeFormalName( name )
	if name ~= "ns2plus_dev" and name ~= "ns2plus_god" then
		return oldGetBadgeFormalName( name )
	elseif name == "ns2plus_dev" then
		return "NS2+ Developer"
	else
		return "NS2+ God / Developer"
	end
end
